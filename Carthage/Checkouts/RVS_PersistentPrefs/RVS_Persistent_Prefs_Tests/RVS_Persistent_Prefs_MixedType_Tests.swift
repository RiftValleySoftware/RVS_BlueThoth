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
 */
class RVS_Persistent_Prefs_MixedType_Tests: XCTestCase {
    /* ############################################################################################################################## */
    // This is a non-Codable class.
    /* ############################################################################################################################## */
    /**
     */
    class NonCodableClass {
        let value = "Hello World"
    }
    
    /* ############################################################################################################################## */
    // This is a non-Codable struct.
    /* ############################################################################################################################## */
    /**
     */
    struct NonCodableStruct {
        let value = "Hello World"
    }
    
    /* ############################################################################################################################## */
    // This is a non-Codable enum.
    /* ############################################################################################################################## */
    /**
     */
    enum NonCodableEnum: String {
        case value = "Hello World"
    }
    
    /* ############################################################################################################################## */
    // MARK: - Embedded Class for Testing Several Simple Data Types
    /* ############################################################################################################################## */
    /**
     */
    class MixedSimpleTypeTestClass: RVS_PersistentPrefs {
        /* ################################################################## */
        /**
         These are the keys for our saved data.
         */
        override public var keys: [String] {
            // These are all the types that we will be testing against.
            return ["Int", "String", "Float", "Double", "Bool", "CodableArray", "CodableDictionary", "NonCodableClass", "NonCodableStruct", "NonCodableEnum", "IllegalBuriedHere"]
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
        
        /* ################################################################## */
        /**
         This is a Float value
         */
        var float: Float {
            get {
                print("Values for \"\(key)\": \(String(describing: values))")
                let ret = values["Float"] as? Float
                return ret ?? Float.nan
            }
            
            set {
                values["Float"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a Double value
         */
        var double: Double {
            get {
                let ret = values["Double"] as? Double
                return ret ?? Double.nan
            }
            
            set {
                values["Double"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a Bool value
         */
        var bool: Bool {
            get {
                let ret = values["Bool"] as? Bool
                return ret ?? false
            }
            
            set {
                values["Bool"] = newValue
            }
        }

        /* ################################################################## */
        /**
         This ia a Codable Array (of Int)
         */
        var codableArray: [Int] {
            get {
                let ret = values["CodableArray"] as? [Int]
                return ret ?? []
            }
            
            set {
                values["CodableArray"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         This is a Codable Dictionary (of String: Int).
         */
        var codableDictionary: [String: Int] {
            get {
                let ret = values["CodableDictionary"] as? [String: Int]
                return ret ?? [:]
            }
            
            set {
                values["CodableDictionary"] = newValue
            }
        }
        
        /* ################################################################## */
        /**
         The main initializer. This will initialize the superclass with our preset values.
         All parameters are optional.
         - parameter key: The storage key for this instance.
         - parameter int: An integer value.
         - parameter string: A String Value.
         - parameter float: A Float value.
         - parameter double: A Double value.
         - parameter bool: A Bool value.
         - parameter codableArray: An Array of Int.
         - parameter codableDictionary: A Dictionary of [String: Int].
         */
        init(key inKey: String! = nil, int inInt: Int! = nil, string inString: String! = nil, float inFloat: Float! = nil, double inDouble: Double! = nil, bool inBool: Bool! = nil, codableArray inCodableArray: [Int]! = nil, codableDictionary inCodableDictionary: [String: Int]! = nil) {
            // Set up an initial values Dictionary to initialize the instance.
            var values: [String: Any] = [:]
            
            if let inInt = inInt {
                values["Int"] = inInt
            }
            
            if let inString = inString {
                values["String"] = inString
            }
            
            if let inFloat = inFloat {
                values["Float"] = inFloat
            }
            
            if let inDouble = inDouble {
                values["Double"] = inDouble
            }
            
            if let inBool = inBool {
                values["Bool"] = inBool
            }
            
            if let inCodableArray = inCodableArray {
                values["CodableArray"] = inCodableArray
            }
            
            if let inCodableDictionary = inCodableDictionary {
                values["CodableDictionary"] = inCodableDictionary
            }

            super.init(key: inKey, values: values)
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
    }
    
    /* ################################################################## */
    /**
     This tests our values initializers.
     */
    func testBasicMixedTypeInitializers() {
        // First, we initialize with a preset Dictionary of values, and then make sure that we get those values back.
        let initialTestSet: [String: Any] = ["Int": 10, "String": "Ten", "Float": Float(12.3), "Double": Double(45.6), "Bool": true, "CodableArray": [1, 2, 3], "CodableDictionary": ["One": 1, "Two": 2, "Three": 3]]
        let testTarget0 = MixedSimpleTypeTestClass(values: initialTestSet)
        XCTAssertEqual(10, testTarget0.int)
        XCTAssertEqual("Ten", testTarget0.string)
        XCTAssertEqual(Float(12.3), testTarget0.float)
        XCTAssertEqual(Double(45.6), testTarget0.double)
        XCTAssertEqual(true, testTarget0.bool)
        XCTAssertEqual([1, 2, 3], testTarget0.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget0.codableDictionary)

        // Now, instantiate a new instance (default key), and make sure that it gets the same values.
        let testTarget1 = MixedSimpleTypeTestClass()
        XCTAssertEqual(10, testTarget1.int)
        XCTAssertEqual("Ten", testTarget1.string)
        XCTAssertEqual(Float(12.3), testTarget1.float)
        XCTAssertEqual(Double(45.6), testTarget1.double)
        XCTAssertEqual(true, testTarget1.bool)
        XCTAssertEqual([1, 2, 3], testTarget1.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget1.codableDictionary)

        // Now, create a discardable instance, with just a couple of the parameters changed, and make sure that the parameters are changed for the two concrete instances we already have.
        let partialTestSet0: [String: Any] = ["Int": 20, "String": "Twenty"]
        _ = MixedSimpleTypeTestClass(values: partialTestSet0)
        XCTAssertEqual(20, testTarget0.int)
        XCTAssertEqual("Twenty", testTarget0.string)
        XCTAssertEqual(Float(12.3), testTarget0.float)
        XCTAssertEqual(Double(45.6), testTarget0.double)
        XCTAssertEqual(true, testTarget0.bool)
        XCTAssertEqual([1, 2, 3], testTarget0.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget0.codableDictionary)
        XCTAssertEqual(20, testTarget1.int)
        XCTAssertEqual("Twenty", testTarget1.string)
        XCTAssertEqual(Float(12.3), testTarget1.float)
        XCTAssertEqual(Double(45.6), testTarget1.double)
        XCTAssertEqual(true, testTarget1.bool)
        XCTAssertEqual([1, 2, 3], testTarget1.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget1.codableDictionary)

        // Now, we change the Dictionary, and make sure that it comes back the way that it should.
        let partialTestSet1: [String: Any] = ["CodableDictionary": ["Four": 4, "Five": 5, "Six": 6]]
        let testTarget2 = MixedSimpleTypeTestClass(values: partialTestSet1)
        XCTAssertEqual(20, testTarget0.int)
        XCTAssertEqual("Twenty", testTarget0.string)
        XCTAssertEqual(Float(12.3), testTarget0.float)
        XCTAssertEqual(Double(45.6), testTarget0.double)
        XCTAssertEqual(true, testTarget0.bool)
        XCTAssertEqual([1, 2, 3], testTarget0.codableArray)
        XCTAssertEqual(20, testTarget1.int)
        XCTAssertEqual("Twenty", testTarget1.string)
        XCTAssertEqual(Float(12.3), testTarget1.float)
        XCTAssertEqual(Double(45.6), testTarget1.double)
        XCTAssertEqual(true, testTarget1.bool)
        XCTAssertEqual([1, 2, 3], testTarget1.codableArray)
        XCTAssertEqual(["Four": 4, "Five": 5, "Six": 6], testTarget1.codableDictionary)
        XCTAssertEqual(20, testTarget2.int)
        XCTAssertEqual("Twenty", testTarget2.string)
        XCTAssertEqual(Float(12.3), testTarget2.float)
        XCTAssertEqual(Double(45.6), testTarget2.double)
        XCTAssertEqual(true, testTarget2.bool)
        XCTAssertEqual([1, 2, 3], testTarget2.codableArray)
        XCTAssertEqual(["Four": 4, "Five": 5, "Six": 6], testTarget2.codableDictionary)
        
        // Now, create a new test preference, with a different key.
        let testTarget3 = MixedSimpleTypeTestClass(key: "testTarget3", values: initialTestSet)
        // Make sure that it instantiated properly
        XCTAssertEqual(10, testTarget3.int)
        XCTAssertEqual("Ten", testTarget3.string)
        XCTAssertEqual(Float(12.3), testTarget3.float)
        XCTAssertEqual(Double(45.6), testTarget3.double)
        XCTAssertEqual(true, testTarget3.bool)
        XCTAssertEqual([1, 2, 3], testTarget3.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget3.codableDictionary)

        // ...and make sure that it didn't mess with the ones we had already set up.
        XCTAssertEqual(20, testTarget0.int)
        XCTAssertEqual("Twenty", testTarget0.string)
        XCTAssertEqual(Float(12.3), testTarget0.float)
        XCTAssertEqual(Double(45.6), testTarget0.double)
        XCTAssertEqual(true, testTarget0.bool)
        XCTAssertEqual([1, 2, 3], testTarget0.codableArray)
        XCTAssertEqual(20, testTarget1.int)
        XCTAssertEqual("Twenty", testTarget1.string)
        XCTAssertEqual(Float(12.3), testTarget1.float)
        XCTAssertEqual(Double(45.6), testTarget1.double)
        XCTAssertEqual(true, testTarget1.bool)
        XCTAssertEqual([1, 2, 3], testTarget1.codableArray)
        XCTAssertEqual(["Four": 4, "Five": 5, "Six": 6], testTarget1.codableDictionary)
        XCTAssertEqual(20, testTarget2.int)
        XCTAssertEqual("Twenty", testTarget2.string)
        XCTAssertEqual(Float(12.3), testTarget2.float)
        XCTAssertEqual(Double(45.6), testTarget2.double)
        XCTAssertEqual(true, testTarget2.bool)
        XCTAssertEqual([1, 2, 3], testTarget2.codableArray)
        XCTAssertEqual(["Four": 4, "Five": 5, "Six": 6], testTarget2.codableDictionary)

        // Create another instance, with the new key, and make sure it has the values it's supposed to have.
        let testTarget4 = MixedSimpleTypeTestClass(key: "testTarget3")
        // Make sure that it instantiated properly
        XCTAssertEqual(10, testTarget4.int)
        XCTAssertEqual("Ten", testTarget4.string)
        XCTAssertEqual(Float(12.3), testTarget4.float)
        XCTAssertEqual(Double(45.6), testTarget4.double)
        XCTAssertEqual(true, testTarget4.bool)
        XCTAssertEqual([1, 2, 3], testTarget4.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget4.codableDictionary)
        
        // Change the Array only, directly through the accessor.
        testTarget4.codableArray = [4, 5, 6]
        XCTAssertEqual(10, testTarget4.int)
        XCTAssertEqual("Ten", testTarget4.string)
        XCTAssertEqual(Float(12.3), testTarget4.float)
        XCTAssertEqual(Double(45.6), testTarget4.double)
        XCTAssertEqual(true, testTarget4.bool)
        XCTAssertEqual([4, 5, 6], testTarget4.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget4.codableDictionary)
        // ...and that it is also reflected in the other instance with the same key.
        XCTAssertEqual(10, testTarget3.int)
        XCTAssertEqual("Ten", testTarget3.string)
        XCTAssertEqual(Float(12.3), testTarget3.float)
        XCTAssertEqual(Double(45.6), testTarget3.double)
        XCTAssertEqual(true, testTarget3.bool)
        XCTAssertEqual([4, 5, 6], testTarget3.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget3.codableDictionary)
        
        // Create a new instance with that key, and make sure that the change is there, as well.
        let testTarget5 = MixedSimpleTypeTestClass(key: "testTarget3")
        XCTAssertEqual(10, testTarget5.int)
        XCTAssertEqual("Ten", testTarget5.string)
        XCTAssertEqual(Float(12.3), testTarget5.float)
        XCTAssertEqual(Double(45.6), testTarget5.double)
        XCTAssertEqual(true, testTarget5.bool)
        XCTAssertEqual([4, 5, 6], testTarget5.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "Three": 3], testTarget5.codableDictionary)
    }
    
    /* ################################################################## */
    /**
     This tests with a few types that we created that are not Codable.
     */
    func testWithNonCodableTypes() {
        let testKey = "testWithNonCodableTypes-1"   // The prefs key that we'll be using for this test.
        
        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
        let initialSet: [String: Any] = ["Int": 1, "String": "One", "Double": Double(2.0), "Bool": false, "CodableArray": [3, 4, 5], "Float": Float(10.0)]
        _ = MixedSimpleTypeTestClass(key: testKey, values: initialSet)

        // The first thing that we test, is if a single non-Codable type will pooch us, the way it should.
        let initialTestSet: [String: Any] = ["Int": 10, "String": "Ten", "Double": Double(1.0), "Bool": true, "CodableArray": [1, 2, 3], "NonCodableClass": NonCodableClass(), "Float": Float(12.3)]
        
        let testTarget0 = MixedSimpleTypeTestClass(key: testKey, values: initialTestSet)
        XCTAssertNotNil(testTarget0.lastError)
        if let lastError = testTarget0.lastError, case let RVS_PersistentPrefs.PrefsError.valuesNotPlistCompatible(valueList) = lastError {
            XCTAssertEqual(["NonCodableClass"], valueList)
        }
        
        XCTAssertNotNil(testTarget0.lastError) // This is still around, because it has not been cleared.
        XCTAssertEqual(1, testTarget0.int)
        XCTAssertNil(testTarget0.lastError) // This should be cleared after the first access.
        XCTAssertEqual("One", testTarget0.string)
        XCTAssertEqual(2.0, testTarget0.double)
        XCTAssertEqual(Float(10.0), testTarget0.float)
        XCTAssertEqual(false, testTarget0.bool)
        XCTAssertEqual([3, 4, 5], testTarget0.codableArray)
        XCTAssertEqual([:], testTarget0.codableDictionary)
        
        let testTarget1 = MixedSimpleTypeTestClass(key: testKey, values: ["NonCodableStruct": NonCodableStruct()])
        XCTAssertNotNil(testTarget1.lastError)
        if let lastError = testTarget1.lastError, case let RVS_PersistentPrefs.PrefsError.valuesNotPlistCompatible(valueList) = lastError {
            XCTAssertEqual(["NonCodableStruct"], valueList)
        }
        
        XCTAssertNotNil(testTarget1.lastError) // This is still around, because it has not been cleared.
        XCTAssertEqual(1, testTarget1.int)
        XCTAssertNil(testTarget1.lastError) // This should be cleared after the first access.
        XCTAssertEqual("One", testTarget1.string)
        XCTAssertEqual(2.0, testTarget1.double)
        XCTAssertEqual(Float(10.0), testTarget1.float)
        XCTAssertEqual(false, testTarget1.bool)
        XCTAssertEqual([3, 4, 5], testTarget1.codableArray)
        XCTAssertEqual([:], testTarget1.codableDictionary)
        
        let testTarget2 = MixedSimpleTypeTestClass(key: testKey, values: ["NonCodableEnum": NonCodableEnum.value])
        XCTAssertNotNil(testTarget2.lastError)
        if let lastError = testTarget2.lastError, case let RVS_PersistentPrefs.PrefsError.valuesNotPlistCompatible(valueList) = lastError {
            XCTAssertEqual(["NonCodableEnum"], valueList)
        }
        
        XCTAssertNotNil(testTarget2.lastError) // This is still around, because it has not been cleared.
        XCTAssertEqual(1, testTarget2.int)
        XCTAssertNil(testTarget2.lastError) // This should be cleared after the first access.
        XCTAssertEqual("One", testTarget2.string)
        XCTAssertEqual(2.0, testTarget2.double)
        XCTAssertEqual(Float(10.0), testTarget2.float)
        XCTAssertEqual(false, testTarget2.bool)
        XCTAssertEqual([3, 4, 5], testTarget2.codableArray)
        XCTAssertEqual([:], testTarget2.codableDictionary)
        
        // Now, we get a bit tricky. We nest illegal values inside of legal ones.
        let nestedIllegalValue: [String: [String: Any]] = ["IllegalBuriedHere": ["ThisIsALegalValue": 10, "ThisContainsLegalValues": ["ThisOnesLegal": 10, "AndSoIsThisOne": "Ten"], "ThisContainsAnIllegalValue": ["JKThisOnesLegal": 10, "ButThisOnesIllegal": NonCodableEnum.value]]]
        let testTarget3 = MixedSimpleTypeTestClass(key: testKey, values: nestedIllegalValue)
        XCTAssertNotNil(testTarget3.lastError)
        if let lastError = testTarget3.lastError, case let RVS_PersistentPrefs.PrefsError.valuesNotPlistCompatible(valueList) = lastError {
            XCTAssertEqual(["IllegalBuriedHere"], valueList.sorted())
        }
        // And make sure that we got the proper values from our initial load.
        XCTAssertNotNil(testTarget3.lastError) // This is still around, because it has not been cleared.
        XCTAssertEqual(1, testTarget3.int)
        XCTAssertNil(testTarget3.lastError) // This should be cleared after the first access.
        XCTAssertEqual("One", testTarget3.string)
        XCTAssertEqual(2.0, testTarget3.double)
        XCTAssertEqual(Float(10.0), testTarget3.float)
        XCTAssertEqual(false, testTarget3.bool)
        XCTAssertEqual([3, 4, 5], testTarget3.codableArray)
        XCTAssertEqual([:], testTarget3.codableDictionary)
    }
    
    /* ################################################################## */
    /**
     In this test, we add some objects that are at different keys from the ones that we allow.
     */
    func testWithIllegalKeys() {
        let testKey = "testWithIllegalKeys-1"   // The prefs key that we'll be using for this test.
        
        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
        let initialSet: [String: Any] = ["Int": 1, "String": "One", "Double": Double(2.0), "Float": Float(10.0), "Bool": false, "CodableArray": [3, 4, 5], "CodableDictionary": ["One": 1, "Two": 2, "3": 3]]
        _ = MixedSimpleTypeTestClass(key: testKey, values: initialSet)
        
        // Set up a new instance. It should have all the ones in the initial set.
        let testTarget0 = MixedSimpleTypeTestClass(key: testKey)
        XCTAssertNil(testTarget0.lastError)
        XCTAssertEqual(1, testTarget0.int)
        XCTAssertEqual("One", testTarget0.string)
        XCTAssertEqual(Double(2.0), testTarget0.double)
        XCTAssertEqual(Float(10.0), testTarget0.float)
        XCTAssertEqual(false, testTarget0.bool)
        XCTAssertEqual([3, 4, 5], testTarget0.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "3": 3], testTarget0.codableDictionary)
        
        testTarget0.values["IllegalValue"] = "I would have gotten away with it, if it hadn't been for those darned..."
        XCTAssertNotNil(testTarget0.lastError)
        if let lastError = testTarget0.lastError, case let RVS_PersistentPrefs.PrefsError.incorrectKeys(valueList) = lastError {
            XCTAssertEqual(["IllegalValue"], valueList)
        }
        
        // Make sure the bad value didn't pee in the pool.
        XCTAssertNil(testTarget0.values["IllegalValue"])
        // And that all the rest of the values are fine.
        XCTAssertEqual(1, testTarget0.int)
        XCTAssertEqual("One", testTarget0.string)
        XCTAssertEqual(Double(2.0), testTarget0.double)
        XCTAssertEqual(Float(10.0), testTarget0.float)
        XCTAssertEqual(false, testTarget0.bool)
        XCTAssertEqual([3, 4, 5], testTarget0.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "3": 3], testTarget0.codableDictionary)
        
        // Try with multiple illegal entries.
        let testTarget1 = MixedSimpleTypeTestClass(key: testKey, values: ["Illegal1": "BANG", "Illegal2": "CRASH", "Illegal3": "POW"])
        XCTAssertNotNil(testTarget1.lastError)
        if let lastError = testTarget1.lastError, case let RVS_PersistentPrefs.PrefsError.incorrectKeys(valueList) = lastError {
            XCTAssertEqual(["Illegal1", "Illegal2", "Illegal3"], valueList.sorted())
        }
        // We should still have the old correct entries.
        XCTAssertEqual(1, testTarget1.int)
        XCTAssertEqual("One", testTarget1.string)
        XCTAssertEqual(Double(2.0), testTarget1.double)
        XCTAssertEqual(Float(10.0), testTarget1.float)
        XCTAssertEqual(false, testTarget1.bool)
        XCTAssertEqual([3, 4, 5], testTarget1.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "3": 3], testTarget1.codableDictionary)
    }
    
    /* ################################################################## */
    /**
     Test the subscript functionality.
     */
    func testSubscript() {
        let testKey = "testSubscript-1"   // The prefs key that we'll be using for this test.
        
        // What we do here, is create a throwaway instance that exists only to make sure that some defaults are set.
        let initialSet: [String: Any] = ["Int": 1, "String": "One", "Double": Double(2.0), "Float": Float(10.0), "Bool": false, "CodableArray": [3, 4, 5], "CodableDictionary": ["One": 1, "Two": 2, "3": 3]]
        _ = MixedSimpleTypeTestClass(key: testKey, values: initialSet)
        
        // Set up a new instance. It should have all the ones in the initial set.
        let testTarget0 = MixedSimpleTypeTestClass(key: testKey)
        XCTAssertNil(testTarget0.lastError)
        XCTAssertEqual(1, testTarget0.int)
        XCTAssertEqual("One", testTarget0.string)
        XCTAssertEqual(Double(2.0), testTarget0.double)
        XCTAssertEqual(Float(10.0), testTarget0.float)
        XCTAssertEqual(false, testTarget0.bool)
        XCTAssertEqual([3, 4, 5], testTarget0.codableArray)
        XCTAssertEqual(["One": 1, "Two": 2, "3": 3], testTarget0.codableDictionary)
        
        // Simply test changing the integer value directly.
        testTarget0["Int"] = 10
        XCTAssertEqual(10, (testTarget0["Int"] as? Int) ?? 0)
        XCTAssertEqual(10, testTarget0.int)
        // And go directly to the values.
        testTarget0.values["Int"] = 20
        XCTAssertEqual(20, (testTarget0["Int"] as? Int) ?? 0)
        XCTAssertEqual(20, testTarget0.int)

        // This is evil, but allowed. Since it's a Dictionary of Any, we can assign a different type.
        testTarget0["CodableDictionary"] = "Hello, World!"
        XCTAssertEqual("Hello, World!", (testTarget0["CodableDictionary"] as? String) ?? "")
        // And here, we go directly into the values calculated property, and change it to an Int.
        testTarget0.values["CodableDictionary"] = 24
        XCTAssertEqual(24, (testTarget0["CodableDictionary"] as? Int) ?? 0)
        
        // Test changing the integer value directly, but coerce it into a String.
        testTarget0["Int"] = "10"
        // This will now fail.
        XCTAssertEqual(0, testTarget0.int)
        XCTAssertEqual(0, (testTarget0["Int"] as? Int) ?? 0)
        XCTAssertEqual("10", (testTarget0["Int"] as? String) ?? "")
        
        // Change it back into an Int.
        testTarget0["Int"] = 10
        XCTAssertEqual(10, testTarget0.int)
    }
}
