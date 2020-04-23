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
class CGA_Bluetooth_Characteristic_CurrentTime: CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     - returns: the current time, as a Date instance, or nil.
     */
    var currentTime: Date? {
        var year: UInt16 = 0
        var month: UInt8 = 0
        var day: UInt8 = 0
        var hour: UInt8 = 0
        var minute: UInt8 = 0
        var second: UInt8 = 0

        guard var data = value else { return nil }
        var offset = UInt(data.castInto(&year))
        offset += UInt(data.castInto(&month, offsetInBytes: offset))
        offset += UInt(data.castInto(&day, offsetInBytes: offset))
        offset += UInt(data.castInto(&hour, offsetInBytes: offset))
        offset += UInt(data.castInto(&minute, offsetInBytes: offset))
        data.castInto(&second, offsetInBytes: offset)

        let components = DateComponents(calendar: .current, year: Int(year), month: Int(month), day: Int(day), hour: Int(hour), minute: Int(minute), second: Int(second))
        return components.date
    }
    
    /* ################################################################## */
    /**
     - returns: the battery level, as a String.
     */
    override var stringValue: String? {
        guard let date = currentTime else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "SLUG-CURRENT-TIME-DATE-FORMAT".localizedVariant
        let retStr = dateFormatter.string(from: date)
        
        return retStr
    }
    
    /* ################################################################## */
    /**
     This returns a unique GATT UUID String for the Characteristic.
     */
    class override var uuid: String { "2A2B" }
}
