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
 
Version: 1.0.5
*/

/* ###################################################################################################################################### */
// MARK: - Standardized Sequence Protocol to Let Collectors be Sequences -
/* ###################################################################################################################################### */
/**
 If you conform to this protocol, you get a few basic Sequence attributes for free.
 
 You'll need to set up a sequence_contents Array (read/write), and set the Element type, and that's about all.
 
 This also gives you a read-only subscript.
 
 This cannot be applied to enums, as it requires a stored property.
 */
public protocol RVS_SequenceProtocol: Sequence {
    /* ################################################################## */
    /**
     :nodoc: The implementor is required to have an Array of Element (required by Sequence).
     */
    var sequence_contents: Array<Element> { get set }
    
    /* ################################################################## */
    /**
     Subscript access is get-only (for safety).
     
     - parameter index: The 0-based index to subscript. Must be less than count.
     */
    subscript(_ inIndex: Int) -> Element { get }
    
    /* ################################################################## */
    /**
     - parameter sequence_contents: An Array of the element type, to initialize the value.
     */
    init(sequence_contents: [Element])
    
    /* ################################################################## */
    /**
     This allows us to remove all the elements in the sequence. It is a mutating function/method.
     */
    mutating func removeAll()
}

/* ###################################################################################################################################### */
// MARK: - Default Implementation (Optional) Methods and Computed Properties -
/* ###################################################################################################################################### */
extension RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     :nodoc: We just pass the iterator through to the Array.
     
     - returns: The Array iterator for our elements.
     */
    public func makeIterator() -> Array<Element>.Iterator { sequence_contents.makeIterator() }
    
    /* ################################################################## */
    /**
     Default implementation should do fine for us.
     */
    public mutating func removeAll() { sequence_contents = [] }
    
    /* ################################################################## */
    /**
     Returns true, if yes, we have no bananas.
     */
    public var isEmpty: Bool { sequence_contents.isEmpty }
    
    /* ################################################################## */
    /**
     The number of elements we have. 1-based. 0 is no elements (isEmpty is true).
     */
    public var count: Int { sequence_contents.count }

    /* ################################################################## */
    /**
     Returns an indexed element.
     
     - parameter inIndex: The 0-based integer index. Must be less than the total count of elements.
     */
    public subscript(_ inIndex: Int) -> Element {
        precondition((0..<count).contains(inIndex), "Index out of range.")   // Standard precondition. Index needs to be 0 or greater, and less than the count.
        
        return sequence_contents[inIndex]
    }
}
