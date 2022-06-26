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

import UIKit
import RVS_BlueThoth

/* ###################################################################################################################################### */
// MARK: - Preferences View Controller -
/* ###################################################################################################################################### */
/**
 */
class CGA_SettingsViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     If on, then devices will be continuously updated.
     */
    @IBOutlet weak var continuousUpdateSwitch: UISegmentedControl!
    
    /* ################################################################## */
    /**
     The switch that controls whether or not to allow non-connectable devices to be discovered.
     */
    @IBOutlet weak var onlyConnectableSwitch: UISegmentedControl!
    
    /* ################################################################## */
    /**
     The switch that controls whether or not to allow empty names.
     */
    @IBOutlet weak var allowEmptyNamesSwitch: UISegmentedControl!
    
    /* ################################################################## */
    /**
     The label for the RSSI Segmented Switch.
     */
    @IBOutlet weak var minRSSILabel: UILabel!
    
    /* ################################################################## */
    /**
     This contains 11 possible values for the minimum RSSI.
     */
    @IBOutlet weak var minRSSISegmentedSwitch: UISegmentedControl!
}

/* ###################################################################################################################################### */
// MARK: - Class Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     This sets up localizations for a segmented switch, based on slugs in the resource.
     
     - parameter inSwitch: The Segmented Control (optional)
     */
    class func setSwitchSegmentLocalizations(_ inSwitch: UISegmentedControl?) {
        if let theSwitch = inSwitch {
            for index in 0..<theSwitch.numberOfSegments {
                theSwitch.setTitle(theSwitch.titleForSegment(at: index)?.localizedVariant, forSegmentAt: index)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
        continuousUpdateSwitch?.accessibilityLabel = "SLUG-ACC-CONTINUOUS-UPDATE-SWITCH-O" + ((prefs?.continuouslyUpdatePeripherals ?? false) ? "N" : "FF").localizedVariant
        onlyConnectableSwitch?.accessibilityLabel = "SLUG-ACC-CONNECTED-ONLY-SWITCH-O" + ((prefs?.discoverOnlyConnectableDevices ?? false) ? "N" : "FF").localizedVariant
        allowEmptyNamesSwitch?.accessibilityLabel = "SLUG-ACC-EMPTY-NAMES-SWITCH-O" + ((prefs?.allowEmptyNames ?? false) ? "N" : "FF").localizedVariant
        minRSSISegmentedSwitch?.accessibilityLabel = "SLUG-ACC-MINIMUM-RSSI-SEGMENTED-SWITCH".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     Called just after the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        Self.setSwitchSegmentLocalizations(continuousUpdateSwitch)
        Self.setSwitchSegmentLocalizations(onlyConnectableSwitch)
        Self.setSwitchSegmentLocalizations(allowEmptyNamesSwitch)
        minRSSILabel?.text = (minRSSILabel?.text ?? "").localizedVariant
        
        continuousUpdateSwitch?.selectedSegmentIndex = (prefs?.continuouslyUpdatePeripherals ?? false) ? 0 : 1
        onlyConnectableSwitch?.selectedSegmentIndex = (prefs?.discoverOnlyConnectableDevices ?? false) ? 0 : 1
        allowEmptyNamesSwitch?.selectedSegmentIndex = (prefs?.allowEmptyNames ?? false) ? 0 : 1

        if let minRSSI = prefs?.minimumRSSILevel {
            switch minRSSI {
            case (-90)..<(-80):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 1
            case (-80)..<(-70):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 2
            case (-70)..<(-60):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 3
            case (-60)..<(-50):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 4
            case (-50)..<(-40):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 5
            case (-40)..<(-30):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 6
            case (-30)..<(-20):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 7
            case (-20)..<(-10):
                minRSSISegmentedSwitch?.selectedSegmentIndex = 8
            case (-10)..<0:
                minRSSISegmentedSwitch?.selectedSegmentIndex = 9
            case 0...:
                minRSSISegmentedSwitch?.selectedSegmentIndex = 10
            default:
                minRSSISegmentedSwitch?.selectedSegmentIndex = 0
            }
        }
        
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view will disappear.
     
     - parameter inAnimated: ignored, but passed to the superclas.
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        prefs?.continuouslyUpdatePeripherals = 0 == (continuousUpdateSwitch?.selectedSegmentIndex ?? 1)
        prefs?.discoverOnlyConnectableDevices = 0 == (onlyConnectableSwitch?.selectedSegmentIndex ?? 1)
        prefs?.allowEmptyNames = 0 == (allowEmptyNamesSwitch?.selectedSegmentIndex ?? 1)
        prefs?.minimumRSSILevel = Int(minRSSISegmentedSwitch?.titleForSegment(at: minRSSISegmentedSwitch?.selectedSegmentIndex ?? 0) ?? "-100") ?? -100
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the table is displayed if BT is available, or the "No BT" image is shown, if it is not.
     */
    func updateUI() {
        setUpAccessibility()
    }
}
