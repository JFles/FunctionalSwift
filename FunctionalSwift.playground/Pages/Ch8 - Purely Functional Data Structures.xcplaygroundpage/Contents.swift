import Foundation

//: # Ch 8: Purely Functional Data Structures
//:
//: In the prior chapter, we showed how enumerations can be used to define specific types for the applications we develop. For this chapter, we'll define recursive enumerations and show how they can be used to define data structures that are both efficient and persistent
//:
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
/// A recursive Enumeration implementation of a Binary Search Tree
///
/// Reference: [Swift Enumeration Declaration](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#ID364)
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
//: Because the `count` and `elements` properties we've defined on our `BinarySearchTree` are very similar, we can define an abstraction sometimes known as a `fold` or `reduce`
extension BinarySearchTree {
    func reduce<A>(
        leaf leafF: A,
        node nodeF: (A, Element, A) -> A
    ) -> A {
        switch self {
        case .leaf:
            return leafF
        case let .node(left, x, right):
            return nodeF(
                left.reduce(leaf: leafF, node: nodeF),
                x,
                right.reduce(leaf: leafF, node: nodeF)
            )
        }
    }
}
//: This enables us to rewrite `elements` and `fold` with very little code
extension BinarySearchTree {
    var elementsR: [Element] {
        return reduce(leaf: []) { $0 + [$1] + $2 }
    }
    
    var countR: Int {
        return reduce(leaf: 0) { 1 + $0 + $2 }
    }
}
//: Now, lets return to our original goal of writing an efficient `set` library using trees. The case for `isEmpty` is very simple since we know that a BST is empty if it only contains a leaf and no nodes.
extension BinarySearchTree {
    var isEmpty: Bool {
        if case .leaf = self {
            return true
        }
        return false
    }
}
//: Since our example BST in this chapter is implemented in a way where we can construct an invalid tree, we can verify its validity through the following admittedly inefficient recursive check
extension BinarySearchTree {
    var isBST: Bool {
        switch self {
        case .leaf:
            return true
        case let .node(left, x, right):
            return left.elements.allSatisfy { y in y < x }
                && right.elements.allSatisfy { y in y > x }
                && left.isBST
                && right.isBST
        }
    }
}
//: The goal of BST is for efficint lookup operations where we only have to consider half of the tree after every evaluation. We can implement that roughly with the following extension.
extension BinarySearchTree {
    func contains(_ x: Element) -> Bool {
        switch self {
        case .leaf:
            return false
        case let .node(_, y, _) where x == y:
            return true
        case let .node(left, y, _) where x < y:
            return left.contains(x)
        case let .node(_, y, right) where x < y:
            return right.contains(x)
        default:
            fatalError("The impossible has happened")
        }
    }
}
//: And in a similar way, insertion searches through the BST recursively.
extension BinarySearchTree {
    mutating func insert(_ x: Element) {
        switch self {
        case .leaf:
            self = BinarySearchTree(x)
        case.node(var left, let y, var right):
            if x < y { left.insert(x) }
            if x > y { right.insert(x) }
            self = .node(left, y, right)
        }
    }
}





//: [Previous](@previous)         [Next](@next)
