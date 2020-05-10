/**
 © Copyright 2019, The Great Rift Valley Software Company
 
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
 */

import XCTest

/* ################################################################################################################################## */
// MARK: - Tests for the Persistent Prefs.
/* ################################################################################################################################## */
/**
 The class is not thread-safe.
 
 You can use it in simple linear tasks (like run loop timers), but not real NSOperation-type threads.
 */
class RVS_Persistent_Prefs_Thread_Tests: XCTestCase {
    /* ############################################################################################################################## */
    // This is a non-Codable class.
    /* ############################################################################################################################## */
    /**
     This is a very simple derived class that we use for testing.
     */
    class SuperSimpleTypeTestClass: RVS_PersistentPrefs {
        /* ################################################################## */
        /**
         These are the keys for our saved data.
         */
        override public var keys: [String] {
            // These are all the types that we will be testing against.
            return ["Int", "String"]
        }
        
        /* ################################################################## */
        /**
         You can initialize instances with a key and some initial data values.
         
         - parameter key: Optional (default is nil). A String, with a key to be used to associate the persistent state of this object to storage in the bundle.
         If not provided, the subclass classname is used as the key.
         - parameter values: Optional (default is nil). A Dictionary<String, Any>, with the values to be stored.
         If not provided, then the instance is populated by any persistent prefs.
         If provided, then the persistent prefs are updated with the new values.
         */
        override public init(key inKey: String! = nil, values inValues: [String: Any]! = [:]) {
            super.init(key: inKey, values: inValues)
        }

        /* ################################################################## */
        /**
         This is an Int value
         */
        var int: Int {
            get {
                let ret = values["Int"] as? Int
                return ret ?? 0
            }
            
            set {
                values["Int"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a String value
         */
        var string: String {
            get {
                let ret = values["String"] as? String
                return ret ?? ""
            }
            
            set {
                values["String"] = newValue
            }
        }
    }

    /* ################################################################## */
    /**
     Test a simple, one-after-the-other timer set in the run loop.
     */
    func testSimpleLinearRunLoopThreading() {
        let testKey = "testSimpleLinearRunLoopThreading-0"   // The prefs key that we'll be using for this test.
        
        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
        let initialSet: [String: Any] = ["Int": 10, "String": "Ten"]
        _ = SuperSimpleTypeTestClass(key: testKey, values: initialSet)
        
        // Set up a new instance. It should have all the ones in the initial set.
        let testTarget0 = SuperSimpleTypeTestClass(key: testKey)
        XCTAssertNil(testTarget0.lastError)
        XCTAssertEqual(10, testTarget0.int)
        XCTAssertEqual("Ten", testTarget0.string)
        
        let expectationsArePremeditatedResenments = XCTestExpectation(description: "Wait For All Threads to Complete")
        
        expectationsArePremeditatedResenments.expectedFulfillmentCount = 2

        /* ############################################################# */
        /**
         This will set the variables for the next iteration, then kick that off.
         */
        func timer1CallBack(_ inTimer: Timer) {
            print("Timer 1 Callback!")
            XCTAssertNil(testTarget0.lastError)
            XCTAssertEqual(10, testTarget0.int)
            XCTAssertEqual("Ten", testTarget0.string)

            testTarget0.int = 1
            testTarget0.string = "One"
            
            expectationsArePremeditatedResenments.fulfill()
            
            _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: timer2CallBack)
        }
        
        /* ############################################################# */
        /**
         This will set the final state.
         */
        func timer2CallBack(_ inTimer: Timer) {
            print("Timer 2 Callback!")
            XCTAssertNil(testTarget0.lastError)
            XCTAssertEqual(1, testTarget0.int)
            XCTAssertEqual("One", testTarget0.string)

            testTarget0.int = 2
            testTarget0.string = "Two"

            expectationsArePremeditatedResenments.fulfill()
        }
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: timer1CallBack)

        wait(for: [expectationsArePremeditatedResenments], timeout: 1)
        
        XCTAssertNil(testTarget0.lastError)
        XCTAssertEqual(2, testTarget0.int)
        XCTAssertEqual("Two", testTarget0.string)
    }

