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

/* ###################################################################################################################################### */
/**
 These are all classes, as opposed to structs, because we want them to be referenced, not copied.
 Remember that Bluetooth is a very dynamic, realtime environment. Caches can be extremely problematic. We want caches, but safe ones.
 */

import Foundation

/* ###################################################################################################################################### */
// MARK: - The Main Protocol for Each Type -
/* ###################################################################################################################################### */
/**
 This protocol is the "base" protocol to which all the exposed types conform.
 */
public protocol CGA_Class_Protocol: class {
    /* ################################################################## */
    /**
     REQUIRED: This is used to reference an "owning instance" of this instance.
     */
    var parent: CGA_Class_Protocol? { get }
    
    /* ################################################################## */
    /**
     REQUIRED: This is used to reference an "owning instance" of this instance.
     */
    var central: RVS_BlueThoth? { get }
    
    /* ################################################################## */
    /**
     REQUIRED: This returns a unique UUID String for the instance.
     */
    var id: String { get }
    
    /* ################################################################## */
    /**
     OPTIONAL: This searches the hierarchy, and will return any instance that has an ID that matches the string passed in.
               This could be a Peripheral, Service, Characteristic or Descriptor. The response will need to be cast.
     
     - parameter inUUIDString: The String for the UUID for which we are searching.
     - returns: Any element in the hierarchy with a UUID that matches the one passed in, or nil.
     */
    func findEntityByUUIDString(_ inUUIDString: String) -> CGA_Class_Protocol?

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: CGA_Errors)
    
    /* ################################################################## */
    /**
     OPTIONAL: Forces the instance to restart its discovery process.
     */
    func startOver()
    
    /* ################################################################## */
    /**
     OPTIONAL: This returns a unique UUID String for the Service or Characteristic, if this is a specialized class.
     */
    static var cbUUIDString: String { get }
}

/* ###################################################################################################################################### */
// MARK: - Protocol Defaults -
/* ###################################################################################################################################### */
extension CGA_Class_Protocol {
    /* ################################################################## */
    /**
     Default is an empty String.
     */
    public static var cbUUIDString: String { "" }

    /* ################################################################## */
    /**
     Default simply passes the buck.
     */
    public func handleError(_ inError: CGA_Errors) {
        parent?.handleError(inError)
    }
    
    /* ################################################################## */
    /**
     Default does nothing.
     */
    public func findEntityByUUIDString(_ inUUIDString: String) -> CGA_Class_Protocol? { nil }
    
    /* ################################################################## */
    /**
     Default does nothing.
     */
    public func startOver() { }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_Protocol_UpdateService Protocol -
/* ###################################################################################################################################### */
/**
 This protocol defines an interface for a message that indicates that a Service object needs to be refreshed.
 */
public protocol CGA_Class_Protocol_UpdateService: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This is called to inform an instance that a Service downstream changed.
     
     - parameter service: The Service wrapper instance that changed.
     */
    func updateThisService(_ service: CGA_Bluetooth_Service)
}

/* ###################################################################################################################################### */
// MARK: - Protocol Defaults -
/* ###################################################################################################################################### */
extension CGA_Class_Protocol_UpdateService {
    /* ################################################################## */
    /**
     Default simply passes the buck.
     */
    public func updateThisService(_ inService: CGA_Bluetooth_Service) {
        (parent as? CGA_Class_Protocol_UpdateService)?.updateThisService(inService)
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_Protocol_UpdateCharacteristic Protocol -
/* ###################################################################################################################################### */
/**
 This protocol defines an interface for a message that indicates that a Characteristic object needs to be refreshed.
 It also specifies a method to "clear" the stored Descriptors
*/
public protocol CGA_Class_Protocol_UpdateCharacteristic: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This eliminates all of the stored data.
     */
    func clear()
    
    /* ################################################################## */
    /**
     This is called to inform an instance that a Characteristic downstream changed.
     
     - parameter characteristic: The Characteristic wrapper instance that changed.
     */
    func updateThisCharacteristic(_ characteristic: CGA_Bluetooth_Characteristic)
}

/* ###################################################################################################################################### */
// MARK: - Protocol Defaults -
/* ###################################################################################################################################### */
extension CGA_Class_Protocol_UpdateCharacteristic {
    /* ################################################################## */
    /**
     Default simply passes the buck.
     */
    public func updateThisCharacteristic(_ inCharacteristic: CGA_Bluetooth_Characteristic) {
        (parent as? CGA_Class_Protocol_UpdateCharacteristic)?.updateThisCharacteristic(inCharacteristic)
    }
}

/* ###################################################################################################################################### */
// MARK: - The CGA_Class_Protocol_UpdateDescriptor Protocol -
/* ###################################################################################################################################### */
/**
This protocol defines an interface for a message that indicates that a Descriptor object needs to be refreshed.
*/
public protocol CGA_Class_Protocol_UpdateDescriptor: CGA_Class_Protocol_UpdateCharacteristic {
    /* ################################################################## */
    /**
     This is called to inform an instance that a Descriptor downstream changed.
     
     - parameter descriptor: The Descriptor wrapper instance that changed.
     */
    func updateThisDescriptor(_ descriptor: CGA_Bluetooth_Descriptor)
}

/* ###################################################################################################################################### */
// MARK: - Protocol Defaults -
/* ###################################################################################################################################### */
extension CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     Default simply passes the buck.
     */
    public func updateThisDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor) {
        (parent as? CGA_Class_Protocol_UpdateDescriptor)?.updateThisDescriptor(inDescriptor)
    }
}

