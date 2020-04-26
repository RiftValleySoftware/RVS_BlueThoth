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
// MARK: - The Internal Face of Characteristics -
/* ###################################################################################################################################### */
/**
 This protocol publishes an internal interface for our Characteristic wrapper classes.
 */
internal protocol CGA_Bluetooth_Characteristic_Protocol_Internal: CGA_Bluetooth_Characteristic_Protocol {
    /* ################################################################## */
    /**
     This is the UUID for the Characteristic type. It is not used for external purposes.
     */
    static var uuid: String { get }
    
    /* ################################################################## */
    /**
     This casts the parent as a Service Wrapper.
     */
    var service: CGA_Bluetooth_Service! { get }
        
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    var scanCriteria: CGA_Bluetooth_CentralManager.ScanCriteria! { get }

    /* ################################################################## */
    /**
     This is a convenience init that should always be used.
     
     - parameter parent: The Service instance that "owns" this instance.
     - parameter cbElementInstance: This is the actual CBharacteristic instance to be associated with this instance.
     */
    init(parent: CGA_Bluetooth_Service, cbElementInstance: CBCharacteristic)

    /* ################################################################## */
    /**
     Called to add a Descriptor to our main Array.
     
     - parameter inDescriptor: The Descriptor to add.
     */
    func addDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor)
}
