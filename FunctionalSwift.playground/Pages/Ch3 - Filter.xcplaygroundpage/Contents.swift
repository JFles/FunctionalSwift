import Foundation

//: ## Filter
//:
//: `Filter` is a general purpose function that, like `map`, also takes a function as an argument. The function it accepts is `(Element) -> Bool`. For every element of the array, the function will determine whether it should be included in the result
extension Array {
    func filter(_ includeElement: (Element) -> Bool) -> [Element] {
        var result = [Element]()
        for x in self where includeElement(x) {
            result.append(x)
        }
        return result
    }
}

//: As an example, we could leverage `filter(:)` to get all `.swift` files in an array!
let exampleFiles = ["README.md", "HelloWorld.swift", "FlappyBird.swift"]

func getSwiftFiles(in files: [String]) -> [String] {
    return files.filter { file in file.hasSuffix(".swift") }
}

getSwiftFiles(in: exampleFiles)

//: [Previous](@previous)       [Next](@next)
