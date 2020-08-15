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
// MARK: - Device Screen Controller -
/* ###################################################################################################################################### */
/**
 This View Controller is for the individual Characteristic screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicInterfaceController: RVS_BlueThoth_Test_Harness_WatchOS_BaseInterfaceController {
    /* ################################################################## */
    /**
     This is the Characteristic instance.
     */
    weak var characteristicInstance: CGA_Bluetooth_Characteristic?

    /* ################################################################## */
    /**
     This is the row index of the first Descriptor.
     */
    var baseOfDescriptors = 0

    /* ################################################################## */
    /**
     This displays the Characteristics the Service has available.
     */
    @IBOutlet weak var propertiesTable: WKInterfaceTable!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicInterfaceController {
    /* ################################################################## */
    /**
     This adds Characteristic Properties to the table for display.
     */
    func populateTable() {
        baseOfDescriptors = -1
        var propertyArray: [(type: String, value: String)] = []
        if  (characteristicInstance?.canRead ?? false) || (characteristicInstance?.canNotify ?? false),
            let stringValue = characteristicInstance?.stringValue,
            !stringValue.isEmpty {
            propertyArray.append((type: "LabelOnly", value: stringValue))
        }
        if characteristicInstance?.canRead ?? false {
            propertyArray.append((type: "ButtonOnly", value: "SLUG-WATCH-PROPERTY-READ".localizedVariant))
        }
        if characteristicInstance?.canNotify ?? false {
            propertyArray.append((type: "SwitchOnly", value: "SLUG-WATCH-PROPERTY-NOTIFY".localizedVariant))
        }
        if characteristicInstance?.canWriteWithResponse ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-WRITE-RESP"))
        }
        if characteristicInstance?.canWriteWithoutResponse ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-WRITE"))
        }
        if characteristicInstance?.canIndicate ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-INDICATE"))
        }
        if characteristicInstance?.canBroadcast ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-BROADCAST"))
        }
        if characteristicInstance?.requiresNotifyEncryption ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-NOTIFY-ENC"))
        }
        if characteristicInstance?.requiresIndicateEncryption ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-INDICATE-ENC"))
        }
        if characteristicInstance?.requiresAuthenticatedSignedWrites ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-AUTH-SW"))
        }
        if characteristicInstance?.hasExtendedProperties ?? false {
            propertyArray.append((type: "LabelOnly", value: "SLUG-WATCH-PROPERTY-EXTENDED"))
        }

        baseOfDescriptors = propertyArray.count
        
        characteristicInstance?.forEach {
            propertyArray.append((type: "DescriptorButton", value: $0.id.localizedVariant))
        }
        
        if !propertyArray.isEmpty {
            let keyArray = propertyArray.map { $0.type }
            propertiesTable?.setRowTypes(keyArray)
            for item in propertyArray.enumerated() {
                if let row = propertiesTable?.rowController(at: item.offset) as? RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Label {
                    row.blueThothElementInstance = characteristicInstance
                    row.labelObject?.setText(item.element.value)
                } else if let row = propertiesTable?.rowController(at: item.offset) as? RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Button {
                    row.blueThothElementInstance = characteristicInstance
                    row.buttonObject?.setTitle(item.element.value)
                } else if let row = propertiesTable?.rowController(at: item.offset) as? RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_Switch {
                    row.blueThothElementInstance = characteristicInstance
                    row.switchObject?.setOn(characteristicInstance?.isNotifying ?? false)
                    row.switchObject?.setTitle(item.element.value)
                } else if let row = propertiesTable?.rowController(at: item.offset) as? RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTables_DescriptorButton,
                    let descriptor = characteristicInstance?[item.offset - baseOfDescriptors] {
                    row.blueThothElementInstance = descriptor
                    row.labelObject?.setText(item.element.value)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Establishes accessibility labels.
     */
    func setAccessibility() {
        propertiesTable?.setAccessibilityLabel("SLUG-ACC-CHARACTERISTIC-ELEMENTS-TABLE-WATCH".localizedVariant)
    }
}

/* ###################################################################################################################################### */
// MARK: - Overridden Base Class Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicInterfaceController {
    /* ################################################################## */
    /**
     This is called as the view is established.
     
     - parameter withContext: The context, passed in from the main view. It will be the device discovery struct.
     */
    override func awake(withContext inContext: Any?) {
        if let context = inContext as? CGA_Bluetooth_Characteristic {
            id = context.id
            super.awake(withContext: inContext)
            characteristicInstance = context
            setTitle(id.localizedVariant)
            updateUI()
        } else {
            super.awake(withContext: inContext)
        }
    }
    
    /* ################################################################## */
    /**
     Table touch handler.
     
     - parameters:
        - withIdentifier: The segue ID for this (we ignore)
        - in: The table instance
        - rowIndex: The vertical position (0-based) of the row that was touched.
     
        - returns: The context, if any. Can be nil.
     */
    override func contextForSegue(withIdentifier inSegueIdentifier: String, in inTable: WKInterfaceTable, rowIndex inRowIndex: Int) -> Any? {
        if  (0...inRowIndex).contains(baseOfDescriptors),
            let characteristicInstance = characteristicInstance,
            (0..<characteristicInstance.count).contains(inRowIndex - baseOfDescriptors) {
            return characteristicInstance[inRowIndex - baseOfDescriptors]
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicInterfaceController {
    /* ################################################################## */
    /**
     This sets everything up to reflect the current state of the Characteristic.
     */
    override func updateUI() {
        setAccessibility()
        populateTable()
    }
}
