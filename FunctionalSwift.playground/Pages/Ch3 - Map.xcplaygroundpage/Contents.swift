import Foundation
//: # Ch. 3: Map, Filter, Reduce
//:
//: ## Map
//: Functions that take functions as arguments are usually referred to as `higher-order functions`. Swift defines a few of these in its standard library.
//:
//: As an imperative example that may be more familiar, we could write a solution to needing to increment each element of an array or doubling all its values with a `for` loop:
/// Imperative solution to increment each Integer element of a provided array
func increment(array: [Int]) -> [Int] {
    var result = [Int]()
    for x in array {
        result.append(x + 1)
    }
    return result
}

/// Imperative solution for doubling each Integer element of a provided array
func double(array: [Int]) -> [Int] {
    var result = [Int]()
    for x in array {
        result.append(x * 2)
    }
    return result
}
//: Both of the imperative solutions above share a lot of code and are very single use. Can we abstract over the differences anf write a single, more general function that captures this pattern?
//:
//: We would need to pass a function to our general function for the operation we expect to occur
/// Transform the given array of Integers with the provided closure
func compute(
    array: [Int],
    transform: (Int) -> Int
) -> [Int] {
    var result = [Int]()
    for x in array {
        result.append(transform(x))
    }
    return result
}

/// Doubles the provided Int array using `compute(array:transform)`
func double2(array: [Int]) -> [Int] {
    return compute(array: array) { element in element * 2 }
}

//: This code is still not very flexible. For example, if we needed to compute an array of bools which describes if each element of an input array of ints was even or not, we couldn't use our existing `compute(array:transform:)` as the `transform` and return type are currently `Int` and `[Int]` respectively but would need to be `Bool` and `[Bool]` for this case
//:
//: We could solve this with a new overload of `compute(array:transform)` that takes an `(Int) -> Bool` transform, but this doesn't scale well

/// Naive overload of `compute(array:transform)` to handle a separate type signature
func compute(
    array: [Int],
    transform: (Int) -> Bool
) -> [Bool] {
    var result = [Bool]()
    for x in array {
        result.append(transform(x))
    }
    return result
}

//: Because the only difference between the `compute(array:transform:)` function overloads are their type signature, we can use [Generics](https://docs.swift.org/swift-book/LanguageGuide/Generics.html) to solve the scalability problem!
/// Generic `compute(array:transform` which takes an [Int] and a transform of
/// `(Int) -> T` and returns `[T]` where `T` is a generic type parameter
/// specified by the calling function
func genericCompute<T>(
    array: [Int],
    transform: (Int) -> T
) -> [T] {
    var result = [T]()
    for x in array {
        result.append(transform(x))
    }
    return result
}

//: To take this further, there is no reason why we should limit our input to `[Int]`, and we can solve this by adding another generic type parameter such as our `map(_:transform:)` below

/// Generic map that takes an array of any type and a transform with a potentially
/// separate return type inferred by the passed in transform function
func map<Element, T>(
    _ array: [Element],
    transform: (Element) -> T
) -> [T] {
    var result = [T]()
    for x in array {
        result.append(transform(x))
    }
    return result
}

//: We can even define our prior `genericCompute(array:transform:)` function in terms of `map`!
/// Transforming [Int] into [T]. Redefined with our `map<Element, T>` function
func genericCompute2<T>(
    _ array: [Int],
    transform: (Int) -> T
) -> [T] {
    return map(array, transform: transform)
}

//: In order to fit more with Swift's style, we can define `map` as an extension of `Array`
extension Array {
    func map<T>(transform: (Element) -> T) -> [T] {
        var result = [T]()
        for x in self {
            result.append(transform(x))
        }
        return result
    }
}

//: Now we can call `array.map(transform:)` or `array.map { ... }`!
func genericCompute3<T>(array: [Int], transform: (Int) -> T) -> [T] {
    return array.map(transform)
}




//: [Previous](@previous)      [Next](@next)
