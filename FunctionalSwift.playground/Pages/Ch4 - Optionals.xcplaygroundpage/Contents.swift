import Foundation

//: # Ch 4: Optionals
//:
//: Swift's optional types can be used to represent values that may be nil or computations that may fail. This module will cover how to work with optional types effectively and how they fit well within the FP paradigm
//:
//: Seeing as the focus of these notes are to learn FP, I'll be skipping the basics of Swift optionals, `if let` unwraps and the like
//:
//: As a fun and interesting exercise, however, we can document Swift's nil-coalescing operator `??`
infix operator ??

func ??<T>(optional: T?, defaultValue: T) -> T {
    if let x = optional {
        return x
    } else {
        return defaultValue
    }
}


//: [Previous](@previous)        [Next](@next)
