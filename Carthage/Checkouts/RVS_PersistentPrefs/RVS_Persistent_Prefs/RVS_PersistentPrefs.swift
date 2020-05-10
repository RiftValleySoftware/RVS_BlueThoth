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
 
 Version 1.0.5
 */

import Foundation

/* ################################################################################################################################## */
// MARK: - Main Preferences Base Class
/* ################################################################################################################################## */
/**
 This class is meant to act as an "abstract" base class, providing a simple `Dictionary` datastore that is stored in the [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults) in the Application Bundle. It is designed to be reliable, and extremely simple to use.
 The stored `Dictionary` would be a String-keyed Dictionary of `Any` (flexible types). It s up to subclasses to specialize the typeless data.
 **THIS IS NOT EFFICIENT OR ROBUST!**
 It is meant as a simple "bucket" for things like application preferences. It is not an industrial data storage solution. You have been warned.
 Subclasses could declare their accessors as [`KVO`](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift)-style, thus, providing a direct way to influence persistent state.
 You can also directly observe the .values property. It will change when ANY pref is changed (so might not be suitable for "pick and choose" observation).
 */
public class RVS_PersistentPrefs: NSObject {
    /* ############################################################################################################################## */
    // MARK: - Private Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is the Dictionary. It's private, and shouldn't need to be accessed outside this base class.
     */
    private var _values: [String: Any] = [:]
    
    /* ############################################################################################################################## */
    // MARK: - Private Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is a private method that saves the current contents of the _values Dictionary to persistent storage, keyed by the value of the "key" property.
     
     - throws: An error, if the values are not all codable.
     */
    private func _save() throws {
        if _values.isEmpty {    // Remove ourselves if we are empty.
            UserDefaults.standard.removeObject(forKey: key)
        } else if PropertyListSerialization.propertyList(_values, isValidFor: .xml) {
            UserDefaults.standard.set(_values, forKey: key)
        } else {
            #if DEBUG
                print("Attempt to set non-plist values!")
            #endif
            
            // What we do here, is look through our values list, and record the keys of the elements that are not considered plist-compatible (for XML plists). We return those in the error that we throw.
            var valueElementList: [String] = []
            _values.forEach {
                if PropertyListSerialization.propertyList($0.value, isValidFor: .xml) {
                    #if DEBUG
                        print("\($0.key) is OK")
                    #endif
                } else {
                    #if DEBUG
                        print("\($0.key) is not plist-compliant")
                    #endif
                    valueElementList.append($0.key)
                }
            }
            throw PrefsError.valuesNotPlistCompatible(invalidElements: valueElementList)
        }
    }
    
