import Foundation

//: # Ch 7: Enumerations
//:
//: An overarching goal of this book is to emphasize the important role that types play in the design and implementation of Swift programs. One such data type we can leverage in Swift is Enumerations which allows us to create precise types to represent the data that our program uses.
//:
//: ## Introducing Enumerations
//:
//: When creating a string, it's important to know its character encoding. For example, consider the enumerations for an NSString object
//NS_ENUM(NSStringEncoding) {
//    NSASCIIStringEncoding = 1,
//    NSNEXTSTEPStringEncoding = 2,
//    NSJapaneseEUCStringEncoding = 3,
//    NSUTF8StringEncoding = 4
//    // ...
//}
//: In Objective-C and other C like languages, enumerations are limited to only assigning meaningful names to integer constants. One of the issues is that the type `NSStringEncoding` isn't precise enough as there are integer values which don't correspond to a valid encoding. Additionally, because the enumerated types are represented by integers, it's possible to compute them as numbers, which is nonsensical.
//:
//: Swift's own type system does not allow this which is more in line with one of the core tenets of FP in Swift - leveraging types effectively to rule out invalid programs.
//:
//: With Swift, we can declare an `enum` construct as such:
enum Encoding {
    case ascii
    case nextstep
    case japaneseEUC
    case utf8
}
//: We'll refer to the possible values of enumeration as `cases`, though a lot of literature calls such enumerations `sum types`
//:
//: In Swift, enumerations create new types which are distinct from integers or other existing types. We can define functions that calculate with encodings using `switch` statements.
//:
//: For example, we may want to compute the NSStringEncoding (imported in Swift as String.Encoding) corresponding to our own encoding enumeration
extension Encoding {
    var nsStringEncoding: String.Encoding {
        switch self {
        case .ascii: return String.Encoding.ascii
        case .nextstep: return String.Encoding.nextstep
        case .japaneseEUC: return String.Encoding.japaneseEUC
        case .utf8: return String.Encoding.utf8
        }
    }
}
//: This `nsStringEncoding` property maps each of the corresponding NSStringEncoding values to our enum cases. If we leave any of our enum cases out, the Swift compiler will warn us that our switch statement is not exhaustive. Very helpful!
//:
//: Additionally, we could create a function on our enum which works in the opposite direction by creating an `Encoding` from an `NSStringEncoding`. As we won't model all possible `NSStringEncoding` values, the initializer is failable.
extension Encoding {
    init?(encoding: String.Encoding) {
        switch encoding {
        case String.Encoding.ascii: self = .ascii
        case String.Encoding.nextstep: self = .nextstep
        case String.Encoding.japaneseEUC: self = .japaneseEUC
        case String.Encoding.utf8: self = .utf8
        default: return nil
        }
    }
}
//: We also don't need to use switch statements to work with our Encoding enum. Instead, we can leverage computed properties. As an example, lets say we want to return the localized name of an encoding, we could do something like the following
extension Encoding {
    var localizedName: String {
        return String.localizedName(of: nsStringEncoding)
    }
}

//: ## Associated Values
//:
//: 







//: [Previous](@previous)        [Next](@next)
