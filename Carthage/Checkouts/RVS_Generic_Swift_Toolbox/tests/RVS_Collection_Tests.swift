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

import XCTest

/* ###################################################################################################################################### */
// MARK: - RVS_FIFOQueue_Tests -
/* ###################################################################################################################################### */
/**
 These are specific unit tests for the RVS_FIFOQueue struct.
 */
class RVS_FIFOQueue_Tests: XCTestCase {
    /* ################################################################## */
    /**
     Just tests the simple creation of the class instance, and stores and removes some elements in order to assure type.
     */
    func testSimpleInstantiation() {
        var testTargetInt = RVS_FIFOQueue<Int>()
        XCTAssertEqual(0, testTargetInt.count)
        testTargetInt.enqueue(10)
        XCTAssertEqual(1, testTargetInt.count)
        let valueInt = testTargetInt.dequeue()
        XCTAssertEqual(0, testTargetInt.count)
        XCTAssertEqual(10, valueInt)
        
        var testTargetIntArray = RVS_FIFOQueue<Int>()
        XCTAssertEqual(0, testTargetIntArray.count)
        testTargetIntArray.enqueue([0, 1])
        XCTAssertEqual(2, testTargetIntArray.count)
        testTargetIntArray.enqueue(2)
        XCTAssertEqual(3, testTargetIntArray.count)
        var valueIntArray = testTargetIntArray.dequeue()
        XCTAssertEqual(2, testTargetIntArray.count)
        XCTAssertEqual(0, valueIntArray)
        valueIntArray = testTargetIntArray.dequeue()
        XCTAssertEqual(1, testTargetIntArray.count)
        XCTAssertEqual(1, valueIntArray)
        valueIntArray = testTargetIntArray.dequeue()
        XCTAssertEqual(0, testTargetIntArray.count)
        XCTAssertEqual(2, valueIntArray)

        var testTargetString = RVS_FIFOQueue<String>()
        XCTAssertEqual(0, testTargetString.count)
        testTargetString.enqueue("HI HOWAYA")
        XCTAssertEqual(1, testTargetString.count)
        let valueString = testTargetString.dequeue()
        XCTAssertEqual(0, testTargetString.count)
        XCTAssertEqual("HI HOWAYA", valueString)
        
        var testTargetStringArray = RVS_FIFOQueue<String>()
        XCTAssertEqual(0, testTargetStringArray.count)
        testTargetStringArray.enqueue(["HI HOWAYA", "IM FINE"])
        XCTAssertEqual(2, testTargetStringArray.count)
        testTargetStringArray.enqueue("HOWRU")
        var valueStringArray = testTargetStringArray.dequeue()
        XCTAssertEqual(2, testTargetStringArray.count)
        XCTAssertEqual("HI HOWAYA", valueStringArray)
        valueStringArray = testTargetStringArray.dequeue()
        XCTAssertEqual(1, testTargetStringArray.count)
        XCTAssertEqual("IM FINE", valueStringArray)
        valueStringArray = testTargetStringArray.dequeue()
        XCTAssertEqual(0, testTargetStringArray.count)
        XCTAssertEqual("HOWRU", valueStringArray)
    }
    
    /* ################################################################## */
    /**
     This uses a typless type, and tests the iterator functionality of the queue struct.
     */
    func testMultipleDifferentValuesAndIterator() {
        var testTarget = RVS_FIFOQueue<Any?>()
        XCTAssertEqual(0, testTarget.count)
        testTarget.enqueue(0)
        testTarget.enqueue(1)
        testTarget.enqueue("One")
        testTarget.enqueue("Two")
        XCTAssertEqual(4, testTarget.count)
        
        for item in testTarget {
            if let item = item as? Int {
                XCTAssertTrue(0 == item || 1 == item)
            } else if let item = item as? String {
                XCTAssertTrue("One" == item || "Two" == item)
            }
        }
        
        XCTAssertEqual(4, testTarget.count, "Items should not have been dequeued by the iterator.")
        
        testTarget.removeAll()
        
        XCTAssertTrue(testTarget.isEmpty)
        
        let testArray: [Any] = [0, 1, "One", "Two"]
        
        testTarget.enqueue(testArray)
        XCTAssertEqual(1, testTarget.count, "Should count as 1 item.")
        
        if let dequeued = testTarget.dequeue() as? [Any] {
            XCTAssertTrue(testTarget.isEmpty)
            XCTAssertEqual(testArray.count, dequeued.count)
            for item in dequeued {
                if let item = item as? Int {
                    XCTAssertTrue(0 == item || 1 == item)
                } else if let item = item as? String {
                    XCTAssertTrue("One" == item || "Two" == item)
                } else {
                    XCTFail("Illegal type!")
                }
            }
        } else {
            XCTFail("This should not be empty.")
        }
    }
    
