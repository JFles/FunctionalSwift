import Foundation

//: # Generics vs. the Any Type
//:
//: On the surface, the `Any` type and generics seem similar in that they both can be used to define functions that can accept different types of arguments.
//:
//: It's important to acknowledge the differences, though. Generics can be used to generate type-safe functions that are still checked by the compiler whereas the `Any` type can be used to dodge the Swift Type system
//:
//: Lets consider the following example which is just a function that only returns its argument
func noOp<T>(_ x: T) -> T {
    return x
}

func noOpAny(_ x: Any) -> Any {
    return x
}

//: Both of these functions will accept any argument, but only the generic version using placeholder types will be checked at compile time.
//: If the danger of this is not immediately obvious, consider that the following type mismatch is valid code at compile time when using the `Any` type
func noOpAnyEgadsMan(_ x: Any) -> Any {
    return 0 // oh god why
}

//: Generics on the other hand would have prevented the above type mismatch and the compiler would have ensured that the input and output types matched per the function signature granting us safety at runtime.
//: If that wasn't enough pros for Generics and warnings for `Any`, consider that any function that calls `noOpAny` doesn't know what type the result must be cast as which could result in possible runtime exceptions being raised

//: [Previous](@previous)             [Next](@next)
