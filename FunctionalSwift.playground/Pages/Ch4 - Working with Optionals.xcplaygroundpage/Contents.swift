import Foundation
//: # Working with Optionals
//:
//: Because Swift's optionals make the possibility of failure explicit, this can be cumbersome to work with -- especially when combining multiple optional results.
//:
//: In this module, we'll cover multiple techniques that will make optionals easier to work with
//:
//: ## Branching on Optionals
//: Besides `if let` unwrapping, Swift offers two other branch statements which are well suited for dealing with optional values -- `guard` and `switch`.
//:
//: To match an optionl value in a `switch` statement, we only need to add a `?` suffix to every pattern in a `case` branch
let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]

let madridPopulation: Int? = cities["Madrid"]

switch madridPopulation {
case 0?: print("Nobody in Madrid")
case (1..<1000)?: print("less than a million in Madrid")
case let x?: print("\(x) people in Madrid")
case nil: print("We don't know about Madrid")
}
//: `guard` is useful when we want to exit the scope early if a precondition isn't met. A common use case is optional unwrapping for a value needed in the function
func populationDescription(for city: String) -> String? {
    guard let population = cities[city] else { return nil }
    return "The population of Madrid is \(population)"
}
//:
//: ## Optional Mapping
//: There are plenty of times where the behavior we want is to manipulate an optional value if it exists else return `nil`. For example, consider a simple increment on an optional `Int?`
func increment(optional: Int?) -> Int? {
    guard let x = optional else { return nil }
    return x + 1
}
//: We can generalize both `increment(optional:)` and the `?` operator and define a map function on optionals. Rather than only increment a value of type `Int?`, we pass the operation we wish to perform as an argument to the map function
extension Optional {
    /// This function is part of the Swift standard library
    func map<U>(_ transform: (Wrapped) -> U) -> U? {
        guard let x = self else { return nil }
        return transform(x)
    }
}
//: Now, we can rewrite `increment(optional:)` using the `map` function we just defined
func incrementWithOptionalMap(optional: Int?) -> Int? {
    return optional.map { $0 + 1 }
}

//: ## Optional Binding Revisited
//:
//: While our `map` function above shows us one way to manipulate optional values, there are still many more methods and techniques.
//:
//: Lets take the following as an example:
let x: Int? = 3
let y: Int? = 3
//let z: Int? = x + y // error 🔥 -> `+` only works on `Int`, not `Int?`
//: As a naive example of adding support to `Int?` for the `+` operator, we could do the following:
func add_V1(_ optionalX: Int?, _ optionalY: Int?) -> Int? {
    if let x = optionalX {
        if let y = optionalY {
            return x + y
        }
    }
    return nil
}

func add_V2(_ optionalX: Int?, _ optionalY: Int?) -> Int? {
    if let x = optionalX, let y = optionalY {
        return x + y
    }
    return nil
}

func add_V3(_ optionalX: Int?, _ optionalY: Int?) -> Int? {
    guard let x = optionalX, let y = optionalY else { return nil }
    return x + y
}

//: Manipulating optional values is fairly common practice. Consider an example where we have a dictionary which associates a city with its capital.
let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam",
    "Belgium": "Brussels",
]
//: Now lets combine that with our prior example to optionally return the number of inhabitants for the capital of a given country
func populationOfCapital(country: String) -> Int? {
    guard
        let capital = capitals[country],
        let population = cities[capital]
    else { return nil }
    return population * 1000
}
//: While this works using `guard let`, Swift's standard library gives us another way to solve this problem => `flatMap`.
//:
//: `flatMap` is defined on multiple types, and for optionals, it looks like the following:
extension Optional {
    /// Perform a transform on the `Optional` if the `wrappedValue` is non-nil
    func flatMap<U>(_ transform: (Wrapped) -> U?) -> U? {
        guard let x = self else { return nil }
        return transform(x)
    }
}
//: We can now write our prior examples in terms of `flatMap` as follows:
func add_V4(_ optionalX: Int?, _ optionalY: Int?) -> Int? {
    return optionalX.flatMap { x in
        optionalY.flatMap { y in
            return x + y
        }
    }
}

func populationOfCapital2(country: String) -> Int? {
    return capitals[country].flatMap { capital in
        cities[capital].flatMap { population in
            population * 1000
        }
    }
}

//: Instead of nesting flatMap calls, we can also rewrite `populationOfCapital2` to make the code more shallow by chaining the calls
func populationOfCapital3(country: String) -> Int? {
    return capitals[country]
        .flatMap { capital in cities[capital] }
        .flatMap { population in population * 1000 }
}

//: The goal of this module isn't to argue that `flatMap` is the "right way" to combine optional values. Instead, the goal was to show that optional binding isn't magically built into the Swift compiler, and as a control structure, it an be implemented by us using higher-order functions

//: [Previous](@previous)        [Next](@next)
