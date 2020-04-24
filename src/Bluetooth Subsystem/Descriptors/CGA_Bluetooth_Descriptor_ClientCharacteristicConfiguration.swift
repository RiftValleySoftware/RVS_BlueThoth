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
// MARK: - The Wrapper Class for the Client Characteristic Configuration Descriptor -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of The Client Characteristic Configuration CBDescriptor, adding some functionality, and linking the hierarchy.
 */
class CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration: CGA_Bluetooth_Descriptor {
    /* ################################################################## */
    /**
     This is the UUID for the Client Characteristic Configuration Descriptor.
     */
    class override var uuid: String { "2902" }
}

/* ###################################################################################################################################### */
// MARK: - Accessor Computed Properties -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration {
    /* ################################################################## */
    /**
     - returns: True, if the Characteristic is currently notifying.
     */
    var isNotifying: Bool {
        print("CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration Value: \(String(describing: cbElementInstance.value))")
        if let value = cbElementInstance.value {
            if let value = value as? Int8 {
                return 1 == value & 0x01
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     - returns: True, if the Characteristic is currently indicating.
     */
    var isIndicating: Bool {
        if let value = value as? UInt8 {
            return 2 == value & 0x02
        }
        
        return false
    }
}
