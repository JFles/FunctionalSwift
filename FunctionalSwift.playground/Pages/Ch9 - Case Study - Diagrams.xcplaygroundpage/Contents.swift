import UIKit

//: # Ch 9 - Case Study: Diagrams
//:
//: In this chapter, we'll look at a functional way to describe diagrams and discuss how to draw them with Core Graphics. By wrapping Core Graphics with a functional layer, we get an API that's simpler and more composable.
//:
//: ## Drawing Squares and Circles
//:
//: First, lets consider how we would draw a simple diagram in Core Graphics
let bounds = CGRect(origin: .zero, size: CGSize(width: 300, height: 200))
let renderer = UIGraphicsImageRenderer(bounds: bounds)
renderer.image { context in
    UIColor.blue.setFill()
    context.fill(CGRect(x: 0.0, y: 37.5, width: 75.0, height: 75.0))
    UIColor.red.setFill()
    context.fill(CGRect(x: 75.0, y: 0.0, width: 150.0, height: 150.0))
    UIColor.green.setFill()
    context.cgContext.fillEllipse(in: CGRect(x: 225.0, y: 37.5, width: 75.0, height: 75.0))
}
//: This is easy and short code, but it would be difficult to maintain
//:
//: For example, lets say we wanted to insert an extra circle in our diagram between two existing shapes. We'd need to add code for drawing our new circle, and we'd need to adjust our doubles for coordinates to shift our shapes to the right.
//:
//: Core Graphics is an imperative library by design -- we describe **how** to draw things.
//:
//: Our goal in this chapter is to build a library to wrap Core Graphics for diagrams which instead allows us to declaratively describe **what** to draw
//:
//: For example, we could use our declarative wrapper library to rewrite the first example as follows
//let blueSquare = square(size: 1).filled(.blue)
//let redSquare = square(size: 2).filled(.red)
//let greenCircle = circle(diameter: 1).filled(.green)
//let example1 = blueSquare ||| redSquare ||| greenCircle
//: And adding our new circle would be trivially easy
//let cyanCircle = circle(diameter: 1).filled(.cyan)
//let example1 = blueSquare ||| cyanCircle ||| redSquare ||| greenCircle
//: We no longer need to worry about calculating frames or moving coordinates. Instead, we can focus on **_what_** should be drawn, and **_how_** it's drawn is abstracted away from us.

//: Looking back at Ch 1, we constructed regions by composing simple functions. While this helped to illustrate FP concepts, there was a large drawback -- We couldn't inspect **_how_** a region had been constructed. Instead, we could only check whether or not a point was included in the region.
//:
//: In this chapter, we'll improve this aspect
//:
//: Instead of immediately executing our drawing commands, we'll build an intermediate data structure which describes the diagram.
//: This is a very powerful technique -- it allows us to inspect the data structure, modify it, and convert it into different formats.

//: As a more complex example of a diagram generated by our same library, let's create a bar graph.
//:
//: We can write a `barGraph` function that takes a list of names (the keys) and values (the relative heights of the bars). For each value in the dictionary, we draw a suitably sized rectangle. We then horizontally concatenate the rectangles with the `hcat` method. Finally, we put the bars and the text below each other using our custom `---` operator.
//func barGraph(_ input: [(String, Double)]) -> Diagram {
//    let values: [CGFloat] = input.map { CGFloat($0.1) }
//    let bars = values
//        .normalized // values are normalized so that our largest value == 1 -- easier if we're bound between `0 <= x <= 1`
//        .map { x in rect(width: 1, height: 3 * x).filled(.black).aligned(to: .bottom) }
//        .hcat // This name is terrible 💩 -- unless it represents a standardly used declarative function operator, it should be expanded
//    let labels = input
//        .map { label, _ in text(label, width: 1, height: 0.3).aligned(to: .top) }
//        .hcat
//    return bars --- labels // `---` infix operator lays out our `labels` beneath our `bars`
//}

//: ## The Core Data Structures
//:
//: In our library, we'll draw three kinds of things:
//: - ellipses
//: - rectangles
//: - text
//:
//: We can define a data type for these with an enum
enum Primitive {
    case ellipse
    case rectangle
    case text(String)
}
//: Similarly, we can define `Diagrams` using an enum as well
indirect enum Diagram {
    /// A diagram which is a Primitive of the specified `size`
    case primitive(CGSize, Primitive)
    /// Two diagrams which are beside each other
    case beside(Diagram, Diagram)
    /// Two diagrams with one below the other
    case below(Diagram, Diagram)
    /// An attributed diagram to allow a styled diagram
    case attributed(Attribute, Diagram)
    /// Specify alignment for a specified diagram
    case align(CGPoint, Diagram)
}
//: Our `Attribute` enum is a data type for describing different attributes of diagrams. Currently, it only supports `fillColor`, but it could easily be extended to support additional attributes such as stroking, gradients, text attributes, etc.
enum Attribute {
    case fillColor(UIColor)
}

//: ## Calculating and Drawing
//:
//: Calculating the size for the Diagram data type is generally easy. The only cases that aren't straightforward are `beside` and `below`.
//:
//: For `beside`:
//: - width equals the sum of widths
//: - height equals max height of the left and right diagram
//:
//: For `below`, it's a similar patterm. All other cases, we call size recursively
extension Diagram {
    var size: CGSize {
        switch self {
        case .primitive(let size, _):
            return size
        case .attributed(_, let diagram):
            return diagram.size
        case let .beside(leftDiagram, rightDiagram):
            return CGSize(
                width: leftDiagram.size.width + rightDiagram.size.width,
                height: max(leftDiagram.size.height, rightDiagram.size.height)
            )
        case let .below(leftDiagram, rightDiagram):
            return CGSize(
                width: max(leftDiagram.size.width, rightDiagram.size.width),
                height: leftDiagram.size.height + rightDiagram.size.height
            )
        case .align(_, let diagram):
            return diagram.size
        }
    }
}
//: Before we start drawing, we'll define one more method.
//:
//: The `fit(into:alignment)` method scales up an input size (e.g. the size of a diagram) to fit into a given rectangle while maintaining the size's aspect ratio.
//:
//: The scaled up size gets positioned within the target rectangle according to the `alignment` parameter. We're using a `CGPoint` to represent this:
//: - `x`
//:   - 0 = left-aligned
//:   - 1 = right-aligned
//: - `y`
//:   - 0 = top-aligned
//:   - 1 = bottom-aligned
extension CGSize {
    func fit(into rect: CGRect, alignment: CGPoint) -> CGRect {
        let scale = min(rect.width / width, rect.height / height)
        let targetSize = scale * self
        let spacerSize = alignment.size * (rect.size - targetSize)
        return CGRect(origin: rect.origin + spacerSize.point, size: targetSize)
    }
}
//: In order to be able to write the calculations in the `fit(into:alignment:)` method above in an expressive way, we'll define the following operations and helper functions `CGSize` and `CGPoint`
func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
}

func *(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
}

func -(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

extension CGSize {
    var point: CGPoint { return CGPoint(x: width, y: height) }
}

extension CGPoint {
    var size: CGSize { return CGSize(width: x, height: y) }
}




//: [Previous](@previous)          [Next](@next)
