import Foundation
//: # Putting It All Together
//:
//: Lets go all in on a real world example using `map`, `filter`, and `reduce`!
//:
//: Suppose we have a struct containing a city's name and population (measured in thousands)
struct City {
    let name: String
    let population: Int // measured in the thousands
}
//: And a list of example cities
let paris = City(name: "Paris", population: 2241)
let madrid = City(name: "Madrid", population: 3165)
let amsterdam = City(name: "Amsterdam", population: 827)
let berlin = City(name: "Berlin", population: 3562)

let cities = [paris, madrid, amsterdam, berlin]

//: Now suppose we want to print a list of each city with a population of at least one million.
extension City {
    /// Scale population to its true approximate number
    func scalingPopulation() -> City {
        return City(
            name: self.name,
            population: self.population * 1000
        )
    }
}

let highPopCities = cities
    .filter { $0.population > 1000 }
    .map { $0.scalingPopulation() }
    .reduce("City: Population") { result, c in
        return result + "\n\(c.name): \(c.population)"
    }

print(highPopCities)



//: [Previous](@previous)       [Next](@next)
