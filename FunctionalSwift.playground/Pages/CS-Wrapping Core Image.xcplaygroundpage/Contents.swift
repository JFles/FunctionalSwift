import UIKit
//: # Case Study: Wrapping Core Image
//:
//: One of the key classes in Core Image is CIFilter which is used to create image filters. When instantiating a CIFilter object, you generally need to:
//: - Provide an input image via the `kCIinputImageKey`
//: - Retrieve the filtered result via the `outputImage` property.
//:
//: And the result can be used as input for the next filter
//:
//: For our functional wrapper over select parts of the Core Image API, the goal is to encapsulate the details of the stringly-typed key-value pairs and instead present a safe, strongly typed API which will also lend itself to function composition for creating new filters in a functional manner.
// MARK: CIImage Filters - Functional transformations

/// Defining a new `Filter` type as a function
/// which takes a `CIImage` and returns a new `CIImage`.
typealias Filter = (CIImage) -> CIImage

/// Gaussian Blur filter
func blur(radius: Double) -> Filter {
    return { image in
        let parameters: [String: Any] = [
            kCIInputRadiusKey: radius,
            kCIInputImageKey: image
        ]
        guard let filter = CIFilter(
            name: "CIGaussianBlur",
            parameters: parameters
        ) else {
            fatalError("Could not create CIFilter")
        }
        guard let outputImage = filter.outputImage else {
            fatalError("Could not retrieve output image from filter")
        }
        return outputImage
    }
}

/// Color Overlay
/// Overlays an image with a solid color
/// Core Image does not have an equivalent, but we can compose it with:
/// - `CIConstantColorGenerator` - Color generator filter
/// - `CISourceOverCompositing` - Source-over compositing filter
func overlay(color: UIColor)-> Filter {
    return { image in
        // TODO: Refactor this to avoid double parens
        // !!!: Could instead levarage SwiftUI's declarative dot
        // !!!: Operator style transformations?
        let overlay = generate(color: color)(image).cropped(to: image.extent)
        return compositeSourceOverlay(overlay: overlay)(image)
    }
}

/// `CIConstantColorGenerator` wrapper
func generate(color: UIColor) -> Filter {
    return { _ in
        let parameters: [String: Any] = [
            kCIInputColorKey: CIColor(cgColor: color.cgColor)
        ]
        guard let filter = CIFilter(
            name: "CIConstantColorGenerator",
            parameters: parameters
        ) else {
            fatalError("Could not create CIFilter")
        }
        guard let outputImage = filter.outputImage else {
            fatalError("Could not retrieve output image from filter")
        }
        return outputImage
    }
}

/// `CISourceOverCompositing` wrapper
func compositeSourceOverlay(overlay: CIImage) -> Filter {
    return { image in
        let parameters: [String: Any] = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey: overlay
        ]
        guard let filter = CIFilter(
            name: "CISourceOverCompositing",
            parameters: parameters
        ) else {
            fatalError("Could not create CIFilter")
        }
        guard let outputImage = filter.outputImage else {
            fatalError("Could not retrieve output image from filter")
        }
        return outputImage.cropped(to: image.extent)
    }
}

//: Processing an image with our functional CIFilter wrappers would look like:
let url = URL(string: "https://i.pinimg.com/originals/46/87/7a/46877a653c8627ff3c253893f1d85bb9.jpg")!
let image = CIImage(contentsOf: url)!

let radius = 5.0
let color = UIColor.red.withAlphaComponent(0.2)
let blurredImage = blur(radius: radius)(image)
let overlaidImage = overlay(color: color)(blurredImage)
//: If we combine the blur and overlay into a single filter call, it loses readability quickly with the parens 💩
let result = overlay(color: color)(blur(radius: radius)(image))
//: Instead, we can build a function that composes two filters and returns a new filter!
func compose(
    filter filter1: @escaping Filter,
    with filter2: @escaping Filter
) -> Filter {
    return { image in filter2(filter1(image)) }
}

let blurAndOverlay = compose(
    filter: blur(radius: radius),
    with: overlay(color: color)
)

let result1 = blurAndOverlay(image)

//: Definitely getting there with readability! We can go further with defining a custom infix operator as well. It won't necessarily help with overall code readability, but once you know the operator, it'll make filter definitions much more readable (allegedly)
infix operator >>>

/// Custom infix operator for composing two CIImage filters
/// Left-associative by default, so it can be read as applying filters to an image from right to left
///
/// Enables us to curry multiple filters for function composition of CIFilters
func >>>(
    filter1: @escaping Filter,
    filter2: @escaping Filter
) -> Filter {
    return { image in filter2(filter1(image)) }
}

//: Now we can use our `>>>` operator in place of `compose(filter:with:)`
// !!!: Not a big fan of custom operators
// !!!: It adds cognitive overhead and an additional barrier to new adoptees and maintainers
// !!!: . syntax used with SwiftUI seems like the better option
// !!!: to remain idiomatic and accomplish the same/similar goal
// !!!: with composability
let blurAndOverlay2 = blur(radius: radius) >>> overlay(color: color)
let result2 = blurAndOverlay2(image)


//: [Previous](@previous)     [Next](@next)
