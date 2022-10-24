import Foundation

// MARK: - Ship

/// Represents our ship
public struct Ship {
    public init(
        position: Position,
        firingRange: Distance = 20.0,
        unsafeRange: Distance = 5.0
    ) {
        self.position = position
        self.firingRange = firingRange
        self.unsafeRange = unsafeRange
    }
    
    /// Where our ship is currently located if not at origin
    public var position: Position
    /// The radius of our circle from origin -- maximum distance we can engage another ship
    public var firingRange: Distance
    /// The inner circle from origin where we can't engage another ship
    public var unsafeRange: Distance
}

extension Ship {
    
    /// Allows us to test if another ship is w/i our ship's firing range.
    /// Also make sure target is outside our ship's unsafeRange,
    /// and make sure target is outside the unsafeRange of friendly ships.
    public func canSafelyEngage_v4(
        ship target: Ship,
        friendly: Ship
    ) -> Bool {
        let unsafeRegion = circle(radius: unsafeRange)
        
        /// Ship range outside the unsafe Range but inside its max firing range
        let rangeRegion = circle(radius: firingRange)
            .subtract(unsafeRegion)
        
        /// Adjust our firing region based on our ship's current position
        let firingRegion = rangeRegion.shift(by: self.position)
       
        /// Determine the unsafe range around our friendly ship
        let friendlyRegion = unsafeRegion
            .shift(by: friendly.position)
       
        /// Remove any points from our firing region that are within the
        /// unsafe range of our friendly ship
        let resultRegion = firingRegion
            .subtract(friendlyRegion)
        
        /// Evaluate the `Region` containing only points where we can safely engage
        /// with the target's position to check whether that point is in the safe Region
        
        return resultRegion.lookup(target.position)
    }
    
    /// Allows us to test if another ship is w/i our ship's firing range.
    /// Also make sure target is outside our ship's unsafeRange,
    /// and make sure target is outside the unsafeRange of friendly ships.
    public func canSafelyEngage_v3(
        ship target: Ship,
        friendly: Ship
    ) -> Bool {
        fatalError("This method depends on Region being implemented as a typealiased function instead of a struct")
        /// Ship range outside the unsafe Range but inside its max firing range
//        let rangeRegion = subtract(
//            circle(radius: unsafeRange),
//            from: circle(radius: firingRange)
//        )
        
        /// Adjust our firing region based on our ship's current position
//        let firingRegion = shift(
//            rangeRegion,
//            by: self.position
//        )
        
        /// Determine the unsafe range around our friendly ship
//        let friendlyRegion = shift(
//            circle(radius: unsafeRange),
//            by: friendly.position
//        )
        
        /// Remove any points from our firing region that are within the
        /// unsafe range of our friendly ship
//        let resultRegion = subtract(
//            friendlyRegion,
//            from: firingRegion
//        )
        
        /// Evaluate the `Region` containing only points where we can safely engage
        /// with the target's position to check whether that point is in the safe Region
//        return resultRegion(target.position)
    }
    
    /// Allows us to test if another ship is w/i our ship's firing range.
    /// Also make sure target is outside our ship's unsafeRange,
    /// and make sure target is outside the unsafeRange of friendly ships.
    public func canSafelyEngage_v2(
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
    public func canSafelyEngage_v1(
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
