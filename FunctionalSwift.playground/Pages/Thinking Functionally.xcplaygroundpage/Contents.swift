import Foundation

//: ## Example: Battleship

let ourShip = Ship(position: Position(x: 0, y: 0))

let targetShip = Ship(position: Position(x: -10, y: -10))
//let targetShip = Ship(position: Position(x: 0, y: 0))

let friendlyShip = Ship(position: Position(x: 10, y: 10))
//let friendlyShip = Ship(position: Position(x: -10, y: -10))

ourShip.canSafelyEngage_v4(ship: targetShip, friendly: friendlyShip)

//: [Next](@next)