/* ###################################################################################################################################### */
// MARK: - The Central Manager Delegate Protocol -
/* ###################################################################################################################################### */
/**
 All delegate callbacks are made in the main thread.
 This is the only delegate for the BlueThoth framework. All events in the system come to this one place.
 */
public protocol CGA_BlueThoth_Delegate: class {
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: CGA_Errors, from: RVS_BlueThoth)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to update its data.
               NOTE: There may be no changes, or many changes. What has changed is not specified.
     
     - parameter centralManager: The central manager that is calling this.
     */
    func updateFrom(_ centralManager: RVS_BlueThoth)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that the state of the Central manager just became "powered on."
     
     - parameter centralManager: The central manager that is calling this.
     */
    func centralManagerPoweredOn(_ centralManager: RVS_BlueThoth)

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Peripheral device has been connected.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter didConnectThisDevice: The device instance that was connected.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, didConnectThisDevice: CGA_Bluetooth_Peripheral)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a peripheral device is about to be disconnected.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter willDisconnectThisDevice: The device instance that will be removed after this call.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, willDisconnectThisDevice: CGA_Bluetooth_Peripheral)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Peripheral device has had some change.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter deviceInfoChanged: The device instance that was changed.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, deviceInfoChanged: CGA_Bluetooth_Peripheral)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Peripheral device is ready for a write.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter deviceReadyForWrite: The device instance that is ready for a write.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, deviceReadyForWrite: CGA_Bluetooth_Peripheral)

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Service changed.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter changedService: The Service instance that was changed.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, device: CGA_Bluetooth_Peripheral, changedService: CGA_Bluetooth_Service)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Characteristic write with response received its response.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter characteristicWriteComplete: The Characteristic that had its write completed.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, characteristicWriteComplete: CGA_Bluetooth_Characteristic)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Characteristic changed its notification state.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter changedCharacteristicNotificationState: The Characteristic that was changed.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, changedCharacteristicNotificationState: CGA_Bluetooth_Characteristic)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Characteristic changed its value.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter changedCharacteristic: The Characteristic that was changed.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, changedCharacteristic: CGA_Bluetooth_Characteristic)

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Descriptor changed its value.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter characteristic: The Characteristic that contains the Descriptor that was changed.
     - parameter changedDescriptor: The Descriptor that was changed.
     */
    func centralManager(_ centralManager: RVS_BlueThoth, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, characteristic: CGA_Bluetooth_Characteristic, changedDescriptor: CGA_Bluetooth_Descriptor)
}

/* ###################################################################################################################################### */
// MARK: - The Central Manager Delegate Defaults -
/* ###################################################################################################################################### */
extension CGA_BlueThoth_Delegate {
    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func handleError(_ inError: Error, from: RVS_BlueThoth) {
        #if DEBUG
            print("Default Protocol Error Received: \(inError)")
        #endif
    }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func updateFrom(_ inCentral: RVS_BlueThoth) {
        #if DEBUG
            print("Default Protocol Central Update Received: \(inCentral)")
        #endif
    }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManagerPoweredOn(_ inCentral: RVS_BlueThoth) {
        #if DEBUG
            print("Default Protocol Central Powered On Received: \(inCentral)")
        #endif
    }

    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, didConnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) connected: \(inDevice)")
        #endif
    }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, willDisconnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) will disconnect: \(inDevice)")
        #endif
    }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, deviceInfoChanged inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) device info changed: \(inDevice)")
        #endif
    }

    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, deviceReadyForWrite inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) device ready for write: \(inDevice)")
        #endif
    }

    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, changedService inService: CGA_Bluetooth_Service) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) device: \(inDevice) Service changed: \(inService)")
        #endif
    }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, characteristicWriteComplete inCharacteristic: CGA_Bluetooth_Characteristic) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) device: \(inDevice) Service: \(inService) Characteristic write complete: \(inCharacteristic)")
        #endif
    }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, changedCharacteristicNotificationState inCharacteristic: CGA_Bluetooth_Characteristic) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) device: \(inDevice) Service: \(inService) Characteristic: \(inCharacteristic) changed its notification state to: \(inCharacteristic.isNotifying ? "ON" : "OFF")")
        #endif
    }

    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, changedCharacteristic inCharacteristic: CGA_Bluetooth_Characteristic) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) device: \(inDevice) Service: \(inService) Characteristic changed: \(inCharacteristic)")
        #endif
    }

    /* ################################################################## */
    /**
     The default does nothing.
     */
    public func centralManager(_ inCentral: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, characteristic inCharacteristic: CGA_Bluetooth_Characteristic, changedDescriptor inDescriptor: CGA_Bluetooth_Descriptor) {
        #if DEBUG
            print("Default Protocol Central: \(inCentral) device: \(inDevice) Service: \(inService) Characteristic: \(inCharacteristic) Descriptor changed: \(inDescriptor)")
        #endif
    }
}

/* ###################################################################################################################################### */
// MARK: - Writaeable Entity Protocol -
/* ###################################################################################################################################### */
/**
 This is a simple protocol for a basic writer.
 */
public protocol CGA_Bluetooth_Writable {
    /* ################################################################## */
    /**
     REQUIRED: This returns a unique UUID String for the instance.
     */
    var id: String { get }
    
    /* ################################################################## */
    /**
     Writes data to the device.
     
     - parameter inData: The data to be sent to the device.
     */
    func writeValue(_ inData: Data)
}
