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
protocol Arbitrary {
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
    static func arbitrary() -> Double {
        return Double.random(in: -10_000...10_000)
    }
}

extension CGSize: Arbitrary {
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

//: [Previous](@previous)         [Next](@next)
