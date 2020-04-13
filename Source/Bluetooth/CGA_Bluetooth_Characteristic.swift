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
    struct ExtensionProperties: OptionSet {
        let rawValue: UInt16
        
        static let notifications = 1 << 0
        
        static let indications = 1 << 1
        
        init(rawValue inRawValue: UInt16 = 0) {
            rawValue = inRawValue
        }
    }
    
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
    var scanCriteria: CGA_Bluetooth_CentralManager.ScanCriteria! { service?.scanCriteria }

    /* ################################################################## */
    /**
     The UUID of this Characteristic.
     */
    var id: String { cbElementInstance?.uuid.uuidString ?? "ERROR" }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write (eithe with or without response).
     */
    var canWrite: Bool { canWriteWithResponse || canWriteWithoutResponse }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write, and returns a receipt response.
     */
    var canWriteWithResponse: Bool { cbElementInstance?.properties.contains(.write) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write, and does not return a response.
     */
    var canWriteWithoutResponse: Bool { cbElementInstance?.properties.contains(.writeWithoutResponse) ?? false }

    /* ################################################################## */
    /**
     Returns true, if the Characteristic can be read.
     */
    var canRead: Bool { cbElementInstance?.properties.contains(.read) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can notify.
     */
    var canNotify: Bool { cbElementInstance?.properties.contains(.notify) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can broadcast.
     */
    var canBroadcast: Bool { cbElementInstance?.properties.contains(.broadcast) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can indicate.
     */
    var canIndicate: Bool { cbElementInstance?.properties.contains(.indicate) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic is currently notifying.
     */
    var isNotifying: Bool { cbElementInstance?.isNotifying ?? false }

    /* ################################################################## */
    /**
     Returns the maximum number of bytes that can be written for this Peripheral.
     */
    var maximumWriteLength: Int { service?.peripheral?.cbElementInstance?.maximumWriteValueLength(for: canWriteWithoutResponse ? .withoutResponse : .withResponse) ?? 0 }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires authenticated writes.
     */
    var requiresAuthenticatedSignedWrites: Bool { cbElementInstance?.properties.contains(.authenticatedSignedWrites) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires encrypted notification.
     */
    var requiresNotifyEncryption: Bool { cbElementInstance?.properties.contains(.notifyEncryptionRequired) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires encrypted indicates.
     */
    var requiresIndicateEncryption: Bool { cbElementInstance?.properties.contains(.indicateEncryptionRequired) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic has extension properties.
     */
    var hasExtendedProperties: Bool { cbElementInstance?.properties.contains(.extendedProperties) ?? false }
    
    /* ################################################################## */
    /**
     This will return any extension properties, as an OptionSet, or nil, if there are none.
     */
    var extendedProperties: ExtensionProperties? {
        guard hasExtendedProperties else { return nil }
        
        let extensionDescriptors = sequence_contents.filter { CBUUIDCharacteristicExtendedPropertiesString == $0.cbElementInstance.uuid.uuidString }
        if  1 == extensionDescriptors.count,
            let value = extensionDescriptors[0].value as? NSNumber {
            return ExtensionProperties(rawValue: value.uint16Value)
        }
        return nil
    }

    /* ################################################################## */
    /**
     If the Characteristic has a value, it is returned here.
     */
    var value: Data? { cbElementInstance?.value }
    
    /* ################################################################## */
    /**
     This returns the parent Central Manager
     */
    var central: CGA_Bluetooth_CentralManager? { parent?.central }

    /* ################################################################## */
    /**
     If the Characteristic has a value, and that value can be expressed as a String, it is returned here.
     */
    var stringValue: String? { nil != value ? String(data: value!, encoding: .utf8) : nil }
    
    /* ################################################################## */
    /**
     TODO: NOT IMPLEMENTED YET
     */
    var intValue: Int64? { nil }
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
     Called to add a Descriptor to our main Array.
     
     - parameter inDescriptor: The Descriptor to add.
     */
    func addDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor) {
        #if DEBUG
            print("Adding the \(inDescriptor.id) Descriptor to the \(self.id) Characteristic.")
        #endif
        sequence_contents.append(inDescriptor)
        central?.updateThisDescriptor(inDescriptor)
    }
    
    /* ################################################################## */
    /**
     If we have read permission, the Peripheral is asked to read our value.
     */
    func readValue() {
        if  canRead,
            let peripheralWrapper = service?.peripheral,
            let peripheral = peripheralWrapper.cbElementInstance {
            #if DEBUG
                print("Reading the value for the \(self.id) Characteristic.")
            #endif
            peripheral.readValue(for: cbElementInstance)
        }
    }
    
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
    
    /* ################################################################## */
    /**
     Tells the Peripheral to start notifying on this Characteristic.
     
     - returns: True, if the request was made (not a guarantee of success, though).
     */
    func startNotifying() -> Bool {
        if  let characteristic = cbElementInstance,
            let peripheral = service?.peripheral?.cbElementInstance {
            peripheral.setNotifyValue(true, for: characteristic)
            return true
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     Tells the Peripheral to stop notifying on this Characteristic.
     
     - returns: True, if the request was made (not a guarantee of success, though).
     */
    func stopNotifying() -> Bool {
        if  isNotifying,
            let characteristic = cbElementInstance,
            let peripheral = service?.peripheral?.cbElementInstance {
            peripheral.setNotifyValue(false, for: characteristic)
            return true
        }
        
        return false
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Characteristic: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This eliminates all of the stored results, and asks the Bluetooth subsystem to start over from scratch.
     */
    func startOver() {
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
            
            central?.reportError(.internalError(nil))
        }
    }
}
