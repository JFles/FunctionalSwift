import Foundation

/**
 - https://math.stackexchange.com/questions/198764/how-to-know-if-a-point-is-inside-a-circle
 - Circle has center (x_c, y_c)
 - Target point is (x_p, y_p)
 - To determine if point is w/i circle
 - LaTeX => `\sqrt{|x_p-x_c|^2+|y_p-y_c|^2}< r`
 - `sqrt( (x_p - x_c)^2 + (y_p - y_c)^2 ) <= r`, where r = Radius
 */

/// **Does the order for position numbers matter when calculating a delta if we're going to square it?**
// My ship = (5,-7)
// Target ship = (-2,4)
// 5 - (-2) = 7 -> 7^2 = 42
// (-2) - 5 = (-7) => (-7)^2 = 42
// (-7) - 4 = (-11) => (-11)^2 = 121
// 4 - (-7) = 11 => 11^2 = 121
/// THE ANSWER IS A RESOUNDING **NO**
/// The only difference the position of the delta arguments makes is the sign of the resulting number, but the same number results.
/// And the sqrt gives us an absolute number, so the result is the same
public typealias Distance = Double

public struct Position {
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public var x: Double
    public var y: Double
}

extension Position {
    /// Determine the delta Position between two coordinate points.
    /// Useful for adjusting a point when the circle center is not at origin (0,0).
    /// NOTE: order of delta arguments only flips the sign -- numbers are the same
    /// and `length` will take the sqrt and give us the absolute number
    public func minus(_ p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    /// Gives us the computed vector length given side lengths `x` and `y`
    ///
    /// Pythagorean Theorem
    /// => c^2 = a^2 + b^2
    /// => c = sqrt(a^2 + b^2)
    /// => c = length
    public var length: Double {
        return sqrt((x * x) + (y * y))
    }
    
    /// Gets the distance from origin with LHS using Pythag Theorem
    /// Compares if it's <= the circle's radius to determine if
    /// our target is within the circle
    /// NOTE: This only works if our ship is at the circle's origin (0, 0)
    public func within(range: Distance) -> Bool {
        return sqrt((x * x) + (y * y)) <= range
    }
}
