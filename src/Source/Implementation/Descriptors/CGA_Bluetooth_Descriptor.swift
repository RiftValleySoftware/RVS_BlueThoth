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
// MARK: - The Main Wrapper Class for the Descriptors -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of CBDescriptor, adding some functionality, and linking the hierarchy.
 */
public class CGA_Bluetooth_Descriptor: CGA_Bluetooth_Descriptor_Protocol_Internal {
    // MARK: Public Properties
    
    /* ################################################################## */
    /**
     If the Descriptor has a value, it is returned here. It is completely untyped, as each descriptor has its own types.
     */
    public var value: Any? { cbElementInstance?.value }
    
    /* ################################################################## */
    /**
     This returns the value as a String, if possible (may be nil).
     */
    public var stringValue: String? {
        guard let utf8Val = value as? UnsafePointer<CChar> else { return nil }
        return String(utf8String: utf8Val)
    }
    
    /* ################################################################## */
    /**
     This returns a unique UUID String for the instance.
     */
    public var id: String { cbElementInstance?.uuid.uuidString ?? "ERROR" }

    /* ################################################################## */
    /**
     This holds the instance of CBDescriptor that is used by this instance.
     */
    public weak var cbElementInstance: CBDescriptor!
    
    // MARK: Public Methods
    
    /* ################################################################## */
    /**
     The Peripheral is asked to read our value.
     */
    public func readValue() {
        if  let serviceWrapper = characteristic?.service,
            let peripheralWrapper = serviceWrapper.peripheral,
            let peripheral = peripheralWrapper.cbElementInstance {
            #if DEBUG
                print("Reading the value for the \(id) Descriptor.")
            #endif
            peripheral.readValue(for: cbElementInstance)
        }
    }
    
    /* ################################################################## */
    /**
     The Peripheral is asked to write the given data into its value.
     
     - parameter inData: The Data instance to write.
     */
// TODO: Implement this when we can test it.
//    public func writeValue(_ inData: Data) {
//        if  let serviceWrapper = characteristic?.service,
//            let peripheralWrapper = serviceWrapper.peripheral,
//            let peripheral = peripheralWrapper.cbElementInstance {
//            #if DEBUG
//                print("Writing this value: \(inData) for the \(id) Descriptor.")
//            #endif
//            peripheral.writeValue(inData, for: cbElementInstance)
//        }
//    }

    // MARK: Internal Properties
    
    /* ################################################################## */
    /**
     Root class does nothing.
     */
    internal class var uuid: String { "" }

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Characteristic
     */
    internal weak var parent: CGA_Class_Protocol?
    
    /* ################################################################## */
    /**
     This casts the parent as a Characteristic Wrapper.
     */
    internal var characteristic: CGA_Bluetooth_Characteristic! { parent as? CGA_Bluetooth_Characteristic }
    
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    internal var scanCriteria: RVS_BlueThoth.ScanCriteria! { characteristic?.scanCriteria }
    
    /* ################################################################## */
    /**
     This returns the parent Central Manager
     */
    internal var central: RVS_BlueThoth? { parent?.central }
    
    /* ################################################################## */
    /**
     Required init. Doesn't do anything, but we have to have it for the factory.
     */
    internal required init() { }
}

/* ###################################################################################################################################### */
// MARK: - CGA_DescriptorFactory Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Descriptor: CGA_DescriptorFactory {
    /* ################################################################## */
    /**
     This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Characteristic that "owns" this Service
     - parameter cbElementInstance: The CB element for this Service.
     - returns: A new instance of CGA_Bluetooth_Descriptor, or a subclass, thereof. Nil, if it fails.
     */
    internal class func createInstance(parent inParent: CGA_Bluetooth_Characteristic, cbElementInstance inCBDescriptor: CBDescriptor) -> CGA_Bluetooth_Descriptor? {
        let ret = Self()
        ret.parent = inParent
        ret.cbElementInstance = inCBDescriptor
        
        return ret
    }
}