    /* ################################################################## */
    /**
     This simply jamss a whole bunch of values into a queue, and then makes sure that it iterates and dequeues properly.
     */
    func testABigBunchOfIntValues() {
        let testCount = 5000
        
        var testTargetInt = RVS_FIFOQueue<Int>()
        XCTAssertEqual(0, testTargetInt.count)
        let initializerArray: [Int] = [Int](0..<testCount)  // This is a cheap way to get an incremented range of ints in an Array.
        testTargetInt.enqueue(initializerArray)
        XCTAssertEqual(testCount, testTargetInt.count)
        XCTAssertEqual(0, testTargetInt[0])
        XCTAssertEqual(testCount - 1, testTargetInt[testCount - 1])
        XCTAssertEqual(testCount, testTargetInt.count, "Should not have been dequeued.")
        
        for value in testTargetInt.enumerated() {
            XCTAssertEqual(value.offset, value.element)
            XCTAssertEqual(value.offset, initializerArray[value.offset])
        }
        
        XCTAssertEqual(testCount, testTargetInt.count, "Should not have been dequeued.")
        
        var lastValue = 0
        while let value = testTargetInt.dequeue() {
            lastValue += 1
            XCTAssertEqual(testTargetInt.count, initializerArray.count - lastValue)
            XCTAssertEqual(lastValue - 1, value)
        }
    }
    