    /* ################################################################## */
    /**
     This is a private method that reads in the data from persistent storage for this instance (using the "key" property), and loads the _values Dictionary property.
     
     - throws: An error, if there were no stored prefs for the given key.
     */
    private func _load() throws {
        let standardDefaultsObject = UserDefaults.standard
        _values = [:]   // Start clean.

        if let loadedPrefs = standardDefaultsObject.object(forKey: key) as? [String: Any] {
            _values = loadedPrefs
        } else {
            #if DEBUG
                print("Unable to Load Prefs for \"\(key)\"")
            #endif
            throw PrefsError.noStoredPrefsForKey(key: key)
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Enums
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Errors that Can be thrown from methods in this class
     */
    public enum PrefsError: Error {
        /// Some elements were presented that do not fit our keys. The associated value is an Array of the failing keys.
        case incorrectKeys(invalidElements: [String])
        /// Not all of the elements in the _values Dictionary are Plist-Compatible. The associated value is an Array of the failing keys.
        case valuesNotPlistCompatible(invalidElements: [String])
        /// We were not able to find a stored pref for the given key. The associated value is the key we are looking for.
        case noStoredPrefsForKey(key: String)
        /// Unknown thrown error. The associated value is the error (if any).
        case unknownError(error: Error?)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is the key that is used to store and fetch the collection of data to be used to populate the _values Dictionary.
     */
    public var key: String = ""
    
    /* ################################################################## */
    /**
     This is any error that was thrown during a save or a load.
     */
    public var lastError: PrefsError!
    
    /* ################################################################## */
    /**
     The number of stored values.
     */
    var count: Int { values.count }

    /* ############################################################################################################################## */
    // MARK: - Public Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This calculated property MUST be overridden by subclasses.
     It is an Array of String, containing the keys used to store and retrieve the values from persistent storage.
     */
    public var keys: [String] {
        preconditionFailure("YOU MUST OVERRIDE THIS METHOD")
    }
    
    /* ################################################################## */
    /**
     This is an accessor for the _values Dictionary. Before it returns the Dictionary, it loads data from persistent storage.
     After it sets the Dictionary, it saves the resulting Dictionary to persistent storage.
     This is meant to make persistent storage completely transparent.
     You simply read and write the Dictionary, using these accessors. The saving and retrieving happens in the background.
     */
    @objc dynamic public var values: [String: Any] {
        get {
            lastError = nil
            do {
                try _load()
                #if DEBUG
                    print("Successfully Loaded \(_values)")
                #endif
            } catch PrefsError.noStoredPrefsForKey(let unknownKey) {
                lastError = PrefsError.noStoredPrefsForKey(key: unknownKey)
            } catch {
                lastError = PrefsError.unknownError(error: error)
            }
            return _values
        }
        
        set {
            lastError = nil
            let oldValues = _values
            _values = newValue
            var illegalKeys: [String] = []
            
            // What we do here, is "scrub" the values of anything that was added against what is expected.
            let filteredDictionary = newValue.filter { (arg0) -> Bool in
                let (key, _) = arg0
                if keys.contains(key) {
                    return true
                } else {
                    illegalKeys.append(key)
                    return false
                }
            }
            
            _values = filteredDictionary
            
            if !illegalKeys.isEmpty {
                #if DEBUG
                    print("Illegal Keys!")
                #endif
                lastError = PrefsError.incorrectKeys(invalidElements: illegalKeys)
            } else {
                do {
                    try _save()
                    #if DEBUG
                        print("Successfully Saved \(_values)")
                    #endif
                } catch PrefsError.valuesNotPlistCompatible(let unCodableKeys) {
                    lastError = PrefsError.valuesNotPlistCompatible(invalidElements: unCodableKeys)
                    _values = oldValues
                } catch {
                    lastError = PrefsError.unknownError(error: error)
                    _values = oldValues
                }
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Subscript
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is a direct-access subscript that allows you to use the prefs object to reach its stored properties.
     */
    subscript(_ inKey: String) -> Any? {
        get { values[inKey] }
        set { values[inKey] = newValue }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Initializers
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The default initializer uses the current subclass typename as the main key.
     */
    public override init() {
        super.init()
        key = String(describing: Self.self)  // This gives us a simple classname as our key.
        do {
            try _load()
        } catch PrefsError.noStoredPrefsForKey(_) { // We ignore this error for initialization.
            lastError = nil
        } catch PrefsError.incorrectKeys(let unknownKeys) {
            lastError = PrefsError.incorrectKeys(invalidElements: unknownKeys)
        } catch {
            lastError = PrefsError.unknownError(error: error)
        }
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
    public init(key inKey: String! = nil, values inValues: [String: Any]! = [:]) {
        super.init()
        key = inKey ?? String(describing: Self.self)  // This gives us a simple classname as our key.
        
        // First, we load any currently stored prefs. This makes sure that we have a solid starting place.
        do {
            try _load()
        } catch PrefsError.noStoredPrefsForKey(_) { // We ignore this error for initialization.
            lastError = nil
        } catch {
            lastError = PrefsError.unknownError(error: error)
        }
        
        #if DEBUG
            print("Initial Values for \"\(key)\": \(_values)")
        #endif
        
        // Make sure we didn't barf.
        if  nil == lastError,
            !inValues.isEmpty {
            values = _values.merging(inValues, uniquingKeysWith: { (_, new) in new })
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This clears the values, and deletes the pref from the UserDefaults.
     */
    public func clear() {
        values = [:]
    }
}
