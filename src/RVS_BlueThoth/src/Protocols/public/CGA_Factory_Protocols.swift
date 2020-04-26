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
// MARK: - Factory Protocol for Service Instances -
/* ###################################################################################################################################### */
/**
 This allows a generic factory method for Service Wrappers.
 */
protocol CGA_ServiceFactory {
    /* ################################################################## */
    /**
     - returns: A String, with the UUID for this class' element type.
     */
    static var uuid: String { get }

    /* ################################################################## */
    /**
     REQUIRED: This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Peripheral that "owns" this Service
     - parameter cbElementInstance: The CB element for this Service.
     - returns: A new instance of CGA_Bluetooth_Service, or a subclass, thereof. Nil, if it fails.
     */
    static func createInstance(parent: CGA_Bluetooth_Peripheral, cbElementInstance: CBService) -> CGA_Bluetooth_Service?
}

/* ###################################################################################################################################### */
// MARK: - Factory Protocol for Characteristic Instances -
/* ###################################################################################################################################### */
/**
 This allows a generic factory method for Characteristic Wrappers.
 */
protocol CGA_CharacteristicFactory {
    /* ################################################################## */
    /**
     - returns: A String, with the UUID for this class' element type.
     */
    static var uuid: String { get }

    /* ################################################################## */
    /**
     REQUIRED: This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Service that "owns" this Characteristic
     - parameter cbElementInstance: The CB element for this Characteristic.
     - returns: A new instance of CGA_Bluetooth_Characteristic, or a subclass, thereof. Nil, if it fails.
     */
    static func createInstance(parent: CGA_Bluetooth_Service, cbElementInstance: CBCharacteristic) -> CGA_Bluetooth_Characteristic?
}

/* ###################################################################################################################################### */
// MARK: - Factory Protocol for Characteristic Instances -
/* ###################################################################################################################################### */
/**
 This allows a generic factory method for Descriptor Wrappers.
 */
protocol CGA_DescriptorFactory {
    /* ################################################################## */
    /**
     - returns: A String, with the UUID for this class' element type.
     */
    static var uuid: String { get }

    /* ################################################################## */
    /**
     REQUIRED: This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Characteristic that "owns" this Descriptor
     - parameter cbElementInstance: The CB element for this Descriptor.
     - returns: A new instance of CGA_Bluetooth_Descriptor, or a subclass, thereof. Nil, if it fails.
     */
    static func createInstance(parent: CGA_Bluetooth_Characteristic, cbElementInstance: CBDescriptor) -> CGA_Bluetooth_Descriptor?
}
