import Foundation

struct Region {
    let lookup: (Position) -> Bool
}

extension Region {
    /// Region for Battleship example is defined as a circle centered around origin (0, 0)
    public static func circle(radius: Distance) -> Region {
        return Region(lookup: { point in point.length <= radius })
    }
    
    // MARK: - Region Transforms
    
    /// Shifts a `Region` by a given offset both vertically and horizontally
    ///
    /// Instead of creating more complex functions than `circle(radius:)`
    /// We have created a function `shift(_:by:)` that modifies other functions
    public func shift(
        by offset: Position
    ) -> Region {
        return Region(lookup: { point in self.lookup(point.minus(offset)) } )
    }
    
    /// Defines a new `Region` by inverting an existing one
    /// Resulting `Region` consists of all points outside of the given `Region`
    public func invert(_ region: Region) -> Region {
        return Region(lookup: { point in !region.lookup(point) })
    }
    
    /// Find whether a point exists in both provided `Region`
    public func intersect(
        _ region: Region,
        with other: Region
    ) -> Region {
        return Region(lookup: { point in region.lookup(point) && other.lookup(point) })
    }
    
    /// Find whether a point exists in either provided `Region`
    public func union(
        _ region: Region,
        with other: Region
    ) -> Region {
        return Region(lookup: { point in region.lookup(point) || other.lookup(point) })
    }
    
    /// Constructs a new `Region` for all points in the first `Region` but not the second
    ///
    /// The function composition is starting to make sense here!
    /// We've built out tiny modular components, and now we're able to combine them
    /// to create a more sophisticated transformation
    public func subtract(
        _ region: Region
    ) -> Region {
        return Region(lookup: self.lookup)
            .intersect(self, with: invert(region))
    }
}
