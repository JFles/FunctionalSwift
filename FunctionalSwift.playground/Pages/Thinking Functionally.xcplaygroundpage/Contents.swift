import Foundation

//: ## Example: Battleship

let ourShip = Ship(position: Position(x: 15, y: -7))

let targetShip = Ship(position: Position(x: 14, y: -8))

let friendlyShip = Ship(position: Position(x: 13, y: 2))

ourShip.canSafelyEngage_v4(ship: targetShip, friendly: friendlyShip)

