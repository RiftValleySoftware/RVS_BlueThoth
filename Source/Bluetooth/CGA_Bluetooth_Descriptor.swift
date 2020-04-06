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

import UIKit
import CoreBluetooth

/* ###################################################################################################################################### */
// MARK: - The Main Wrapper Class for the Descriptors -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of CBDescriptor, adding some functionality, and linking the hierarchy.
 */
class CGA_Bluetooth_Descriptor: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Characteristic
     */
    weak var parent: CGA_Class_Protocol?
    
    /* ################################################################## */
    /**
     This holds the instance of CBDescriptor that is used by this instance.
     */
    weak var cbElementInstance: CBDescriptor!
    
    /* ################################################################## */
    /**
     This casts the parent as a Characteristic Wrapper.
     */
    var characteristic: CGA_Bluetooth_Characteristic! { parent as? CGA_Bluetooth_Characteristic }
    
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    var scanCriteria: CGA_Bluetooth_CentralManager.ScanCriteria! {
        return (parent as? CGA_Bluetooth_Characteristic)?.scanCriteria
    }
    
    /* ################################################################## */
    /**
     This returns a unique UUID String for the instance.
     */
    var id: String {
        cbElementInstance?.uuid.uuidString ?? "ERROR"
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Descriptor Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Descriptors, looking for an exact instance.
 */
extension Array where Element == CGA_Bluetooth_Descriptor {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Descriptor.
     
     - parameter inItem: The CBDescriptor we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBDescriptor) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                if nextItem === inItem {
                    return nextItem
                } else if nextItem.cbElementInstance.uuid == inItem.uuid {
                    return nextItem
                }
                
                return nil
            }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBDescriptor) -> Bool { nil != self[inItem] }
}
