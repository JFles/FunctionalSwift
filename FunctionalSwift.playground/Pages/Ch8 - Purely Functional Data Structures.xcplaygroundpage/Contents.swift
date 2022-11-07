import Foundation

//: # Ch 8: Purely Functional Data Structures
//:
//: In the prior chapter, we showed how enumerations can be used to define specific types for the applications we develop. For this chapter, we'll define recursive enumerations and show how they can be used to define data structures that are both efficient and persistent

//: ## Binary Search Trees
//:
//: For this example, we'll build a limited `Set` type to demonstrate how recursive enumerations can be used to define efficient data structures.
//:
//: For our library, we'll focus on three set operations:
//: 1. `isEmpty` - check if set is empty
//: 2. `contains` - checks if provided element is w/i the set
//: 3. `insert` - adds an element to an existing set
//:
//: As a first attempt, we can use arrays to represent sets.
struct MySet<Element: Equatable> {
    var storage = [Element]()
    
    var isEmpty: Bool {
        return storage.isEmpty
    }
    
    func contains(_ element: Element) -> Bool {
        return storage.contains(element)
    }
    
    /// Non-mutating element insertion into set.
    func insert(_ x: Element) -> MySet {
        return contains(x) ? self : MySet(storage: storage + [x])
    }
}
//: While simple, the drawback with this implementation is that many of the operations will perform linearly for the size of the set. This may cause performance problems with larger sets.
//:
//: There are several ways we can address the performance bottleneck and improve beyond `O(n)`. For this module, we'll define a `binary search tree` to represent our sets, and we'll define our trees directly as an enumeration in Swift using the `indirect` keyword.
indirect enum BinarySearchTree<Element: Comparable> {
    case leaf
    case node(
        BinarySearchTree<Element>,
        Element,
        BinarySearchTree<Element>
    )
}
//: This definition states that each tree is either a `leaf` with no associated values or a `node` with a left subtree, a value stored on the node, and a right subtree.
//:
//: Lets define two small example trees below
let leaf: BinarySearchTree<Int> = .leaf
let five: BinarySearchTree<Int> = .node(.leaf, 5, .leaf)
//: We can generalize these constructions with two initializers: one that builds an empty tree and one that builds a tree with a single value
extension BinarySearchTree {
    init() {
        self = .leaf
    }
    
    init(_ value: Element) {
        self = .node(.leaf, value, .leaf)
    }
}
//: As seen in the prior chapter, we can write functions that manipulate these trees with switch statements. Since our `BinarySearchTree` enum is recursive, most of our functions on it will be recursive as well.
//:
//: For example, we can define a function which counts the total number of elements stored in a tree
extension BinarySearchTree {
    var count: Int {
        switch self {
        case .leaf:
            return 0
        case let .node(left, _, right):
            return 1 + left.count + right.count
        }
    }
}
//: And similarly, we can write an `elements` property which computes the array of elements stored in the tree
extension BinarySearchTree {
    var elements: [Element] {
        switch self {
        case .leaf:
            return []
        case let .node(left, x, right):
            return left.elements + [x] + right.elements
        }
    }
}







//: [Previous](@previous)         [Next](@next)