    /* ################################################################## */
    /**
     Test with a bunch of NSOperations. Bit hairier.
     
     THIS WILL FAIL. It may work for a few times, but it will eventually crash in a dealloc, as the dealloc happens in a different thread than the original allocation.
     
     This class IS NOT THREAD-SAFE.
     */
//    func testOperationThreading() {
//        let taskCount = 30
//        let testKey = "testOperationThreading-0"   // The prefs key that we'll be using for this test.
//
//        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
//        let initialSet: [String: Any] = ["Int": 10, "String": "Ten"]
//        _ = SuperSimpleTypeTestClass(key: testKey, values: initialSet)
//
//        // Set up a new instance. It should have all the ones in the initial set.
//        let testTarget0 = SuperSimpleTypeTestClass(key: testKey)
//        XCTAssertNil(testTarget0.lastError)
//        XCTAssertEqual(10, testTarget0.int)
//        XCTAssertEqual("Ten", testTarget0.string)
//
//        let expectationsArePremeditatedResenments = XCTestExpectation(description: "Wait For All Threads to Complete")
//
//        expectationsArePremeditatedResenments.expectedFulfillmentCount = taskCount * 4
//
//        class SetIntegers: Operation {
//            let threadName: String
//            let index: Int
//            let list: [Int]
//            let target: SuperSimpleTypeTestClass
//            let expectation: XCTestExpectation
//
//            init(_ inList: [Int], index inIndex: Int = 0, target inTarget: SuperSimpleTypeTestClass, expectation inExpectation: XCTestExpectation, threadName inName: String) {
//                list = inList
//                index = inIndex
//                target = inTarget
//                expectation = inExpectation
//                threadName = inName
//            }
//
//            override func main() {
//                guard 0 < list.count else {
//                    XCTFail("No Data!")
//                    return
//                }
//                guard !isCancelled else { return }
//                let indexVal = index % list.count
//                guard !isCancelled else { return }
//                let value = list[indexVal]
//                expectation.fulfill()
//                target["Int"] = value
//                expectation.fulfill()
//            }
//        }
//
//        class SetStrings: Operation {
//            let threadName: String
//            let index: Int
//            let list: [String]
//            let target: SuperSimpleTypeTestClass
//            let expectation: XCTestExpectation
//
//            init(_ inList: [String], index inIndex: Int = 0, target inTarget: SuperSimpleTypeTestClass, expectation inExpectation: XCTestExpectation, threadName inName: String) {
//                list = inList
//                index = inIndex
//                target = inTarget
//                expectation = inExpectation
//                threadName = inName
//            }
//
//            override func main() {
//                guard 0 < list.count else {
//                    XCTFail("No Data!")
//                    return
//                }
//                guard !isCancelled else { return }
//                let indexVal = index % list.count
//                var value = "My name is \(list[indexVal])"
//                if "Inigo Montaya" == value {
//                    value += ". You killed my father. Prepare to die!"
//                }
//                target["String"] = value
//                expectation.fulfill()
//                guard !isCancelled else { return }
//            }
//        }
//
//        // Set up a couple of NSOperations for the testing.
//        class RunningOperations {
//            lazy var currentOperations: [IndexPath: Operation] = [:]
//            lazy var testSet0Queue: OperationQueue = {
//                var queue = OperationQueue()
//                return queue
//            }()
//
//            lazy var testSet1Queue: OperationQueue = {
//                var queue = OperationQueue()
//                return queue
//            }()
//        }
//
//        let runningOperations = RunningOperations()
//
//        for index in 0..<taskCount {
//            runningOperations.testSet0Queue.addOperation(SetIntegers([0, 1, 2, 3, 4], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "Int 0"))
//            runningOperations.testSet0Queue.addOperation(SetStrings(["Fred", "Doug", "Inigo Montaya", "Bilbo", "Bond, James Bond"], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "String 0"))
//            runningOperations.testSet1Queue.addOperation(SetIntegers([5, 6, 7, 8, 9], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "Int 1"))
//            runningOperations.testSet1Queue.addOperation(SetStrings(["Barbra", "Helen", "Susan", "Annie", "Debbie"], index: index, target: testTarget0, expectation: expectationsArePremeditatedResenments, threadName: "String 1"))
//        }
//
//        wait(for: [expectationsArePremeditatedResenments], timeout: 10)
//
//        runningOperations.testSet0Queue.cancelAllOperations()
//    }
}
