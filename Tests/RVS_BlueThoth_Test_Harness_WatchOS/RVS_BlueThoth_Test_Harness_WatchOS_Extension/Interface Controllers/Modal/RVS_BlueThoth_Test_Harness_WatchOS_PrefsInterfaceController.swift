/*
© Copyright 2020-2022, The Great Rift Valley Software Company

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
import RVS_BlueThoth

/* ###################################################################################################################################### */
// MARK: - Prefs Modal Screen Controller -
/* ###################################################################################################################################### */
/**
 This controls the modal prefs ("more") screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_PrefsInterfaceController: WKInterfaceController {
    /* ################################################################## */
    /**
     The switch for "Connected Only"
     */
    @IBOutlet weak var connectedOnlySwitch: WKInterfaceSwitch!

    /* ################################################################## */
    /**
     The switch for "Empty Names"
     */
    @IBOutlet weak var emptyNamesSwitch: WKInterfaceSwitch!

    /* ################################################################## */
    /**
     The label above the RSSI slider
     */
    @IBOutlet weak var rssiSectionLabel: WKInterfaceLabel!

    /* ################################################################## */
    /**
     This label displays the value of the RSSI slider
     */
    @IBOutlet weak var rssiLevelLabel: WKInterfaceLabel!

    /* ################################################################## */
    /**
     This is the slider that sets the minimum RSSI
     */
    @IBOutlet weak var minimumRSSISlider: WKInterfaceSlider!
    
    /* ################################################################## */
    /**
     Used to track the prefs value while in this screen.
     */
    var connectedOnly: Bool = false
    
    /* ################################################################## */
    /**
     Used to track the prefs value while in this screen.
     */
    var emptyNames: Bool = false
    
    /* ################################################################## */
    /**
     Used to track the prefs value while in this screen.
     */
    var currentRSSI: Int = -100
    
    /* ################################################################## */
    /**
     Simple accessor to the main extension delegate instance.
     */
    var extensionDelegateInstance: RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate? { RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.extensionDelegateObject }
    
    /* ################################################################## */
    /**
     This accesses our stored preferences.
     */
    var prefs: CGA_PersistentPrefs? { extensionDelegateInstance?.prefs }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_PrefsInterfaceController {
    /* ################################################################## */
    /**
     Called when the "Connected Devices Only" switch is selected.
     
     - parameter inValue: The new value
     */
    @IBAction func connectedOnlySwitchHit(_ inValue: Bool) {
        connectedOnly = inValue
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called when the "Allow Empty Names" switch is selected.
     
     - parameter inValue: The new value
     */
    @IBAction func emptyNamesSwitchHit(_ inValue: Bool) {
        emptyNames = inValue
        updateUI()
    }

    /* ################################################################## */
    /**
     Called when the RSSI Slider changes.
     
     - parameter inValue: The new value
     */
    @IBAction func rssiSliderChanged(_ inValue: Float) {
        currentRSSI = Int(inValue)
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_PrefsInterfaceController {
    /* ################################################################## */
    /**
     Establishes accessibility labels.
     */
    func setAccessibility() {
        connectedOnlySwitch?.setAccessibilityLabel("SLUG-ACC-CONNECTED-ONLY-BUTTON-O" + (connectedOnly ? "FF" : "N").localizedVariant)
        emptyNamesSwitch?.setAccessibilityLabel("SLUG-ACC-EMPTY-NAMES-BUTTON-O" + (emptyNames ? "FF" : "N").localizedVariant)
        minimumRSSISlider?.setAccessibilityLabel(String(format: "SLUG-ACC-SLIDER-FORMAT".localizedVariant, currentRSSI))
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_PrefsInterfaceController {
    /* ################################################################## */
    /**
     Called as the View is set up.
     
     - parameter withContext: The context provided to the view, as it was instantiated.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        setTitle("SLUG-DONE".localizedVariant)
        connectedOnlySwitch?.setTitle("SLUG-CONNECTED-ONLY".localizedVariant)
        emptyNamesSwitch?.setTitle("SLUG-EMPTY-NAME".localizedVariant)
        rssiSectionLabel?.setText("SLUG-MINIMUM-RSSI-LABEL-WATCH".localizedVariant)
        
        connectedOnly = prefs?.discoverOnlyConnectableDevices ?? false
        emptyNames = prefs?.allowEmptyNames ?? false
        currentRSSI = prefs?.minimumRSSILevel ?? -100
        
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view disappears.
     
     We use this to set the main prefs to the ones selected by this screen.
     */
    override func willDisappear() {
        prefs?.discoverOnlyConnectableDevices = connectedOnly
        prefs?.allowEmptyNames = emptyNames
        prefs?.minimumRSSILevel = currentRSSI
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_PrefsInterfaceController {
    /* ################################################################## */
    /**
     This sets the various items to match the values recorded.
     */
    func updateUI() {
        connectedOnlySwitch?.setOn(connectedOnly)
        emptyNamesSwitch?.setOn(emptyNames)
        rssiLevelLabel?.setText(String(format: "SLUG-RSSI-LEVEL-FORMAT".localizedVariant, currentRSSI))
        minimumRSSISlider?.setValue(Float(currentRSSI))
        setAccessibility()
    }
}
