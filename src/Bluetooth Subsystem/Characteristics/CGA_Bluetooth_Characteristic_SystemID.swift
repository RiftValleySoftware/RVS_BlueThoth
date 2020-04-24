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

import UIKit
import CoreBluetooth

/* ###################################################################################################################################### */
// MARK: - System ID Characteristic Wrapper Class -
/* ###################################################################################################################################### */
/**
 This adds a specialized accessor to the System ID Characteristic.
 */
class CGA_Bluetooth_Characteristic_SystemID: CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     - returns: The 40-bit Manufacturer ID
     */
    var manufacturerID: UInt64? {
        var id = UInt64(0)
        guard var data = value else { return nil }
        data.castInto(&id)
        
        id &= 0xFFFFFFFFFF000000
        
        return id >> 24
    }
    
    /* ################################################################## */
    /**
     - returns: The 24-bit Organizationally Unique ID
     */
    var ouID: UInt32? {
        var id = UInt64(0)
        guard var data = value else { return nil }
        data.castInto(&id)
        
        id &= 0x0000000000FFFFFF
        
        return UInt32(id)
    }
    
    /* ################################################################## */
    /**
     - returns: the ID as a String.
     */
    override var stringValue: String? {
        guard let intValue = intValue else { return nil }
        return String(format: "%016X", UInt64(intValue))
    }
    
    /* ################################################################## */
    /**
     This returns a unique GATT UUID String for the Characteristic.
     */
    class override var uuid: String { "2A23" }
}
