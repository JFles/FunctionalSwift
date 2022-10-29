import Foundation

//: # Ch 4: Optionals
//:
//: Swift's optional types can be used to represent values that may be nil or computations that may fail. This module will cover how to work with optional types effectively and how they fit well within the FP paradigm
//:
//: Seeing as the focus of these notes are to learn FP, I'll be skipping the basics of Swift optionals, `if let` unwraps and the like
//:
//: As a fun and interesting exercise, however, we can a rough approximation of Swift's nil-coalescing operator `??`
infix operator ????

func ????<T>(optional: T?, defaultValue: T) -> T {
    if let x = optional {
        return x
    } else {
        return defaultValue
    }
}

//: The problem with this definition is that `defaultValue` will be evaluated whether or not the optional is nil. The behavior we want is for the `??` operator to only evaluate the `defaultValue` operator when the optional argument is `nil`
//:
//: As an example, suppose we were to call `??` as follows:

let cache = ["test.swift": 1000]
let defaultValue = 2000 // Read from disk
cache["hello.swift"] ???? defaultValue

//: In this example, we ONLY want to evaluate `defaultValue` if the optional value is `nil` -- especially if it's an expensive computation that we only want to run when absolutely necessary.
//:
//: Thankfully, we can fix this by making the defaultValue lazy evaluate a function instead of a primitive value
infix operator ???

func ???<T>(optional: T?, defaultValue: () -> T) -> T {
    if let x = optional {
        return x
    } else {
        return defaultValue()
    }
}

//: The drawback to setting the `defaultValue` to a function is that we'd now need to compromise the ergonomics of our code for potential performance savings
// V1
let myOptional: String? = nil
let myDefaultValue: String = "Ahoy there matey!"

myOptional ??? { myDefaultValue } // 💩

// V2
let myOptional2: String? = nil
let myDefaultValue2: () -> String = { "Ahoy there matey!" } // 💩

myOptional2 ??? myDefaultValue2

//: In order to avoid creating an explicit closure, we can leverage Swift's [autoclosure type attribute](https://developer.apple.com/library/prerelease/mac/documentation/Swift/Conceptual/Swift_Programming_Language/Types.html).
//:
//: With this change, we can provide the same benefit of only evaluating the `defaultValue` if the optional is `nil` while also preserving ergonomics by not requiring user's to explicitly wrap the `defaultValue` in a closure
infix operator ??

func ??<T>(
    optional: T?,
    defaultValue: @autoclosure () throws -> T
) rethrows -> T {
    if let x = optional {
        return x
    } else {
        return try defaultValue()
    }
}

// V3 💆
let myOptional3: String? = nil
let myDefaultValue3 = "Ahoy there matey!"

myOptional3 ?? myDefaultValue3 // 🤝



//: [Previous](@previous)        [Next](@next)
