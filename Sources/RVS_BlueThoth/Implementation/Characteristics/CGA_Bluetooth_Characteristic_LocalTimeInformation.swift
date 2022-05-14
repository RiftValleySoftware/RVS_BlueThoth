/*
© Copyright 2020-2022, The Great Rift Valley Software Company

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
// MARK: - Local Time Information Characteristic Wrapper Class -
/* ###################################################################################################################################### */
/**
 This adds a specialized accessor to the Local Time Information Characteristic.
 */
public class CGA_Bluetooth_Characteristic_LocalTimeInformation: CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     - returns: The offset from UTC, in seconds. Nil, if not available, or out of range.
     */
    public var timezone: TimeInterval? {
        var fifteenMinuteIntervals = Int8(0)
        guard var data = value else { return nil }
        data.castInto(&fifteenMinuteIntervals)
        let ret = TimeInterval(Double(fifteenMinuteIntervals) * 15.0 * 60.0)
        return (-86400.00...86400.00).contains(ret) ? ret : nil
    }
    
    /* ################################################################## */
    /**
     - returns: the Daylight Savings time offset, in seconds. Nil, if not available, or out of range.
     */
    public var dstOffset: TimeInterval? {
        var fifteenMinuteIntervals = Int8(0)
        guard var data = value else { return nil }
        data.castInto(&fifteenMinuteIntervals, offsetInBytes: 1)
        return (0...8).contains(fifteenMinuteIntervals) ? TimeInterval(Double(fifteenMinuteIntervals) * 15 * 60) : nil
    }
    
    /* ################################################################## */
    /**
     - returns: the local time offset from UTC, in seconds, including DST.
     */
    public var offsetFromUTCInSeconds: TimeInterval? {
        guard   let timezone = timezone,
                let dstOffset = dstOffset else { return nil }
        return timezone + dstOffset
    }
    
    /* ################################################################## */
    /**
     - returns: the DST offset, as a String.
     */
    public override var stringValue: String? {
        guard   let offsetFromUTC = offsetFromUTCInSeconds else { return nil }
        return "\(offsetFromUTC)"
    }
    
    /* ################################################################## */
    /**
     This returns a unique GATT UUID String for the Characteristic.
     */
    public class override var uuid: String { "2A0F" }
}
