/*
 This is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 2 of the License, or
 (at your option) any later version.
 
 This Software is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this code.  If not, see <http: //www.gnu.org/licenses/>.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import Foundation

/* ###################################################################################################################################### */
/**
 These are a variety of cool String extensions that add some great extra cheese on the pizza.
 */
public extension StringProtocol {
    /* ################################################################## */
    /**
     - returns: the localized string (main bundle) for this string.
     */
    var localizedVariant: String {
        return NSLocalizedString(String(self), comment: "") // Need to force self into a String.
    }
    
    /* ################################################################## */
    /**
     From here: https://stackoverflow.com/q/24123518/879365, but modified from here: https://stackoverflow.com/a/55639723/879365
     - returns: an MD5 hash of the String
     */
    var md5: String {
        var hash = ""
        
        // Start by getting a C-style string of our string as UTF-8.
        if let str = self.cString(using: .utf8) {
            // This is a cast for the MD5 function. The convention attribute just says that it's a "raw" C function.
            typealias CC_MD5_Type = @convention(c) (UnsafeRawPointer, UInt32, UnsafeMutableRawPointer) -> UnsafeMutableRawPointer
            
            // This is a flag, telling the name lookup to happen in the global scope. No dlopen required.
            let RTLD_DEFAULT = UnsafeMutableRawPointer(bitPattern: -2)
            
            // This loads a function pointer with the CommonCrypto MD5 function.
            let CC_MD5 = unsafeBitCast(dlsym(RTLD_DEFAULT, "CC_MD5")!, to: CC_MD5_Type.self)
            
            // This is the length of the hash
            let CC_MD5_DIGEST_LENGTH = 16
            
            // This is where our MD5 hash goes. It's a simple 16-byte buffer.
            let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: CC_MD5_DIGEST_LENGTH)
            
            // Execute the MD5 hash. Save the result in our buffer.
            _ = CC_MD5(str, CUnsignedInt(str.count), result)
            
            // Turn it into a normal Swift String of hex digits.
            for i in 0..<CC_MD5_DIGEST_LENGTH {
                hash.append(String(format: "%02x", result[i]))
            }
            
            // Don't need this anymore.
            result.deallocate()
        }
        
        return hash
    }
    
    /* ################################################################## */
    /**
     This extension lets us uppercase only the first letter of the string (used for weekdays).
     From here: https://stackoverflow.com/a/28288340/879365
     
     - returns: The string, with only the first letter uppercased.
     */
    var firstUppercased: String {
        guard let first = self.first else { return "" }
        return String(first).uppercased() + self.dropFirst()
    }
    
    /* ################################################################## */
    /**
     The following calculated property comes from this: http://stackoverflow.com/a/27736118/879365
     
     This extension function cleans up a URI string.
     
     - returns: a string, cleaned for URI.
     */
    var urlEncodedString: String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        if let ret = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet) {
            return ret
        } else {
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     The opposite of the above
     
     This extension function cleans up a URI string.
     
     - returns: a string, cleaned for URI.
     */
    var urlDecodedString: String? {
        if let ret = self.removingPercentEncoding {
            return ret
        } else {
            return ""
        }
    }
}

/* ###################################################################################################################################### */
/**
 This extension will allow searching and indexing substrings. It comes straight from here: https://stackoverflow.com/a/32306142/879365
 */
public extension StringProtocol where Index == String.Index {
    /* ################################################################## */
    /**
     This allows us to find the first index of a substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: The index of the first occurrence. Nil, if does not occur.
     */
    func index(of inString: Self, options inOptions: String.CompareOptions = []) -> Index? {
        return range(of: inString, options: inOptions)?.lowerBound
    }
    
    /* ################################################################## */
    /**
     This allows us to find the last index of a substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: The index of the last occurrence. Nil, if does not occur.
     */
    func endIndex(of inString: Self, options inOptions: String.CompareOptions = []) -> Index? {
        return range(of: inString, options: inOptions)?.upperBound
    }
    
    /* ################################################################## */
    /**
     This returns an Array of indexes that map all the occurrences of a given substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: an Array, containing the indexes of each occurrence. Empty Array, if does not occur.
     */
    func indexes(of inString: Self, options inOptions: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        
        while start < endIndex, let range = self[start..<endIndex].range(of: inString, options: inOptions) {
            result.append(range.lowerBound)
            start = range.lowerBound < range.upperBound ? range.upperBound: index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        
        return result
    }
    
    /* ################################################################## */
    /**
     This returns an Array of Index Ranges that map all the occurrences of a given substring.
     
     - parameter of: The substring we're looking for.
     - parameter options: The String options for the search.
     
     - returns: an Array, containing the Ranges that map each occurrence. Empty Array, if does not occur.
     */
    func ranges(of inString: Self, options inOptions: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex,
            let range = self[start..<endIndex].range(of: inString, options: inOptions) {
                result.append(range)
                start = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
