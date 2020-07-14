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

import Cocoa
import RVS_BlueThoth_MacOS

/* ###################################################################################################################################### */
// MARK: - The Initial Screen View Controller -
/* ###################################################################################################################################### */
/**
 */
class RVS_BlueThoth_Test_Harness_MacOS_InitialViewController: RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     This enum has the scanning on/off states, expressed as 0-based Int.
     */
    enum ScanningModeSwitchValues: Int {
        /// The SDK is not scanning for Peripherals.
        case notScanning
        /// The SDK is scanning for Peripherals.
        case scanning
    }
    
    /* ################################################################## */
    /**
     The segue ID for displaying a peripheral window.
     */
    static private let _peripheralWindowSegueID = "peripheral-window-display"

    /* ################################################################## */
    /**
     This is a segmented switch that reflects the state of the scanning.
     */
    @IBOutlet weak var scanningModeSegmentedSwitch: NSSegmentedControl!
    
    /* ################################################################## */
    /**
     Called when the scanning/not scanning sgmented switch changes.
     
     - parameter inSwitch: The switch object.
     */
    @IBAction func scanningChanged(_ inSwitch: NSSegmentedControl) {
        if ScanningModeSwitchValues.notScanning.rawValue == inSwitch.selectedSegment {
            centralManager?.stopScanning()
        } else {
            centralManager?.startScanning()
        }
        
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - P{rivate Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_InitialViewController {
    /* ################################################################## */
    /**
     Sets up the various accessibility labels.
     */
    private func _setUpAccessibility() {
        scanningModeSegmentedSwitch?.setAccessibilityLabel("SLUG-ACC-SCANNING-BUTTON-O" + ((ScanningModeSwitchValues.notScanning.rawValue == scanningModeSegmentedSwitch?.selectedSegment) ? "FF" : "N"))
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_InitialViewController {
    /* ################################################################## */
    /**
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        scanningModeSegmentedSwitch?.setLabel(scanningModeSegmentedSwitch?.label(forSegment: ScanningModeSwitchValues.notScanning.rawValue)?.localizedVariant ?? "ERROR", forSegment: ScanningModeSwitchValues.notScanning.rawValue)
        scanningModeSegmentedSwitch?.setLabel(scanningModeSegmentedSwitch?.label(forSegment: ScanningModeSwitchValues.scanning.rawValue)?.localizedVariant ?? "ERROR", forSegment: ScanningModeSwitchValues.scanning.rawValue)
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen appears.
     We use this to register with the app delegate.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        appDelegateObject.screenList.addScreen(self)
    }
    
    /* ################################################################## */
    /**
     Called just before the screen disappears.
     We use this to un-register with the app delegate.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        appDelegateObject.screenList.removeScreen(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_InitialViewController: RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController_Protocol {
    /* ################################################################## */
    /**
     This is a String key that uniquely identifies this screen.
     */
    var key: String { "MAIN" }
    
    /* ################################################################## */
    /**
     This forces the UI elements to be updated.
     */
    func updateUI() {
        scanningModeSegmentedSwitch?.isHidden = !(centralManager?.isBTAvailable ?? false)
        scanningModeSegmentedSwitch?.setSelected(true, forSegment: (centralManager?.isScanning ?? false) ? ScanningModeSwitchValues.scanning.rawValue : ScanningModeSwitchValues.notScanning.rawValue)
        _setUpAccessibility()
    }
}
