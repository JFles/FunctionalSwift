import Foundation

//: # Ch 5 - Case Study: QuickCheck
//:
//: In this module, we'll build a small library for property-based testing of Swift functions. It will be built iteratively, and we'll improve it step-by-step.
//:
//: `QuickCheck` is a Haskell library for random testing. Instead of writing individual unit tests to test whether a function is correct for a given input, `QuickCheck` allows you to describe **abstract** properties of your functions and **generate** tests to verify said properties.
//:
//: When a property passes, it doesn't prove that the property is correct. Instead, `QuickCheck` aims to find boundary conditions that invalidate the property.
//:
//: To illustrate this, the following example should suffice. Suppose we want to verify that addition is a commutative operation (i.e. `x + y` == `y + x` where `x` and `y` are Integers)
func plusIsCommutative(x: Int, y: Int) -> Bool {
    return (x + y) == (y + x)
}
//: And calling this test in `QuickCheck` is straight-forward
func check<T>(_ testName: String, _ testClosure: (T) -> Bool) { print("Implement me!") }
check("Plus should be commutative", plusIsCommutative)
// "Plus should be commutative" passed 10 tests.

//: Also, the tests can be implemented as a trailing closure to `check` directly such as:
check("Additive identity") { (x: Int) in x + 0 == x }
// "Additive identity" passed 10 tests.

//: ## Building QuickCheck
//:
//: In order to bulid our Swift implementation of QuickCheck, we'll need to do a few things
//: - First, we need a way to generate random values for different types
//: - Using the random value generators, we need to implement the `check` function which passes random values to its argument property
//: - If a test fails, we'd like to make the test input as small as possible. (e.g. If a test fails on an array of 100 elements, try to reduce the array size and check if the test still fails)
//: - Finally, we'll have to make sure our `check` function works on types that have generics
//:
//: ### Generating Random Values
//: First, let's define a protocol that knows how to generate arbitrary values. The `Arbitrary` protocol only contains one function, `arbitrary()` which returns `Self` (i.e. an instance of the class or struct that implements the `Arbitrary` protocol
protocol Arbitrary_v1 {
    static func arbitrary() -> Self
}
//: The first type we can add support to return Arbitrary values from is `Int`. We'll constrain ourselves to an artificially small range to prevent integer overflows and have more readable output
extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int.random(in: -10_000...10_000)
    }
}
//: Now, we can generate random integers with ease!
Int.arbitrary()
//: To generate random strings, we need to do a bit more work! To begin, we generate random Unicode scalars. Note that we'll only generate a small subset of Unicode as random characters to preserve readability for these examples
extension UnicodeScalar: Arbitrary {
    func smaller() -> Unicode.Scalar? {
        // TODO: Can this be shrunk?
        return nil
    }
    
    static func arbitrary() -> UnicodeScalar {
        return UnicodeScalar(Int.random(in: 48..<122))!
    }
}
//: Next, we generate a random length between 0 and 40, then we generate random scalars of matching length and turn them into a string. Note: In a prod library, we should generate both longer strings and strings that contain arbitrary characters
extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = Int.random(in: 0..<40)
        let randomScalars = (0..<randomLength).map { _ in
            UnicodeScalar.arbitrary()
        }
        return String(UnicodeScalarView(randomScalars))
    }
}
//: And now we can generate random Strings as well!
String.arbitrary()
//: ### Implementing the `check` Function
//:
//: Here's the first version of our `check` function!
func check1<A: Arbitrary>(_ message: String, _ property: (A) -> Bool) {
    let numberOfIterations = 10
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            return print("\"\(message)\" doesn't hold:\(value)")
        }
    }
    print("\"\(message)\" passed \(numberOfIterations) tests.")
}
//: And here's how we can use this function to test properties
extension CGSize {
    var area: CGFloat {
        return width * height
    }
}

extension Double: Arbitrary {
    func smaller() -> Double? {
        return self == 0 ? nil : self / 2
    }
    
    static func arbitrary() -> Double {
        return Double.random(in: -10_000...10_000)
    }
}

extension CGSize: Arbitrary {
    func smaller() -> CGSize? {
        // TODO: How do we want to shrink a `CGSize` object?
        return nil
    }
    
    static func arbitrary() -> CGSize {
        return CGSize(width: .arbitrary(), height: .arbitrary())
    }
}

check1("Area should be at least 0") { (size: CGSize) in size.area >= 0 }

//: ## Making Values Smaller
//:
//: Ideally, we would like our failing input to be as short as possible. In general, the smaller the counterexample for the failed case, the easier it is to spot the code which caused the failure.
//:
//: To accomplish this, we'll start with a protocl `Smaller` whose only responsibility is to shrink the failure message in the counterexample
protocol Smaller {
    func smaller() -> Self?
}
//: We're using an optional `Self?` return type as there are cases where it isn't clear how to shrink the test data any further. For example, there's no way to shrink an empty array, so we'd return `nil` in this instance
//:
//: For Int, we can try to divide the integer and return `nil` if we reach zero
extension Int: Smaller {
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}

100.smaller()

extension String: Smaller {
    func smaller() -> String? {
        return isEmpty ? nil : String(dropFirst())
    }
}

"Hello".smaller()

//: To use the `Smaller` protocol in the `check` function, we'll need the ability to shrink any test data generated by our `check` function. We can use Protocol composition here and extend the `Arbitrary` protocol with our `Smaller` protocol
protocol Arbitrary: Smaller {
    static func arbitrary() -> Self
}

