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
// MARK: - Service Specialization for Device Info -
/* ###################################################################################################################################### */
/**
 This adds some specialized accessors.
 */
public class CGA_Bluetooth_Service_DeviceInfo: CGA_Bluetooth_Service {
    /* ################################################################## */
    /**
     This returns The manufacturer name for the Service (if provided).
     */
    public var manufacturerName: String? { (sequence_contents[CBUUID(string: CGA_Bluetooth_Characteristic_ManufacturerName.cbUUIDString)] as? CGA_Bluetooth_Characteristic_ManufacturerName)?.stringValue }
    
    /* ################################################################## */
    /**
     This returns The model number for the Service (if provided).
     */
    public var modelNumber: String? { (sequence_contents[CBUUID(string: CGA_Bluetooth_Characteristic_ModelNumber.cbUUIDString)] as? CGA_Bluetooth_Characteristic_ModelNumber)?.stringValue }
    
    /* ################################################################## */
    /**
     This returns a unique GATT UUID String for the Service.
     */
    class var cbUUIDString: String { "180A" }
}
