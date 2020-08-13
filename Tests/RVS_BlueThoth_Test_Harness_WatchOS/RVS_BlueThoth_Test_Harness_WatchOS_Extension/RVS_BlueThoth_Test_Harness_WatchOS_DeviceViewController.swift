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
 This View Controller is for the individual device screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_DeviceViewController: RVS_BlueThoth_Test_Harness_WatchOS_Base {
    /* ################################################################## */
    /**
     This flag is used to prevent the device from being disconnecete/reconnected when we look at details.
     */
    var stupidDetailsSemaphore: Bool = false
    
    /* ################################################################## */
    /**
     This is the device discovery struct that describes this device.
     */
    var deviceDiscoveryData: RVS_BlueThoth.DiscoveryData!
    
    /* ################################################################## */
    /**
     This label is shown while the device is undergoing a connection, and is hidden upon connection.
     */
    @IBOutlet weak var connectingLabel: WKInterfaceLabel!

    /* ################################################################## */
    /**
     This displays the Services the device has available.
     */
    @IBOutlet weak var servicesTable: WKInterfaceTable!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DeviceViewController {
    /* ################################################################## */
    /**
     This adds Services to the table for display.
     */
    func populateTable() {
        if  let deviceInstance = deviceDiscoveryData?.peripheralInstance,
            0 < deviceInstance.count {
            let rowControllerInitializedArray = [String](repeatElement("RVS_BlueThoth_Test_Harness_WatchOS_ServiceTableController", count: deviceInstance.count))
            
            servicesTable.setNumberOfRows(rowControllerInitializedArray.count, withRowType: "RVS_BlueThoth_Test_Harness_WatchOS_ServiceTableController")

            for item in rowControllerInitializedArray.enumerated() {
                if let serviceRow = servicesTable.rowController(at: item.offset) as? RVS_BlueThoth_Test_Harness_WatchOS_ServiceTableController {
                    serviceRow.serviceInstance = deviceInstance[item.offset]
                }
            }
        } else {
            servicesTable.setNumberOfRows(0, withRowType: "")
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Overridden Base Class Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DeviceViewController {
    /* ################################################################## */
    /**
     This is called as the view is established.
     
     - parameter withContext: The context, passed in from the main view. It will be the device discovery struct.
     */
    override func awake(withContext inContext: Any?) {
        stupidDetailsSemaphore  = false
        
        if let context = inContext as? RVS_BlueThoth.DiscoveryData {
            id = context.identifier + "-CONNECTED"
            super.awake(withContext: inContext)
            deviceDiscoveryData = context
            connectingLabel?.setHidden(false)
            connectingLabel?.setText("SLUG-CONNECTING".localizedVariant)
            setTitle(deviceDiscoveryData.preferredName.isEmpty ? "SLUG-NO-DEVICE-NAME".localizedVariant : deviceDiscoveryData.preferredName)
        } else {
            super.awake(withContext: inContext)
        }
    }
    
    /* ################################################################## */
    /**
     Called as the screen is activated
     */
    override func willActivate() {
        super.willActivate()
        if !stupidDetailsSemaphore {
            deviceDiscoveryData?.connect()
        }
        stupidDetailsSemaphore  = false
    }
    
    /* ################################################################## */
    /**
     Called sfter the screen has deactivated
     */
    override func didDeactivate() {
        super.didDeactivate()
        if !stupidDetailsSemaphore {
            deviceDiscoveryData?.disconnect()
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
        if  let device = deviceDiscoveryData?.peripheralInstance,
            inRowIndex < device.count {
            stupidDetailsSemaphore  = true
            return device[inRowIndex]
        }
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DeviceViewController {
    /* ################################################################## */
    /**
     This sets everything up to reflect the current state of the Central Manager.
     */
    override func updateUI() {
        if  let device = deviceDiscoveryData?.peripheralInstance,
            device.isConnected {
            #if DEBUG
                print("Device: \(device.id) connected")
            #endif
            connectingLabel?.setHidden(true)
            servicesTable?.setHidden(false)
            populateTable()
        } else {
            #if DEBUG
                if  let device = deviceDiscoveryData?.peripheralInstance {
                    print("Device: \(device.id) disconnected")
                }
            #endif
            connectingLabel?.setHidden(false)
            servicesTable?.setHidden(true)
        }
    }
}
