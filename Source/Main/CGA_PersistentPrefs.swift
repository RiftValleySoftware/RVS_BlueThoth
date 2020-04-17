/*
© Copyright 2020, Little Green Viper Software Development LLC

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

Little Green Viper Software Development LLC: https://littlegreenviper.com
*/

/* ###################################################################################################################################### */
// MARK: - The Persistent Prefs Subclass -
/* ###################################################################################################################################### */
/**
 This is the subclass of the preferences type that will provide our persistent app settings.
 */
class CGA_PersistentPrefs: RVS_PersistentPrefs {
    /* ################################################################################################################################## */
    // MARK: - The Persistent Prefs Keys (As An Enum) -
    /* ################################################################################################################################## */
    /**
     This is an enumeration that will list the prefs keys for us.
     */
    enum Keys: String {
        /* ############################################################## */
        /**
         This will be a Boolean value. If true, then the scan will not use duplicate filtering (meaning that it will be continuously updating).
         */
        case continuouslyUpdatePeripherals = "kUpdatePeripherals"
        
        /* ############################################################## */
        /**
         These are all the keys, in an Array of String.
         */
        static var allKeys: [String] { [continuouslyUpdatePeripherals.rawValue] }
    }
    
    /* ################################################################## */
    /**
     This is a list of the keys for our prefs.
     We should use the enum for the keys (rawValue).
     */
    override var keys: [String] { Keys.allKeys }
    
    /* ################################################################## */
    /**
     This is a Boolean value. If true, then the scan will not use duplicate filtering (meaning that it will be continuously updating).
     */
    var continuouslyUpdatePeripherals: Bool {
        get { values[Keys.continuouslyUpdatePeripherals.rawValue] as? Bool ?? false }
        set { values[Keys.continuouslyUpdatePeripherals.rawValue] = newValue }
    }
}
