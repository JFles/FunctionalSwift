import UIKit

//: ## Case Study: Wrapping Core Image

/// One of the key classes in Core Image is CIFilter to create image filters
/// When instantiating a CIFilter object, you generally need to provide
/// - An input image via the `kCIinputImageKey`
/// - retrieve the filtered result via the `outputImage` property
/// The result can be used as input for the next filter

/// Goal is to encapsulate the details of the key-value pairs and instead
/// present a safe, strongly typed API

// MARK: CIImage Filters - Functional transformations

/// Defining a new `Filter` type as a function
/// which takes an `CIImage` and returns a new `CIImage`.
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

// MARK: Composing Filters

let url = URL(string: "https://i.pinimg.com/originals/46/87/7a/46877a653c8627ff3c253893f1d85bb9.jpg")!
let image = CIImage(contentsOf: url)!

let radius = 5.0
let color = UIColor.red.withAlphaComponent(0.2)
let blurredImage = blur(radius: radius)(image)
let overlaidImage = overlay(color: color)(blurredImage)

//: [Previous](@previous)     [Next](@next)
