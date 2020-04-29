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

import CoreBluetooth

/* ###################################################################################################################################### */
// MARK: - Main Characteristic Wrapper Class -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of CBCharacteristic, adding some functionality, and linking the hierarchy.
 */
public class CGA_Bluetooth_Characteristic: CGA_Bluetooth_Characteristic_Protocol_Internal {
    /* ################################################################## */
    /**
     This is the type we're aggregating. We aggregate the public face of the Descriptors.
     */
    public typealias Element = CGA_Bluetooth_Descriptor_Protocol

    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    public var sequence_contents: Array<Element> = []

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Service
     */
    public weak var parent: CGA_Class_Protocol?

    /* ################################################################## */
    /**
     This holds the instance of CBCharacteristic that is used by this instance.
     */
    public weak var cbElementInstance: CBCharacteristic!

    /* ################################################################## */
    /**
     The UUID of this Characteristic.
     */
    public var id: String { cbElementInstance?.uuid.uuidString ?? "ERROR" }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write (eithe with or without response).
     */
    public var canWrite: Bool { canWriteWithResponse || canWriteWithoutResponse }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write, and returns a receipt response.
     */
    public var canWriteWithResponse: Bool { cbElementInstance?.properties.contains(.write) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write, and does not return a response.
     */
    public var canWriteWithoutResponse: Bool { cbElementInstance?.properties.contains(.writeWithoutResponse) ?? false }

    /* ################################################################## */
    /**
     Returns true, if the Characteristic can be read.
     */
    public var canRead: Bool { cbElementInstance?.properties.contains(.read) ?? false }

    /* ################################################################## */
    /**
     Returns true, if the Characteristic can notify.
     */
    public var canNotify: Bool { cbElementInstance?.properties.contains(.notify) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can broadcast.
     */
    public var canBroadcast: Bool { cbElementInstance?.properties.contains(.broadcast) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can indicate.
     */
    public var canIndicate: Bool { cbElementInstance?.properties.contains(.indicate) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic is currently notifying.
     */
    public var isNotifying: Bool { cbElementInstance?.isNotifying ?? false }

    /* ################################################################## */
    /**
     Returns the maximum number of bytes that can be written for this Peripheral.
     */
    public var maximumWriteLength: Int { service?.peripheral?.cbElementInstance?.maximumWriteValueLength(for: canWriteWithoutResponse ? .withoutResponse : .withResponse) ?? 0 }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires authenticated writes.
     */
    public var requiresAuthenticatedSignedWrites: Bool { cbElementInstance?.properties.contains(.authenticatedSignedWrites) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires encrypted notification.
     */
    public var requiresNotifyEncryption: Bool { cbElementInstance?.properties.contains(.notifyEncryptionRequired) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires encrypted indicates.
     */
    public var requiresIndicateEncryption: Bool { cbElementInstance?.properties.contains(.indicateEncryptionRequired) ?? false }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic has extension properties.
     */
    public var hasExtendedProperties: Bool { cbElementInstance?.properties.contains(.extendedProperties) ?? false }
    
    /* ################################################################## */
    /**
     If the Characteristic has a value, and that value can be expressed as a String, it is returned here.
     This computed property is defined here, so it can be overridden by subclasses.
     */
    public var stringValue: String? { nil != value ? String(data: value!, encoding: .utf8) : nil }
    
    /* ################################################################## */
    /**
     Returns the number (if possible) as an Int64. This assumes littlendian.
     This computed property is defined here, so it can be overridden by subclasses.
     */
    public var intValue: Int64? {
        guard var data = value else { return nil }
        var number = Int64(0)
        data.castInto(&number)
        return number
    }
    
    /* ################################################################## */
    /**
     Returns the value as a Boolean. It should be noted that ANY non-zero number will return true.
     This computed property is defined here, so it can be overridden by subclasses.
     */
    public var boolValue: Bool? {
        guard var data = value else { return nil }
        var ret = Bool(false)
        data.castInto(&ret)
        return ret
    }
    
    /* ################################################################## */
    /**
     Returns the value as a Double.
     This computed property is defined here, so it can be overridden by subclasses.
     */
    public var doubleValue: Double? {
        guard var data = value else { return nil }
        var ret = Double(0.0)
        data.castInto(&ret)
        return ret
    }

    /* ################################################################## */
    /**
     This will return any extension properties, as a simple tuple, or nil, if there are none.
     */
    public var extendedProperties: (isIndicating: Bool, isNotifying: Bool)? {
        guard hasExtendedProperties else { return nil }
        let extensionDescriptors = sequence_contents.filter({ CBUUIDCharacteristicExtendedPropertiesString == $0.cbElementInstance.uuid.uuidString })
        guard let extensionDescriptor = extensionDescriptors[0] as? CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration else { return nil }
        return (isIndicating: extensionDescriptor.isIndicating, isNotifying: extensionDescriptor.isNotifying)
    }

    /* ################################################################## */
    /**
     If the Characteristic has a value, it is returned here.
     */
    public var value: Data? { cbElementInstance?.value }
    
    /* ################################################################## */
    /**
     This returns the parent Central Manager
     */
    public var central: RVS_BlueThoth? { parent?.central }
    
    /* ################################################################## */
    /**
     If we have read permission, the Peripheral is asked to read our value.
     */
    public func readValue() {
        if  canRead,
            let peripheralWrapper = service?.peripheral,
            let peripheral = peripheralWrapper.cbElementInstance {
            #if DEBUG
                print("Reading the value for the \(id) Characteristic.")
            #endif
            peripheral.readValue(for: cbElementInstance)
        }
    }
    
    /* ################################################################## */
    /**
     Tells the Peripheral to start notifying on this Characteristic.
     
     - returns: True, if the request was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    public func startNotifying() -> Bool {
        guard   !isNotifying,
                let characteristic = cbElementInstance,
                let peripheral = service?.peripheral?.cbElementInstance else { return false }
        
        peripheral.setNotifyValue(true, for: characteristic)
        return true
    }
    
    /* ################################################################## */
    /**
     Tells the Peripheral to stop notifying on this Characteristic.
     
     - returns: True, if the request was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    public func stopNotifying() -> Bool {
        guard   isNotifying,
                let characteristic = cbElementInstance,
                let peripheral = service?.peripheral?.cbElementInstance else { return false }
        
        peripheral.setNotifyValue(false, for: characteristic)
        return true
    }

    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.

     - parameter sequence_contents: The initial value of the Array cache.
     */
    public required init(sequence_contents inSequence_Contents: [CGA_Bluetooth_Descriptor_Protocol]) {
        sequence_contents = inSequence_Contents
    }
        
    /* ################################################################## */
    /**
     If we have write permission, the Peripheral is asked to write the given data into its value.
     
     - parameter inData: The Data instance to write.
     */
// TODO: Implement this when we can test it.
//    public func writeValue(_ inData: Data) {
//        if  canWrite,
//            let peripheralWrapper = service?.peripheral,
//            let peripheral = peripheralWrapper.cbElementInstance {
//            #if DEBUG
//                print("Writing this value: \(inData) for the \(id) Characteristic.")
//            #endif
//            peripheral.writeValue(inData, for: cbElementInstance, type: canWriteWithoutResponse ? .withoutResponse : .withResponse)
//        }
//    }
    
    // MARK: Internal Properties (Declared here, so it can be overridden).
    
    /* ################################################################## */
    /**
     Root class does nothing.
     */
    internal class var uuid: String { "" }
    
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     - parameter parent: The Service instance that "owns" this instance.
     - parameter cbElementInstance: This is the actual CBharacteristic instance to be associated with this instance.
     */
    internal required convenience init(parent inParent: CGA_Bluetooth_Service, cbElementInstance inCBharacteristic: CBCharacteristic) {
        self.init(sequence_contents: [])
        parent = inParent
        cbElementInstance = inCBharacteristic
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
    public func clear() {
        #if DEBUG
            print("Clearing the decks for A Characteristic: \(id).")
        #endif
        
        sequence_contents = []
    }
    
    /* ################################################################## */
    /**
     This eliminates all of the stored results, and asks the Bluetooth subsystem to start over from scratch.
     */
    public func startOver() {
        if  let cbPeripheral = ((parent as? CGA_Bluetooth_Service)?.parent as? CGA_Bluetooth_Peripheral)?.cbElementInstance,
            let cbCharacteristic = cbElementInstance {
            clear()
            #if DEBUG
                print("Discovering Descriptors for the \(id) Characteristic.")
            #endif
            cbPeripheral.discoverDescriptors(for: cbCharacteristic)
        } else {
            #if DEBUG
                print("ERROR! Can't get characteristic, service and/or peripheral!")
            #endif
            
            central?.reportError(.internalError(error: nil, id: id))
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Internal Computed Properties and Methods -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     This casts the parent as a Service Wrapper.
     */
    internal var service: CGA_Bluetooth_Service! { parent as? CGA_Bluetooth_Service }
        
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    internal var scanCriteria: RVS_BlueThoth.ScanCriteria! { service?.scanCriteria }

    /* ################################################################## */
    /**
     Called to add a Descriptor to our main Array.
     
     - parameter inDescriptor: The Descriptor to add.
     */
    internal func addDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor) {
        #if DEBUG
            print("Adding the \(inDescriptor.id) Descriptor to the \(id) Characteristic.")
        #endif
        sequence_contents.append(inDescriptor)
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_CharacteristicFactory Conformance -
/* ###################################################################################################################################### */
/**
 This allows us to create Characteristics.
 */
extension CGA_Bluetooth_Characteristic: CGA_CharacteristicFactory {
    /* ################################################################## */
    /**
     This instantiates an instance of this class.
     
     - parameter parent: The Service instance that "owns" this Characteristic.
     - parameter cbElementInstance: The CBCharacteristic instance that will be applied to the factory.
     - returns: A new instance of CGA_Bluetooth_Characteristic, or a subclass, thereof. Nil, if it fails.
     */
    internal class func createInstance(parent inParent: CGA_Bluetooth_Service, cbElementInstance inCBCharacteristic: CBCharacteristic) -> CGA_Bluetooth_Characteristic? {
        let ret = Self.init(sequence_contents: [])
        ret.parent = inParent
        ret.cbElementInstance = inCBCharacteristic
        
        return ret
    }
}
