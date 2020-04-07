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
// MARK: - Main Characteristic Wrapper Class -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of CBCharacteristic, adding some functionality, and linking the hierarchy.
 */
class CGA_Bluetooth_Characteristic: RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This is the type we're aggregating.
     */
    typealias Element = CGA_Bluetooth_Descriptor
    
    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    var sequence_contents: Array<Element> = []

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Service
     */
    weak var parent: CGA_Class_Protocol?

    /* ################################################################## */
    /**
     This holds the instance of CBCharacteristic that is used by this instance.
     */
    weak var cbElementInstance: CBCharacteristic!
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequence_Contents: [Element]) {
        sequence_contents = inSequence_Contents
    }
}

/* ###################################################################################################################################### */
// MARK: - Computed Properties -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     This casts the parent as a Service Wrapper.
     */
    var service: CGA_Bluetooth_Service! { parent as? CGA_Bluetooth_Service }
        
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    var scanCriteria: CGA_Bluetooth_CentralManager.ScanCriteria! { (parent as? CGA_Bluetooth_Service)?.scanCriteria }

    /* ################################################################## */
    /**
     The UUID of this Characteristic.
     */
    var id: String { cbElementInstance?.uuid.uuidString ?? "ERROR" }
    
    /* ################################################################## */
    /**
     */
    var canWrite: Bool { (.write == cbElementInstance?.properties) || (.writeWithoutResponse == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var canWriteWithoutResponse: Bool { (.writeWithoutResponse == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var canRead: Bool { (.read == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var canNotify: Bool { (.notify == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var canBroadcast: Bool { (.broadcast == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var canIndicate: Bool { (.indicate == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var requiresAuthenticatedSignedWrites: Bool { (.authenticatedSignedWrites == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var requiresNotifyEncryption: Bool { (.notifyEncryptionRequired == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var requiresIndicateEncryption: Bool { (.indicateEncryptionRequired == cbElementInstance?.properties) }
    
    /* ################################################################## */
    /**
     */
    var hasExtendedProperties: Bool { (.extendedProperties == cbElementInstance?.properties) }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     - parameter parent: The Service instance that "owns" this instance.
     - parameter cbElementInstance: This is the actual CBharacteristic instance to be associated with this instance.
     */
    convenience init(parent inParent: CGA_Bluetooth_Service, cbElementInstance inCBharacteristic: CBCharacteristic) {
        self.init(sequence_contents: [])
        parent = inParent
        cbElementInstance = inCBharacteristic
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance to discover its descriptors.
     */
    func discoverDescriptors() {
        if  let cbPeripheral = ((parent as? CGA_Bluetooth_Service)?.parent as? CGA_Bluetooth_Peripheral)?.cbElementInstance,
            let cbCharacteristic = cbElementInstance {
            clear()
            #if DEBUG
                print("Discovering Descriptors for the \(self.id) Characteristic.")
            #endif
            cbPeripheral.discoverDescriptors(for: cbCharacteristic)
        } else {
            #if DEBUG
                print("ERROR! Can't get characteristic, service and/or peripheral!")
            #endif
        }
    }

    /* ################################################################## */
    /**
     Called to add a Descriptor to our main Array.
     
     - parameter inDescriptor: The Descriptor to add.
     */
    func addDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor) {
        #if DEBUG
            print("Adding the \(inDescriptor.id) Descriptor to the \(self.id) Characteristic.")
        #endif
        sequence_contents.append(inDescriptor)
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Characteristic: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This eliminates all of the stored Descriptors.
     */
    func clear() {
        #if DEBUG
            print("Clearing the decks for A Characteristic: \(self.id).")
        #endif
        
        sequence_contents = []
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Characteristics Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Characteristics, looking for an exact instance.
 */
extension Array where Element == CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Characteristic.
     
     - parameter inItem: The CBCharacteristic we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBCharacteristic) -> Element! {
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
     Removes the element (as a CBCharacteristic).
     
     - parameter inItem: The CB element we're looking to remove.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisCharacteristic(_ inItem: CBCharacteristic) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            guard let testCharacteristic = test.cbElementInstance else { return false }
            if testCharacteristic === inItem {
                success = true
                return true
            } else if testCharacteristic.uuid.uuidString == inItem.uuid.uuidString {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBCharacteristic) -> Bool { nil != self[inItem] }
}
