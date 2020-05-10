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

import Foundation

/* ################################################################################################################################## */
// MARK: - Shared Prefs Subclass
/* ################################################################################################################################## */
/**
 This class is the concrete subclass of RVS_PersistentPrefs that implements a few simple data types.
 It is designed to be KVO, so it can be accessed without coding.
 */
public class RVS_PersistentPrefs_TestSet: RVS_PersistentPrefs {
    /* ############################################################################################################################## */
    // MARK: - Private Static Variables
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is an Array of String, containing the keys used to store and retrieve the values from persistent storage.
     */
    private static let _myKeys: [String] = ["Integer Value", "String Value", "Array Value", "Dictionary Value", "Date Value"]
    
    /* ################################################################## */
    /**
     This Dictionary contains our default (initial) values for the contained data.
     */
    private static let _myValues: [String: Any] = ["Integer Value": 12345, "String Value": "Any String", "Array Value": ["One", "Two", "Three", "Four", "Five"], "Dictionary Value": ["One": "1", "Two": "2", "Three": "3", "Four": "4", "Five": "5"], "Date Value": Date()]
    
    /* ############################################################################################################################## */
    // MARK: - Private Enums
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     These are indexes, into the main keys Array. They represent different types of stored properties.
     */
    private enum _ValueIndexes: Int {
        /// Simple arbitrary Integer value
        case int
        /// Simple arbitrary String value
        case string
        /// An Array of String
        case array
        /// A Dictionary of String, keyed by String
        case dictionary
        /// A Date object
        case date
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties (Override)
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is an Array of String, containing the keys used to store and retrieve the values from persistent storage. READ-ONLY
     */
    override public var keys: [String] {
        return type(of: self)._myKeys
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The Integer Value. READ-WRITE
     */
    @objc dynamic public var int: Int {
        get {
            if let ret = values[keys[_ValueIndexes.int.rawValue]] as? Int {
                return ret
            } else {
                #if DEBUG
                    print("No legal variant of Integer Value")
                #endif
                return 0
            }
        }
        
        set {
            return values[keys[_ValueIndexes.int.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Integer Value. READ-ONLY
     */
    @objc dynamic public var intKey: String {
        return keys[_ValueIndexes.int.rawValue]
    }
    
    /* ################################################################## */
    /**
     The String Value. READ-WRITE
     */
    @objc dynamic public var string: String {
        get {
            let value = values[keys[_ValueIndexes.string.rawValue]] as? String ?? ""
            return value
        }
        
        set {
            return values[keys[_ValueIndexes.string.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the String Value. READ-ONLY
     */
    @objc dynamic public var stringKey: String {
        return keys[_ValueIndexes.string.rawValue]
    }

    /* ################################################################## */
    /**
     The Array<String> Value. READ-WRITE
     */
    @objc dynamic public var array: [String] {
        get {
            return values[keys[_ValueIndexes.array.rawValue]] as? [String] ?? []
        }
        
        set {
            return values[keys[_ValueIndexes.array.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Array Value. READ-ONLY
     */
    @objc dynamic public var arrayKey: String {
        return keys[_ValueIndexes.array.rawValue]
    }

    /* ################################################################## */
    /**
     The Dictionary<String, String> Value. READ-WRITE
     */
    @objc dynamic public var dictionary: [String: String] {
        get {
            return values[keys[_ValueIndexes.dictionary.rawValue]] as? [String: String] ?? [:]
        }
        
        set {
            return values[keys[_ValueIndexes.dictionary.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Dictionary Value. READ-ONLY
     */
    @objc dynamic public var dictionaryKey: String {
        return keys[_ValueIndexes.dictionary.rawValue]
    }

    /* ################################################################## */
    /**
     The Date Value. READ-WRITE
     */
    @objc dynamic public var date: Date {
        get {
            return values[keys[_ValueIndexes.date.rawValue]] as? Date ?? Date()
        }
        
        set {
            return values[keys[_ValueIndexes.date.rawValue]] = newValue
        }
    }
    
    /* ################################################################## */
    /**
     The Key (the Label) for the Date Value. READ-ONLY
     */
    @objc dynamic public var dateKey: String {
        return keys[_ValueIndexes.date.rawValue]
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This resets everything to the default settings.
     */
    public func reset() {
        values = type(of: self)._myValues
        if let appDomain: String = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }

    /* ############################################################################################################################## */
    // MARK: - Public Init
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The keyed initializer. It sends in our default values, if there were no previous ones. Bit primitive, but this is for test harnesses.
     */
    public init(key inKey: String) {
        super.init(key: inKey)  // Start by initializing with the key. This will load any saved values.
        if values.isEmpty { // If we didn't already have something, we send in our defaults.
            values = type(of: self)._myValues
        }
    }
}
