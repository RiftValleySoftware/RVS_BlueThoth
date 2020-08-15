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

import WatchKit
import Foundation
import RVS_BlueThoth_WatchOS

/* ###################################################################################################################################### */
// MARK: - Label-Only Table Controller -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base: NSObject {
    /* ################################################################## */
    /**
     */
    var blueThothElementInstance: Any?
}

/* ###################################################################################################################################### */
// MARK: - Label-Only Table Controller -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Label: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var labelObject: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - Button Table Controller -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Button: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var buttonObject: WKInterfaceButton!

    /* ################################################################## */
    /**
     */
    @IBAction func buttonHit() {
        (blueThothElementInstance as? CGA_Bluetooth_Characteristic)?.readValue()
    }
}

/* ###################################################################################################################################### */
// MARK: - Switch Table Controller -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Switch: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var switchObject: WKInterfaceSwitch!
    
    /* ################################################################## */
    /**
     */
    @IBAction func switchChanged(_ inValue: Bool) {
        if let characteristicInstance = blueThothElementInstance as? CGA_Bluetooth_Characteristic {
            if characteristicInstance.isNotifying && !inValue {
                characteristicInstance.stopNotifying()
            } else if !characteristicInstance.isNotifying && inValue {
                characteristicInstance.startNotifying()
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Descriptor Button Table Controller -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_DescriptorButton: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var labelObject: WKInterfaceLabel!
}
