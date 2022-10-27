import Foundation

/* Commented out so the compiler doesn't poo on the walls


//: ## Example: Battleship

// Make a new name for an existing type to make the API more expressive
typealias Distance = Double

// MARK: - Region

/// Region will refer to functions **transforming** a `Position` into a `Bool`
///
/// Instead of representing a `Region` as a class or struct, we represent
/// it as a function that determines if a given point is in the region or not.
/// Also, we gave it a name `Region` rather than a name like `CheckInRegion`
/// because FP's philosophy is that functions are values like a Struct or Boolean
typealias Region = (Position) -> Bool

/// First Region defined is a circle centered around origin (0, 0)
/// Given an argument position `point`,
func circle(radius: Distance) -> Region {
    /// The function we're returning has its inputs and outputs defined by
    /// the called function's return type `Region`
    /// We can use `Region` defined as `(Position) -> Bool` to guide us in
    /// constructing our function we want to return
    return { point in point.length <= radius}
}

// MARK: - Region Transforms

/// Shifts a `Region` by a given offset both vertically and horizontally
///
/// Instead of creating more complex functions than `circle(radius:)`
/// We have created a function `shift(_:by:)` that modifies other functions
func shift(
    _ region: @escaping Region,
    by offset: Position
) -> Region {
    return { point in region(point.minus(offset)) }
}

// Example of creating a circle centered at (5, 5) with radius of 10
let shiftedCircle = shift(circle(radius: 10), by: Position(x: 5, y: 5))

/// Defines a new `Region` by inverting an existing one
/// Resulting `Region` consists of all points outside the given `Region`
func invert(_ region: @escaping Region) -> Region {
    return { point in !region(point) }
}

/// Find whether a point exists in both provided `Region`
func intersect(
    _ region: @escaping Region,
    with other: @escaping Region
) -> Region {
    return { point in region(point) && other(point) }
}

/// Find whether a point exists in either provided `Region`
func union(
    _ region: @escaping Region,
    with other: @escaping Region
) -> Region {
    return { point in region(point) || other(point) }
}

/// Constructs a new `Region` for all points in teh first `Region` but not the second
///
/// The function composition is starting to make sense here!
/// We've built out tiny modular components, and now we're able to combine them
/// to create a more sophisticated transformation
func subtract(
    _ region: @escaping Region,
    from original: @escaping Region
) -> Region {
    return intersect(original, with: invert(region))
}

/// Naive approach to handling a circle not centered at origin (0, 0)
func circle2(radius: Distance, center: Position) -> Region {
    return { point in point.minus(center).length <= radius}
}

func pointInRange(point: Position) -> Bool {
    fatalError("Implement me!")
}

// MARK: - Position

struct Position {
    var x: Double
    var y: Double
}

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


extension Position {
    /// Determine the delta Position between two coordinate points.
    /// Useful for adjusting a point when the circle center is not at origin (0,0).
    /// NOTE: order of delta arguments only flips the sign -- numbers are the same
    /// and `length` will take the sqrt and give us the absolute number
    func minus(_ p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    /// Gives us the computed vector length given side lengths `x` and `y`
    ///
    /// Pythagorean Theorem
    /// => c^2 = a^2 + b^2
    /// => c = sqrt(a^2 + b^2)
    /// => c = length
    var length: Double {
        return sqrt((x * x) + (y * y))
    }
    
    /// Gets the distance from origin with LHS using Pythag Theorem
    /// Compares if it's <= the circle's radius to determine if
    /// our target is within the circle
    /// NOTE: This only works if our ship is at the circle's origin (0, 0)
    func within(range: Distance) -> Bool {
        return sqrt((x * x) + (y * y)) <= range
    }
}

// MARK: - Ship

/// Represents our ship
struct Ship {
    /// Where our ship is currently located if not at origin
    var position: Position
    /// The radius of our circle from origin -- maximum distance we can engage another ship
    var firingRange: Distance
    /// The inner circle from origin where we can't engage another ship
    var unsafeRange: Distance
}

extension Ship {
    
    /// Allows us to test if another ship is w/i our ship's firing range.
    /// Also make sure target is outside our ship's unsafeRange,
    /// and make sure target is outside the unsafeRange of friendly ships.
    func canSafelyEngage_v3(
        ship target: Ship,
        friendly: Ship
    ) -> Bool {
        /// Ship range outside the unsafe Range but inside its max firing range
        let rangeRegion = subtract(
            circle(radius: unsafeRange),
            from: circle(radius: firingRange)
        )
        
        /// Adjust our firing region based on our ship's current position
        let firingRegion = shift(
            rangeRegion,
            by: self.position
        )
        
        /// Determine the unsafe range around our friendly ship
        let friendlyRegion = shift(
            circle(radius: unsafeRange),
            by: friendly.position
        )
        
        /// Remove any points from our firing region that are within the
        /// unsafe range of our friendly ship
        let resultRegion = subtract(
            friendlyRegion,
            from: firingRegion
        )
        
        /// Evaluate the `Region` containing only points where we can safely engage
        /// with the target's position to check whether that point is in the safe Region
        return resultRegion(target.position)
    }
    
    /// Allows us to test if another ship is w/i our ship's firing range.
    /// Also make sure target is outside our ship's unsafeRange,
    /// and make sure target is outside the unsafeRange of friendly ships.
    func canSafelyEngage_v2(
        ship target: Ship,
        friendly: Ship
    ) -> Bool {
        // target relative to our position
        let targetDistance = target.position.minus(position).length
        
        // friendly ship relative to our target's position
        let friendlyDistance = friendly.position.minus(target.position).length
        
        return targetDistance <= firingRange
        && targetDistance > unsafeRange
        && (friendlyDistance > unsafeRange)
    }
    
    /// Allows us to test if another ship is w/i our ship's firing range.
    /// Also make sure target is outside our ship's unsafeRange,
    /// and make sure target is outside the unsafeRange of friendly ships.
    func canSafelyEngage_v1(
        ship target: Ship,
        friendly: Ship
    ) -> Bool {
        let dx = target.position.x - position.x
        let dy = target.position.y - position.y
        let targetDistance = sqrt(dx * dx + dy * dy)
        let friendlyDx = friendly.position.x - target.position.x
        let friendlyDy = friendly.position.y - target.position.y
        let friendlyDistance = sqrt(friendlyDx * friendlyDx +
                                    friendlyDy * friendlyDy)
        return targetDistance <= firingRange
        && targetDistance > unsafeRange
        && (friendlyDistance > unsafeRange)
    }
}

*/
