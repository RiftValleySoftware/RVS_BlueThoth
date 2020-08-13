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
class RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController: RVS_BlueThoth_Test_Harness_WatchOS_Base {
    /* ################################################################## */
    /**
     The segue ID for the connection segue (from the CONNECT button).
     */
    static let connectionSegueID = "connect-to-device"
    
    /* ################################################################## */
    /**
     This is the device discovery struct that describes this device.
     */
    var deviceDiscoveryData: RVS_BlueThoth.DiscoveryData!
    
    /* ################################################################## */
    /**
     This label displays the advertising strings.
     */
    @IBOutlet weak var advertisingInformationLabel: WKInterfaceLabel!
    
    /* ################################################################## */
    /**
     If the device is connectable, this button is displayed, and will bring in the connected device screen.
     */
    @IBOutlet weak var connectButton: WKInterfaceButton!
}

/* ###################################################################################################################################### */
// MARK: - Overridden Base Class Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     This is called as the view is established.
     
     - parameter withContext: The context, passed in from the main view. It will be the device discovery struct.
     */
    override func awake(withContext inContext: Any?) {
        if let context = inContext as? RVS_BlueThoth.DiscoveryData {
            deviceDiscoveryData = context
            id = context.identifier + "-DISCOVERED"
            setTitle(deviceDiscoveryData.preferredName)
            connectButton?.setTitle("SLUG-CONNECT".localizedVariant)
            connectButton?.setHidden(!deviceDiscoveryData.canConnect)
        }
    }
    
    /* ################################################################## */
    /**
     This is called as the view is about to become active.
     */
    override func willActivate() {
        super.willActivate()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     This is called as we switch to the connection screen.
     
     - parameter withIdentifier: The String that identifies the segue.
     - returns: nil, if the segue is not ours, or the device discovery data.
     */
    override func contextForSegue(withIdentifier inSegueIdentifier: String) -> Any? {
        print(inSegueIdentifier)
        guard Self.connectionSegueID == inSegueIdentifier else { return nil }
        
        return deviceDiscoveryData
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     This sets everything up to reflect the current state of the Central Manager.
     */
    override func updateUI() {
        let advertisingStrings = RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.createAdvertimentStringsFor(deviceDiscoveryData.advertisementData, id: deviceDiscoveryData.identifier, power: deviceDiscoveryData.rssi)
        advertisingInformationLabel.setText(advertisingStrings.joined(separator: "\n-\n"))
    }
}
