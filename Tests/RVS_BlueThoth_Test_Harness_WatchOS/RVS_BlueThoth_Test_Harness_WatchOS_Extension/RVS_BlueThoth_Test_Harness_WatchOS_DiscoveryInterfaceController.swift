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
// MARK: - Main Watch App Discovery Interface Controller -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController: WKInterfaceController {
    /* ################################################################## */
    /**
     The switch that controls the scanning for Peripherals.
     */
    @IBOutlet weak var scanningSwitch: WKInterfaceSwitch!

    /* ################################################################## */
    /**
     The table that lists the discovered devices.
     */
    @IBOutlet weak var deviceListTable: WKInterfaceTable!

    /* ################################################################## */
    /**
     The "NO BT" image.
     */
    @IBOutlet weak var noBTImage: WKInterfaceImage!
    
    /* ################################################################## */
    /**
     The BlueThoth instance for this app.
     */
    var driverInstance: RVS_BlueThoth?
    
    /* ################################################################## */
    /**
     Accesses the single Central Manager instance.
     */
    var centralManager: RVS_BlueThoth? { RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.extensionDelegateObject?.centralManager }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController {
    /* ################################################################## */
    /**
     Called when the Scanning switch changes value
     
     - parameter inIsOn: True, if the switch is now on.
     */
    @IBAction func scanningSwitchChanged(_ inIsOn: Bool) {
        if  let centralManager = centralManager,
            centralManager.isBTAvailable,
            inIsOn {
            centralManager.startScanning()
        } else {
            centralManager?.stopScanning()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController {
    /* ################################################################## */
    /**
     Called as the View is set up.
     
     - parameter withContext: The context provided to the view, as it was instantiated.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        scanningSwitch?.setTitle("SLUG-SCANNING".localizedVariant)
        if  let centralManager = centralManager,
            centralManager.isBTAvailable {
            noBTImage?.setHidden(true)
            scanningSwitch?.setHidden(false)
            scanningSwitch?.setOn(centralManager.isScanning)
        } else {
            noBTImage?.setHidden(false)
            scanningSwitch?.setOn(false)
            scanningSwitch?.setHidden(true)
        }
    }
    
    /* ################################################################## */
    /**
     Called just before the view activates.
     */
    override func willActivate() {
        super.willActivate()
        populateTable()
    }
    
    /* ################################################################## */
    /**
     Called just before the view deactivates.
     */
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    /* ################################################################## */
    /**
     This adds devices to the table for display.
     */
    func populateTable() {
        if  let driverInstance = driverInstance,
            driverInstance.isBTAvailable,
            0 < driverInstance.stagedBLEPeripherals.count {
            let rowControllerInitializedArray = [String](repeatElement("RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryTableController", count: driverInstance.stagedBLEPeripherals.count))
            
            deviceListTable.setNumberOfRows(rowControllerInitializedArray.count, withRowType: "RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryTableController")
            
            for item in rowControllerInitializedArray.enumerated() {
                if let deviceRow = deviceListTable.rowController(at: item.offset) as? RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryTableController {
                    let deviceInstance = driverInstance.stagedBLEPeripherals[item.offset]
                    deviceRow.deviceInstance = deviceInstance
                    deviceRow.deviceRowButton.setTitle(deviceInstance.preferredName)
                }
            }
        } else {
            deviceListTable.setNumberOfRows(0, withRowType: "")
        }
    }
}
