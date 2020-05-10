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
// MARK: - Simple Instantiation and Persistence Tests for the Persistent Prefs Class.
/* ################################################################################################################################## */
/**
 Just some simple tests, to make sure that our persistent prefs are in good shape.
 */
class RVS_Persistent_Prefs_Tests: XCTestCase {
    /* ############################################################################################################################## */
    // MARK: - Concrete Subclass For Testing
    /* ############################################################################################################################## */
    /**
     This is a special simple subclass of the persistent prefs. It declares four keys, and provides simple accessors for the data.
     It has simple mixed data types that are all scalar and Codable.
     */
    class TestClass: RVS_PersistentPrefs {
        /* ################################################################## */
        /**
         These are the keys for our saved data.
         */
        override public var keys: [String] {
            return ["First", "Next", "Test", "Last"]
        }
        
        /* ################################################################## */
        /**
         The first value is an Int.
         */
        var first: Int {
            let ret = values["First"] as? Int
            return ret ?? 0
        }
        
        /* ################################################################## */
        /**
         The second value is a String
         */
        var next: String {
            let ret = values["Next"] as? String
            return ret ?? ""
        }
        
        /* ################################################################## */
        /**
         The third value is a Bool
         */
        var test: Bool {
            let ret = values["Test"] as? Bool
            return ret ?? false
        }
        
        /* ################################################################## */
        /**
         The last value is a Double.
         */
        var last: Double {
            let ret = values["Last"] as? Double
            return ret ?? 0.0
        }
    }

    /* ################################################################## */
    /**
     Test the default instantiation, to make sure that the prefs propagate everywhere.
     */
    func testBasicDefaults() {
        // We first create a default instance, and load it with some values.
        let testClass = TestClass()
        testClass.values = ["First": 1, "Next": "HELO", "Test": true, "Last": 4.5]
        
        // Make sure the values are reflected in the access variables.
        XCTAssertEqual(1, testClass.first)
        XCTAssertEqual("HELO", testClass.next)
        XCTAssertEqual(true, testClass.test)
        XCTAssertEqual(4.5, testClass.last)

        // Next, create a whole new instance of the default class.
        let testClass2 = TestClass()
        
        // Make sure that it got the same values from the persistent defaults.
        XCTAssertEqual(1, testClass2.first)
        XCTAssertEqual("HELO", testClass2.next)
        XCTAssertEqual(true, testClass2.test)
        XCTAssertEqual(4.5, testClass2.last)

        // Change the values, using the new instance.
        testClass2.values = ["First": 12, "Next": "HIHOWAYA", "Test": false, "Last": 26.2]
        
        // Make sure that the first instance now reflects the new values.
        XCTAssertEqual(12, testClass.first)
        XCTAssertEqual("HIHOWAYA", testClass.next)
        XCTAssertEqual(false, testClass.test)
        XCTAssertEqual(26.2, testClass.last)
        
        // Create yet another instance of the default class.
        let testClass3 = TestClass()
        
        // Make sure that it got the correct values.
        XCTAssertEqual(12, testClass3.first)
        XCTAssertEqual("HIHOWAYA", testClass3.next)
        XCTAssertEqual(false, testClass3.test)
        XCTAssertEqual(26.2, testClass3.last)
    }
    
    /* ################################################################## */
    /**
     Test with two sets of defaults, specialized by a test key.
     */
    func testWithKeys() {
        // We first create a default instance, and load it with some values.
        let testClass = TestClass()
        testClass.values = ["First": 1, "Next": "HELO", "Test": true, "Last": 4.5]

        // Make sure the values are reflected in the access variables.
        XCTAssertEqual(1, testClass.first)
        XCTAssertEqual("HELO", testClass.next)
        XCTAssertEqual(true, testClass.test)
        XCTAssertEqual(4.5, testClass.last)

        // Next, create a whole new instance of the default class, but this time, we use a key.
        let testClass2 = TestClass(key: "TestInstance-2")

        // Make sure the values are NOT reflected in the access variables.
        XCTAssertNotEqual(1, testClass2.first)
        XCTAssertNotEqual("HELO", testClass2.next)
        XCTAssertNotEqual(true, testClass2.test)
        XCTAssertNotEqual(4.5, testClass2.last)

        // Change the values, using the new instance.
        testClass2.values = ["First": 12, "Next": "HIHOWAYA", "Test": false, "Last": 26.2]

        // Make sure the values are NOT sent to the original default instance.
        XCTAssertEqual(1, testClass.first)
        XCTAssertEqual("HELO", testClass.next)
        XCTAssertEqual(true, testClass.test)
        XCTAssertEqual(4.5, testClass.last)

        // Next, create a new instance, but use the same key that we used for the second instance.
        let testClass3 = TestClass(key: "TestInstance-2")

        // Make sure that it got the correct values.
        XCTAssertEqual(12, testClass3.first)
        XCTAssertEqual("HIHOWAYA", testClass3.next)
        XCTAssertEqual(false, testClass3.test)
        XCTAssertEqual(26.2, testClass3.last)

        // Create a fourth one, with the default key.
        let testClass4 = TestClass()

        // Make sure it got the values from the first (default) instance.
        XCTAssertEqual(1, testClass4.first)
        XCTAssertEqual("HELO", testClass4.next)
        XCTAssertEqual(true, testClass4.test)
        XCTAssertEqual(4.5, testClass4.last)

        // This should delete all of our data
        testClass4.values = [:]
        XCTAssertEqual(0, testClass4.count)

        // Create a fifth one, and make sure the data was deleted
        let testClass5 = TestClass()
        XCTAssertEqual(0, testClass5.count)
        
        // Put the values back.
        testClass5.values = ["First": 1, "Next": "HELO", "Test": true, "Last": 4.5]
        
        // Make sure they made it.
        XCTAssertEqual(1, testClass4.first)
        XCTAssertEqual("HELO", testClass4.next)
        XCTAssertEqual(true, testClass4.test)
        XCTAssertEqual(4.5, testClass4.last)
        
        XCTAssertEqual(1, testClass5.first)
        XCTAssertEqual("HELO", testClass5.next)
        XCTAssertEqual(true, testClass5.test)
        XCTAssertEqual(4.5, testClass5.last)
        
        // Clear the values. This time, use the method.
        testClass5.clear()
        
        // Make sure it cleared everything.
        XCTAssertEqual(0, testClass5.count)
        XCTAssertEqual(0, testClass4.count)
    }
}
