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
/**
This is a base class for the various table controller types.
*/
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base: NSObject {
    /* ################################################################## */
    /**
     This is the element that is associated with the table element (either a Characteristic or a Descriptor).
     */
    var blueThothElementInstance: Any?
}

/* ###################################################################################################################################### */
// MARK: - Label-Only Table Controller -
/* ###################################################################################################################################### */
/**
This is a simple, non-touchable label.
*/
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Label: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     The label instance.
     */
    @IBOutlet weak var labelObject: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - Button Table Controller -
/* ###################################################################################################################################### */
/**
This is a button that allows us to read a value.
*/
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Button: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     The button instance.
     */
    @IBOutlet weak var buttonObject: WKInterfaceButton!

    /* ################################################################## */
    /**
     The handler for the read.
     */
    @IBAction func buttonHit() {
        (blueThothElementInstance as? CGA_Bluetooth_Characteristic)?.readValue()
    }
}

/* ###################################################################################################################################### */
// MARK: - Switch Table Controller -
/* ###################################################################################################################################### */
/**
This is a switch, for notification.
*/
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Switch: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     The switch object.
     */
    @IBOutlet weak var switchObject: WKInterfaceSwitch!
    
    /* ################################################################## */
    /**
     This is called when the switch changes value, and changes the notification state.
     
     - parameter inValue: The new switch value.
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
/**
 This is a simple label, but in a "touchable" row, that opens a Descripto inspection screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_DescriptorButton: RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Base {
    /* ################################################################## */
    /**
     This is a label that displays the Descriptor name, as a "button."
     */
    @IBOutlet weak var labelObject: WKInterfaceLabel!
}
