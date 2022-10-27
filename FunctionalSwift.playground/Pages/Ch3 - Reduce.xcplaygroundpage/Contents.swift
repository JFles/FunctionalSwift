import Foundation

//: # Reduce
//:
//: Lets say we want to define a function that sums all integers in an array. V straightforward! :>
func sum(integers: [Int]) -> Int {
    var result = 0
    for x in integers {
        result += x
    }
    return result
}

let ints = [1, 2, 3, 4]

sum(integers: ints)

//: Similarly, we could define a function that computes the product of all integers in an array
func product(integers: [Int]) -> Int {
    var result = 1
    for x in integers {
        result = x * result
    }
    return result
}

product(integers: ints)

//: In yet another similar vein, lets say we want to concatenate all strings in an array!

func concatenate(strings: [String]) -> String {
    var result = ""
    for string in strings {
        result += string
    }
    return result
}

//: How about if we wanted to concat all the strings in an array, BUT we also wanted to insert a separate header AND newline character after every element?? 👀
func prettyPrint(strings: [String]) -> String {
    var result = "~=~=~=~=~=~=~=~=~=~=~=~=\n"
    for string in strings {
        result = " " + result + string + "\n"
    }
    return result
}

let exampleStrings = ["Pizza", "Pie", "Apples", "Brotein"]

print(prettyPrint(strings: exampleStrings))


//: We can make a generic `reduce` function by abstracting over the initial value assigned to the `result` variable and the function used to update `result` for each iteration

extension Array {
    func reduce<T>(
        _ initial: T,
        combine: (T, Element) -> T
    ) -> T {
        var result = initial
        for x in self {
            result = combine(result, x)
        }
        return result
    }
}

//: Additionally, we can define every function we've seen thus far in Ch3 using `reduce` 🤯

func sumUsingReduce(integers: [Int]) -> [Int] {
    return integers.reduce(0) { result, x in result + x }
}

//: The trailing closure is a bit strange to read still, but we can make this code even shorter by just passing the operator as the last argument!

func productUsingReduce(integers: [Int]) -> [Int] {
    return integers.reduce(1, combine: *)
}

func concatUsingReduce(strings: [String]) -> String {
    return strings.reduce("", combine: +)
}

//: Now, lets say we have an array of arrays and we want to flatten it into a single array. We could achieve this with a `for` loop such as:
func flatten<T>(_ xss: [[T]]) -> T {
    
}







//: [Previous](@previous)      [Next](@next)