    /* ################################################################## */
    /**
     This tests enqueing and dequeueing in a mixed manner.
     */
    func testMixedQueueing() {
        let testCount = 5000
        var indexAdd = 0
        var indexRemove = 0

        var testTargetInt = RVS_FIFOQueue<Int>()
        XCTAssertEqual(0, testTargetInt.count)
        
        let initializerArray: [Int] = [Int](0..<(testCount * 10))
        var expectation = XCTestExpectation()
        
        func enqueuenext() {
            let ind = indexAdd
            indexAdd += 1
            let val = initializerArray[ind]
            testTargetInt.enqueue(val)
            expectation.fulfill()
        }
        
        func dequeuenext() {
            if let val = testTargetInt.dequeue() {
                XCTAssertEqual(indexRemove, val)
                indexRemove += 1
                expectation.fulfill()
            } else {
                XCTAssertTrue(testTargetInt.isEmpty)
            }
        }
        
        expectation.expectedFulfillmentCount = testCount * 2
        
        for _ in 0..<testCount {
            enqueuenext()
            enqueuenext()
            dequeuenext()
            enqueuenext()
            dequeuenext()
            dequeuenext()
            enqueuenext()
            dequeuenext()
            dequeuenext()
            enqueuenext()
            enqueuenext()
            enqueuenext()
            dequeuenext()
            enqueuenext()
            enqueuenext()
            enqueuenext()
            dequeuenext()
        }

        while let val = testTargetInt.dequeue() {
            XCTAssertEqual(indexRemove, val)
            indexRemove += 1
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_SequenceProtocol_Tests -
/* ###################################################################################################################################### */
/**
 These are specific unit tests for the RVS_SequenceProtocol protocol.
 */
class RVS_SequenceProtocol_Tests: XCTestCase {
    /* ################################################################################################################################## */
    // MARK: - TestProtocolImplementation_Int -
    /* ################################################################################################################################## */
    /**
     This is a very simple implementation with an Int data type.
     */
    struct TestProtocolImplementation_Int: RVS_SequenceProtocol {
        typealias Element = Int
        var sequence_contents: [Element] = []
    }
    
    /* ################################################################################################################################## */
    // MARK: - TestProtocolImplementation_String -
    /* ################################################################################################################################## */
    /**
     This is a very simple implementation with a String data type.
     */
    struct TestProtocolImplementation_String: RVS_SequenceProtocol {
        typealias Element = String
        var sequence_contents: [Element] = []
    }
    
    /* ################################################################################################################################## */
    // MARK: - TestProtocolImplementation_Tuple -
    /* ################################################################################################################################## */
    /**
     This is a very simple implementation with a special Tuple data type.
     */
    struct TestProtocolImplementation_Tuple: RVS_SequenceProtocol {
        typealias Element = (intVal: Int, stringVal: String)
        var sequence_contents: [Element] = []
    }
    
    /* ################################################################################################################################## */
    // MARK: - TestProtocolImplementation_Tuple_Class -
    /* ################################################################################################################################## */
    /**
     This is a very simple implementation with a special Tuple data type, but as a class.
     */
    class TestProtocolImplementation_Tuple_Class: RVS_SequenceProtocol {
        typealias Element = (intVal: Int, stringVal: String)
        var sequence_contents: [Element] = []
        required init(sequence_contents inSequence_contents: [(intVal: Int, stringVal: String)]) {
            sequence_contents = inSequence_contents
        }
    }

    /* ################################################################## */
    /**
     Just tests the simple creation of the class instances, and iterates them.
     
     This pretty much tests everything we need for this simple protocol.
     */
    func testSimpleInstantiation() {
        let testTargetInt = TestProtocolImplementation_Int(sequence_contents: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        
        XCTAssertEqual(10, testTargetInt.count)

        for testValue in testTargetInt.enumerated() {
            XCTAssertEqual(testValue.offset, testValue.element)
        }
        
        for index in 0..<testTargetInt.count {
            XCTAssertEqual(index, testTargetInt[index])
        }

        XCTAssertEqual(10, testTargetInt.count)

        let testTargetString = TestProtocolImplementation_String(sequence_contents: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"])
        
        XCTAssertEqual(10, testTargetString.count)

        for testValue in testTargetString.enumerated() {
            XCTAssertEqual(testValue.offset, Int(testValue.element, radix: 10) ?? -1)
        }
        
        for index in 0..<testTargetString.count {
            XCTAssertEqual(index, Int(testTargetString[index], radix: 10) ?? -1)
        }

        XCTAssertEqual(10, testTargetString.count)
        
        var testTargetTuple = TestProtocolImplementation_Tuple(sequence_contents: [ (intVal: 0, stringVal: "0"),
                                                                                    (intVal: 1, stringVal: "1"),
                                                                                    (intVal: 2, stringVal: "2"),
                                                                                    (intVal: 3, stringVal: "3"),
                                                                                    (intVal: 4, stringVal: "4"),
                                                                                    (intVal: 5, stringVal: "5"),
                                                                                    (intVal: 6, stringVal: "6"),
                                                                                    (intVal: 7, stringVal: "7"),
                                                                                    (intVal: 8, stringVal: "8"),
                                                                                    (intVal: 9, stringVal: "9")
        ])
        XCTAssertEqual(10, testTargetTuple.count)
        
        for testValue in testTargetTuple.enumerated() {
            XCTAssertEqual(testValue.offset, testValue.element.intVal)
            XCTAssertEqual(testValue.offset, Int(testValue.element.stringVal, radix: 10) ?? -1)
        }
        
        for index in 0..<testTargetTuple.count {
            XCTAssertEqual(index, testTargetTuple[index].intVal)
            XCTAssertEqual(index, Int(testTargetTuple[index].stringVal, radix: 10) ?? -1)
        }

        XCTAssertEqual(10, testTargetTuple.count)
        testTargetTuple.removeAll()
        XCTAssertTrue(testTargetTuple.isEmpty)
        XCTAssertEqual(0, testTargetTuple.count)
        
        var testTargetTupleClass = TestProtocolImplementation_Tuple_Class(sequence_contents: [  (intVal: 0, stringVal: "0"),
                                                                                                (intVal: 1, stringVal: "1"),
                                                                                                (intVal: 2, stringVal: "2"),
                                                                                                (intVal: 3, stringVal: "3"),
                                                                                                (intVal: 4, stringVal: "4"),
                                                                                                (intVal: 5, stringVal: "5"),
                                                                                                (intVal: 6, stringVal: "6"),
                                                                                                (intVal: 7, stringVal: "7"),
                                                                                                (intVal: 8, stringVal: "8"),
                                                                                                (intVal: 9, stringVal: "9")
        ])
        
        XCTAssertEqual(10, testTargetTupleClass.count)

        for testValue in testTargetTupleClass.enumerated() {
            XCTAssertEqual(testValue.offset, testValue.element.intVal)
            XCTAssertEqual(testValue.offset, Int(testValue.element.stringVal, radix: 10) ?? -1)
        }
        
        XCTAssertEqual(10, testTargetTupleClass.count)
        testTargetTupleClass.removeAll()
        XCTAssertTrue(testTargetTupleClass.isEmpty)
        XCTAssertEqual(0, testTargetTupleClass.count)
    }
}
