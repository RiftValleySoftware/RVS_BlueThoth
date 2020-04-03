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
// MARK: - CBPeripheral Wrapper Class -
/* ###################################################################################################################################### */
/**
 This class is instantiated when a Peripheral is connected, and will handle discovery of Services, Characteristics and Descriptors.
 */
class CGA_Bluetooth_Peripheral: NSObject, RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This is the type we're aggregating.
     */
    typealias Element = CGA_Bluetooth_Service
    
    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    var sequence_contents: Array<Element> = []
    
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Parent instance.
     */
    weak var parent: CGA_Class_Protocol?

    /* ################################################################## */
    /**
     This returns the instance of CBPeripheral that is used by this instance.
     */
    var cbElementInstance: CBPeripheral! { discoveryData?.cbPeripheral }
    
    /* ################################################################## */
    /**
     This holds the discovery data that applies to this instance.
     */
    var discoveryData: CGA_Bluetooth_CentralManager.DiscoveryData!
    
    /* ################################################################## */
    /**
     This casts the parent as a Central Manager.
     */
    var central: CGA_Bluetooth_CentralManager! { parent as? CGA_Bluetooth_CentralManager }

    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequence_Contents: [Element]) {
        sequence_contents = inSequence_Contents
        super.init()    // Since we derive from NSObject, we must call the super init()
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral {
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     - parameter discoveryData: The discovery data of the Peripheral.
     */
    convenience init(discoveryData inCBPeriperalDiscoveryData: CGA_Bluetooth_CentralManager.DiscoveryData) {
        self.init(sequence_contents: [])
        discoveryData = inCBPeriperalDiscoveryData
        cbElementInstance?.delegate = self
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_Protocol Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This is the required conformance method to update the collection.
     */
    func updateCollection() {
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral: CBPeripheralDelegate {
    
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Peripherals Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Peripherals, looking for an exact instance.
 */
extension Array where Element == CGA_Bluetooth_Peripheral {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Peripheral
     
     - parameter inItem: The Peripheral we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBPeripheral) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                if nextItem === inItem {
                    return nextItem
                } else if nextItem.cbElementInstance.identifier == inItem.identifier {
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
    func contains(_ inItem: CBPeripheral) -> Bool {
        return nil != self[inItem]
    }
    
    /* ################################################################## */
    /**
     Removes the element (as a CBPeripheral).
     
     - parameter inItem: The CB element we're looking to remove, as the opaque type.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisDevice(_ inItem: CBPeripheral) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            guard let testPeripheral = test.discoveryData?.cbPeripheral else { return false }
            if testPeripheral === inItem {
                success = true
                return true
            } else if testPeripheral.identifier.uuidString == inItem.identifier.uuidString {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }
}