//: ### Repeatedly Shrinking
//:
//: We can now redefine our `check` function to shrink any test data that triggers a failure. We'll define a function that takes an initial value and will be repeatedly applied as long as the condition holds. Note that this is defined recursively, but it could also be implemented using a while loop.
func iterate<A>(
    while condition: (A) -> Bool,
    initial: A,
    next: (A) -> A?
) -> A {
    guard let x = next(initial), condition(x) else { return initial }
    return iterate(while: condition, initial: x, next: next)
}

//: We can use `iterate(while:initial:next:)` to now recursively shrink our counterexamples from failures with `check` whhich are uncovered during testing
func check2<A: Arbitrary>(_ message: String, _ property: (A) -> Bool) -> () {
    let numberOfIterations = 10
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        guard property(value) else {
            // Shrink down the counterexample to make the output more manageable
            let smallerValue = iterate(
                while: { !property($0) },
                initial: value,
                next: { $0.smaller() }
            )
            return print("\"\(message)\" doesn't hold:\(smallerValue)")
        }
    }
    print("\"\(message)\" passed \(numberOfIterations) tests.")
}

//: ### Arbitrary Arrays
//:
//: Currently, `check2` only supports Int and String values. Extending it to other types such as Bool isn't hard, but things become significantly more complex when we want to generate arbitrary arrays. As a motivating example, we'll write a functional version of QuickSort
extension Array where Element: Comparable {
    func qsort() -> [Element] {
        guard !isEmpty else { return [] }
        var array = self
        let pivot = array.removeFirst()
        let lesser = array.filter { $0 < pivot }
        let greater = array.filter { $0 >= pivot }
        return lesser.qsort() + [pivot] + greater.qsort()
    }
}
//: We can also try to write a property to check our version of QuickSort against the built-in sort function
check2("qsort should behave like sort") { (x: [Int]) in
    return x.qsort() == x.sorted()
}
//: The compiler warns us that `[Int]` must conform to `Arbitrary` first, and before we can implement `Arbitrary`, we'll need to implement `Smaller`. We can define `Smaller` for arrays to drop the last element of the array
extension Array: Smaller {
    func smaller() -> [Element]? {
        guard !isEmpty else { return nil }
        return Array(dropLast())
    }
}

extension Array: Arbitrary where Element: Arbitrary {
    static func arbitrary() -> [Element] {
        let randomLength = Int.random(in: 0..<50)
        return (0..<randomLength).map { _ in .arbitrary() }
    }
}

//: ### Arbitrary Tuples
//:
//: For most generic types such as arrays and dictionaries, we can add conditional conformance to the `Arbitrary` protocol; however, it is currently not possible to conform tuple types to protocols.
//:
//: Let's consider our earlier example
func plusIsCommutative2(x: Int, y: Int) -> Bool {
    return x + y == y + x
}
//: The type of `plusIsCommutative` is `(Int, Int) -> Bool`. If we try to pass it to `check2`, the compiler will tell us that it must conform to `Arbitrary`. Again, this is currently impossible with tuple types. In order to accomodate this limitation, we can change the signature of `check` to allow us to pass in the `smaller` and `arbitrary` functions as arguments
//:
//: To start, we can define an auxillary struct which contains the two functions we need
struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}
//: We can now write a helper function that takes an `ArbitraryInstance` struct as an argument. The definition of `checkHelper` is very similar to our earlier `check2` function. The major change here are with how `arbitrary` and `smaller` are defined. While `check2` had these defined using a constraint on a generic type `<A: Arbitrary>`, `checkHelper` passes them explicitly in the `ArbitraryInstance` struct
func checkHelper<A>(
    _ arbitraryInstance: ArbitraryInstance<A>,
    _ property: (A) -> Bool,
    _ message: String
) -> () {
    let numberOfIterations = 10
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        guard property(value) else {
            let smallerValue = iterate(
                while: { !property($0) },
                initial: value,
                next: arbitraryInstance.smaller
            )
            return print("\"\(message)\" doesn't hold \(smallerValue)")
        }
    }
    return print("\"\(message)\" passed \(numberOfIterations) tests.")
}
//: This is a standard technique. Instead of working with functions defined in protocols, we explicitly pass the information as an argument. This allows us to have more flexibility instead of being bound and limited to Swift's type inference behavior
//:
//: And now we can redefine our `check2` function to use the `checkHelper` function
func check<X: Arbitrary>(
    _ message: String,
    property: (X) -> Bool
) -> () {
    let instance = ArbitraryInstance(
        arbitrary: X.arbitrary,
        smaller: { $0.smaller() }
    )
    checkHelper(instance, property, message)
}
//: If we have a type where we can's define the desired `Arbitrary` instance, such as with tuples, we can overload the `check` function and construct the desired `ArbitraryInstance` struct ourselves
func check<X: Arbitrary, Y: Arbitrary>(
    _ message: String,
    _ property: (X, Y) -> Bool
) -> () {
    let arbitraryTuple = { (X.arbitrary(), Y.arbitrary()) }
    let smaller: (X, Y) -> (X, Y)? = { (x, y) in
        guard let newX = x.smaller(), let newY = y.smaller() else { return nil }
        return (newX, newY)
    }
    let instance = ArbitraryInstance(arbitrary: arbitraryTuple, smaller: smaller)
    checkHelper(instance, property, message)
}
// Now, we can finally verify our commutative property with random tuples being passed to our test
check("Plus should be commutative", plusIsCommutative)



//: [Previous](@previous)         [Next](@next)
