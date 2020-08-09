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
     This is the device discovery struct that describes this device.
     */
    var deviceDiscoveryData: RVS_BlueThoth.DiscoveryData!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var connectingLabel: WKInterfaceLabel!
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
        if let context = inContext as? RVS_BlueThoth.DiscoveryData {
            deviceDiscoveryData = context
            id = context.identifier
            setTitle(deviceDiscoveryData.preferredName)
        }
    }
    
    /* ################################################################## */
    /**
     Called as the screen is activated
     */
    override func willActivate() {
        super.willActivate()
        connectingLabel?.setText("SLUG-CONNECTING".localizedVariant)
        connectingLabel?.setHidden(false)
        deviceDiscoveryData?.connect()
    }
    
    /* ################################################################## */
    /**
     Called sfter the screen has deactivated
     */
    override func didDeactivate() {
        super.didDeactivate()
        deviceDiscoveryData?.disconnect()
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
        } else {
            connectingLabel?.setHidden(false)
        }
    }
}
