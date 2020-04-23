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
// MARK: - Current Time Characteristic Wrapper Class -
/* ###################################################################################################################################### */
/**
 This adds a specialized accessor to the Current Time Characteristic.
 */
class CGA_Bluetooth_Characteristic_LocalTimeInformation: CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     - returns: the timezone, as an integer.
     */
    var timezone: Int? {
        var timezone = UInt8(0)
        guard var data = value else { return nil }
        data.castInto(&timezone)
        return Int(timezone)
    }
    
    /* ################################################################## */
    /**
     - returns: the Daylight Savings time offset.
     */
    var dstOffset: Int? {
        var ret = Int(0)
        guard var data = value else { return 0 }
        data.castInto(&ret)
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: the battery level, as a String.
     */
    override var stringValue: String? {
        guard   let timezone = timezone,
                let dstOffset = dstOffset else { return nil }
        return "\(timezone), \(dstOffset)"
    }
    
    /* ################################################################## */
    /**
     This returns a unique GATT UUID String for the Characteristic.
     */
    class override var uuid: String { "2A0F" }
}
