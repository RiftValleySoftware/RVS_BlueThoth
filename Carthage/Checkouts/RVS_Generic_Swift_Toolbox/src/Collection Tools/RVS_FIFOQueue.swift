/**
© Copyright 2019-2020, The Great Rift Valley Software Company

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
Version: 1.1.0
*/

import Foundation

/* ###################################################################################################################################### */
// MARK: - Queue Protocol -
/* ###################################################################################################################################### */
/**
 This was taken straight from the objc.io book "Advanced Swift." It's so damn useful, that I have it made into a standard tool.
 
 The original design was done by [Ole Begemann](https://oleb.net) and [Chris Eidhof](https://chris.eidhof.nl). I have modified it slightly; but not much.
 
 It is fast as all git-go.

 A type that can efficiently "enqueue" and "dequeue" elements. It works on one element at a time. You cannot dequeue groups of elements.
 */
public protocol OLEB_Queue {
    /* ################################################################## */
    /**
     Defines the type for the Elements
     */
    associatedtype Element
    
    /* ################################################################## */
    /**
     This will push the single element into the 0th (first) place.
     */
    mutating func cutTheLine(_ : Element)
    
    /* ################################################################## */
    /**
     Adds a new Element to the end (back) of the queue
     */
    mutating func enqueue(_ : Element)

    /* ################################################################## */
    /**
     Adds a new Array of Element to the end (back) of the queue
     */
    mutating func enqueue(_ : [Element])

    /* ################################################################## */
    /**
     Removes and returns the first element from the beginning (front) of the queue. nil, if the queue is empty.
     */
    mutating func dequeue() -> Element?
    
    /* ################################################################## */
    /**
     Deletes all data in the queue.
     */
    mutating func removeAll()
}

/* ###################################################################################################################################### */
// MARK: - RVS_FIFOQueue Struct -
/* ###################################################################################################################################### */
/**
 An efficient variable-size FIFO queue of elements of type "Element."
 */
public struct RVS_FIFOQueue<Element>: OLEB_Queue {
    /// This is the "delivery" queue. Elements are removed, one by one, from the top of this queue.
    /// When the queue is empty, and a request is made for an element, it first asks for the reveresed contents of the right queue, which is then emptied.
    private var _leftQueue: [Element] = []
    /// This is the "staging queue." We add elements, one by one, to the top of this queue.
    private var _rightQueue: [Element] = []
    
    /* ################################################################## */
    /**
     This will push the single element into the 0th (first) place.
     - parameter inNewElement: The Element to be enqueued (placed on the front of the list).
     - Complexity: O(1).
     */
    mutating public func cutTheLine(_ inNewElement: Element) {
        #if DEBUG
            print("Adding to the front of the queue: \(String(describing: inNewElement))")
        #endif
        
        _leftQueue.append(inNewElement)
    }

    /* ################################################################## */
    /**
     Add an Element to the end of the queue.
     - parameter inNewElement: The Element to be enqueued (placed on the end of the list).
     - Complexity: O(1).
     */
    mutating public func enqueue(_ inNewElement: Element) {
        #if DEBUG
            print("Enqueuing: \(String(describing: inNewElement))")
        #endif
        
        _rightQueue.append(inNewElement)
    }
    
    /* ################################################################## */
    /**
     Add an Array of Element to the end of the queue.
     - parameter inNewElements: The Elements to be enqueued (placed on the end of the list). They are appened in the order presented.
     - Complexity: O(n), where n is the number of elements in the input Array.
     */
    mutating public func enqueue(_ inNewElements: [Element]) {
        #if DEBUG
            print("Enqueuing: \(String(describing: inNewElements))")
        #endif
        
        _rightQueue.append(contentsOf: inNewElements)
    }

    /* ################################################################## */
    /**
     Removes and returns from the front of the queue.
     Returns nil for an empty queue.
     - returns: The first Element. Nil, if none. Can be ignored.
     - Complexity: Amortized O(1).
     The "Amortized" is because there's a one-time "charge" for dumping the right queue into the left queue.
     The way that this works, is that the right queue is a "staging" queue. It's cheap to shove elements onto the top.
     We remove elements from the top of the left queue, so there's no moving of memory.
     When the left queue is empty, we dump the entire right (staging) queue into it, as reversed.
     The idea is to keep all the operations on the tops of the queues. That prevents massive memory movements every time we access the bottom.
     */
    @discardableResult
    mutating public func dequeue() -> Element? {
        if _leftQueue.isEmpty { // If we are empty, then we simply dump the right queue into the left queue, all at once, as reversed.
            _leftQueue = _rightQueue.reversed()
            _rightQueue.removeAll()
        }
        
        #if DEBUG
            print("Dequeuing: \(String(describing: _leftQueue.last))")
        #endif
        
        return _leftQueue.popLast() // Since we are popping off the top, the cost is negligible.
    }
    
    /* ################################################################## */
    /**
     Deletes all data in the queue.
     
     - Complexity: O(1).
     */
    mutating public func removeAll() {
        #if DEBUG
            print("Clearing the Decks. Removing \(count) items.")
        #endif
        
        _leftQueue.removeAll()
        _rightQueue.removeAll()
    }
}

/* ###################################################################################################################################### */
// MARK: - ExpressibleByArrayLiteral Support -
/* ###################################################################################################################################### */
/**
 We add the initializer with a variadic parameter list of type "Element."
 */
extension RVS_FIFOQueue: ExpressibleByArrayLiteral {
    /* ################################################################## */
    /**
     Variadic initializer.
     */
    public init(arrayLiteral inElements: Element...) {
        _leftQueue = inElements.reversed()
        _rightQueue = []
    }
}

/* ###################################################################################################################################### */
// MARK: - MutableCollection Support -
/* ###################################################################################################################################### */
extension RVS_FIFOQueue: MutableCollection {
    /* ################################################################## */
    /**
     - returns: 0. The start is always 0.
     */
    public var startIndex: Int { 0 }

    /* ################################################################## */
    /**
     - returns: The length of both internal queues, combined.
     */
    public var endIndex: Int { _leftQueue.count + _rightQueue.count }
    
    /* ################################################################## */
    /**
     - parameter after: The index we want to get after.
     
     - returns: The input plus one (Can't get simpler than that). It can return the endIndex, which is past the last element.
     */
    public func index(after inIndex: Int) -> Int {
        precondition((0..<endIndex).contains(inIndex), "Index out of bounds")
        return inIndex + 1
    }
    
    /* ################################################################## */
    /**
     - parameter inPosition: The position of the element we are working on.
     
     - returns: The element we are subscripting.
     */
    public subscript(_ inPosition: Int) -> Element {
        get {
            precondition((0..<endIndex).contains(inPosition), "Index out of bounds")
            // See which queue the element is in.
            if inPosition < _leftQueue.endIndex {
                return _leftQueue[_leftQueue.count - inPosition - 1]
            } else {
                return _rightQueue[inPosition - _leftQueue.count]
            }
        }
        
        set {
            precondition((0..<endIndex).contains(inPosition), "Index out of bounds")
            if inPosition < _leftQueue.endIndex {
                return _leftQueue[_leftQueue.count - inPosition - 1] = newValue
            } else {
                return _rightQueue[inPosition - _leftQueue.count] = newValue
            }
        }
    }
}
