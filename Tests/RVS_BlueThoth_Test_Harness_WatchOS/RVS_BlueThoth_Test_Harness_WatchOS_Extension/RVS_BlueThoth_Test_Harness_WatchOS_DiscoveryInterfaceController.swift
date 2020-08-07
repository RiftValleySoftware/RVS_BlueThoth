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

/* ###################################################################################################################################### */
// MARK: - Main Watch App Discovery Interface Controller -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController: WKInterfaceController {
    /* ################################################################## */
    /**
     The Table Row Controller ID.
     */
    static let discoveredDeviceTableRowControllerID = "discoveredDeviceTableRowController"
    
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
        scanningSwitch?.setOn(false)
    }
    
    /* ################################################################## */
    /**
     Called just before the view activates.
     */
    override func willActivate() {
        super.willActivate()
    }
    
    /* ################################################################## */
    /**
     Called just before the view deactivates.
     */
    override func didDeactivate() {
        super.didDeactivate()
    }
}
