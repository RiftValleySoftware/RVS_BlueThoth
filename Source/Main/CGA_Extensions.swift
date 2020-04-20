/*
© Copyright 2020, The Great Rift Valley Software Company

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

import UIKit

/* ###################################################################################################################################### */
// MARK: - UITableView Extension -
/* ###################################################################################################################################### */
/**
 This extension adds a method for deselecting all the table rows..
 */
extension UITableView {
    /* ################################################################## */
    /**
     This will deselect all selected rows.
     
     - parameter animated: This can be ignored (defaults to false). If true, the deselection is animated.
     - returns: an Array of IndexPath, denoting the rows that were deselected. Can be ignored.
     */
    @discardableResult
    func deselectAll(animated inAnimated: Bool = false) -> [IndexPath] {
        if  let indexPaths = indexPathsForSelectedRows,
            !indexPaths.isEmpty {
            indexPaths.forEach { deselectRow(at: $0, animated: inAnimated) }
            
            return indexPaths
        }
        
        return []
    }
}

/* ###################################################################################################################################### */
// MARK: - Bundle Extension -
/* ###################################################################################################################################### */
/**
 This extension adds a few simple accessors for some of the more common bundle items.
 */
extension Bundle {
    /* ################################################################## */
    /**
     The app name, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appDisplayName: String { (object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "ERROR" }

    /* ################################################################## */
    /**
     The app version, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appVersionString: String { object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "ERROR" }
    
    /* ################################################################## */
    /**
     The build version, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appVersionBuildString: String { object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "ERROR" }
    
    /* ################################################################## */
    /**
     If there is a copyright string, it is returned here. It may be nil.
     */
    var copyrightString: String? { object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String }
}
