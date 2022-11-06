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
//: Recalling a past example in Chapter 5, we created a function called `populationOfCapital` which looked up a country's capital, and if it's found, return the capital's population. The result type is `Int?`, and the function returns the population if everything is found, otherwise nil
//:
//: One issue here with Swift's optional type is that we don't return an error message when it fails. This leaves us with no way to diagnose what went wrong. Does the country not exist in our dictionary? Is there no population defined for the capital?
//:
//: The more meaningful and expressive route would be to return either an `Int` or an `Error`. Luckily, we can accomplish that with Swift Enumerations!
//:
//: For our `populationOfCapital` function, instead of returning `Int?`, we can redfine our function to return a case of the `PopulationResult` enum.
enum LookupError: Error {
    case capitalNotFound
    case populationNotFound
}

enum PopulationResult {
    case success(Int)
    case failure(LookupError)
}
//: Both of these leverage associated values to return the population as an `Int` for success and a `LookupError` in the case of failure
//:
//: Below is our rewrite of `populationOfCapital` which returns a `PopulationResult`. This allows us to explicitly define both our error cases and success for the function.
let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam",
    "Belgium": "Brussels",
]
let cities = [
    "Paris": 2241,
    "Madrid": 3165,
    "Amsterdam": 827,
    "Berlin": 3562
]

func populationOfCapital(country: String) -> PopulationResult {
    guard let capital = capitals[country] else {
        return .failure(.capitalNotFound)
    }
    guard let population = cities[capital] else {
        return .failure(.populationNotFound)
    }
    return .success(population)
}
//: Callers of this function can use a switch statement to determine whether or not the function succeeded
switch populationOfCapital(country: "France") {
case let .success(population):
    print("France's capital has a population of \(population) thousand inhabitants.")
case let .failure(error):
    print("Error: \(error)")
}

//: ## Adding Generics
//:
//: Let's say we want to write a similar function to `populationOfCapital` except we want to look up the mayor of a country's capital
let mayors = [
    "Paris": "Hidalgo",
    "Madrid": "Martinez",
    "Amsterdam": "Halsema",
    "Berlin": "Muller"
]
//: We could solve this with flatMaps as we did previously in Ch 4
func mayorOfCapital(country: String) -> String? {
    return capitals[country]
        .flatMap { capital in mayors[capital] }
}
//: But now we've run into the same issue that our optional return type doesn't tell us why the lookup failed.
//:
//: A similar enum to `PopulationResult` would be a good choice here
enum MayorResult {
    case success(string)
    case failure(Error)
}
//: But we should see now that the key differences in these enums are the associated values, so we can make a generic `Result` type to cover both enums and future related enums
enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}
//: And now we can use our generic `Result` type for both of our functions!
func populationOfCapital(country: String) -> Result<Int, LookupError> { }
func mayorOfCapital(country: String) -> Result<String, Error> { }

//: ## Swift Errors
//:
//: Swift's built-in error handling is similar to our Result type above. It differs syntactically and semantically, though.
//:
//: Syntactically, we define Swift's built-in error with `throws` for the return type, and we must mark calling code with `try`, `try!` or `try?`
//:
//: Semantically, the `Result` type is generic over a second error type, so we can be more specific such as with `LookupError`. Swift's built-in error handling is not as precise and only guarantees that an error conforms to the `Error` protocol.
//:
//: Below is a rewrite of our `populationOfCapital` function using Swift's errors
func populationOfCapital(country: String) throws -> Int {
    guard let capital = capitals[country] else {
        throw LookupError.capitalNotFound
    }
    guard let population = cities[capital] else {
        throw LookupError.populationNotFound
    }
    return population
}
//: And to call our function, we can wrap it in a `do-catch` block with a `try` prefix
do {
    let population = populationOfCapital(country: "France")
    print("France's population is \(population)")
} catch {
    print("Lookup error: \(error)") // 😟 We don't know the exact Error type here -- unlike `Result<T, E>`
}





//: [Previous](@previous)        [Next](@next)
