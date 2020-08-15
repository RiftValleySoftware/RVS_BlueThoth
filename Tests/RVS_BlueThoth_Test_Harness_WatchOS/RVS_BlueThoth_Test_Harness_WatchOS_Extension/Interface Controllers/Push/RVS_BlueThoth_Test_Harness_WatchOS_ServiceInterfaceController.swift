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
 This View Controller is for the individual Service screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_ServiceInterfaceController: RVS_BlueThoth_Test_Harness_WatchOS_BaseInterfaceController {
    /* ################################################################## */
    /**
     This is the device discovery struct that describes this device.
     */
    weak var serviceInstance: CGA_Bluetooth_Service?
    
    /* ################################################################## */
    /**
     This displays the Characteristics the Service has available.
     */
    @IBOutlet weak var characteristicsTable: WKInterfaceTable!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_ServiceInterfaceController {
    /* ################################################################## */
    /**
     This adds Services to the table for display.
     */
    func populateTable() {
        if  let serviceInstance = serviceInstance,
            0 < serviceInstance.count {
            let rowControllerInitializedArray = [String](repeatElement("RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTableController", count: serviceInstance.count))
            
            characteristicsTable.setNumberOfRows(rowControllerInitializedArray.count, withRowType: "RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTableController")

            for item in rowControllerInitializedArray.enumerated() {
                if let charRow = characteristicsTable.rowController(at: item.offset) as? RVS_BlueThoth_Test_Harness_WatchOS_CharacteristicTableController {
                    charRow.characteristicInstance = serviceInstance[item.offset]
                }
            }
        } else {
            characteristicsTable.setNumberOfRows(0, withRowType: "")
        }
    }
    
    /* ################################################################## */
    /**
     Establishes accessibility labels.
     */
    func setAccessibility() {
        characteristicsTable?.setAccessibilityLabel("SLUG-ACC-CHARACTERISTIC-TABLE-WATCH".localizedVariant)
    }
}

/* ###################################################################################################################################### */
// MARK: - Overridden Base Class Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_ServiceInterfaceController {
    /* ################################################################## */
    /**
     This is called as the view is established.
     
     - parameter withContext: The context, passed in from the main view. It will be the device discovery struct.
     */
    override func awake(withContext inContext: Any?) {
        if let context = inContext as? CGA_Bluetooth_Service {
            id = context.id
            super.awake(withContext: inContext)
            serviceInstance = context
            setTitle(id.localizedVariant)
            setAccessibility()
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
        if  let serviceInstance = serviceInstance,
            (0..<serviceInstance.count).contains(inRowIndex) {
            return serviceInstance[inRowIndex]
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_ServiceInterfaceController {
    /* ################################################################## */
    /**
     This sets everything up to reflect the current state of the Service.
     */
    override func updateUI() {
        populateTable()
    }
}
