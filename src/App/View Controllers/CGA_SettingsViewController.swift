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

import UIKit
import CoreBluetooth

/* ###################################################################################################################################### */
// MARK: - The Settings View Controller -
/* ###################################################################################################################################### */
/**
 This controls the settings view.
 */
class CGA_SettingsViewController: UIViewController {
    /* ################################################################## */
    /**
     This switch will determine whether or not duplicate filtering is applied to the Peripheral scanning.
     If it is applied, then duplicates will be ignored during the discovery process (meaning that the devices are not continuously updated).
     False/Off means that duplicates ARE being filtered.
     */
    @IBOutlet weak var ignoreDuplicatesScanningSwitch: UISwitch!
    
    /* ################################################################## */
    /**
     This button is the "label" for the switch. I always like my labels to actuate their targets. This toggles the value of the switch.
     */
    @IBOutlet weak var ignoreDuplicatesSwitchButton: UIButton!
    
    /* ################################################################## */
    /**
     The label for the header over the three TextFields.
     */
    @IBOutlet weak var filterHeaderLabel: UILabel!
    
    /* ################################################################## */
    /**
     The Label for the device/Peripheral filter TextField.
     */
    @IBOutlet weak var deviceFilterLabel: UILabel!
    
    /* ################################################################## */
    /**
     The TextField for entry of the device/Peripheral filters.
     */
    @IBOutlet weak var deviceFilterTextView: UITextView!
    
    /* ################################################################## */
    /**
     The Label for the Service filter TextField.
     */
    @IBOutlet weak var serviceFilterLabel: UILabel!
    
    /* ################################################################## */
    /**
     The TextField for entry of the Service filters.
     */
    @IBOutlet weak var serviceFilterTextView: UITextView!
    
    /* ################################################################## */
    /**
     The Label for the Characteristic filter TextField.
     */
    @IBOutlet weak var characteristicFilterLabel: UILabel!
    
    /* ################################################################## */
    /**
     The TextField for entry of the Characteristic filters.
     */
    @IBOutlet weak var characteristicFilterTextView: UITextView!
    
    /* ################################################################## */
    /**
     The Label for the Minimum RSSI threshold.
     */
    @IBOutlet weak var minimumRSSILevelLabel: UILabel!
    
    /* ################################################################## */
    /**
     The Label for the Left (minimum) RSSI threshold.
     */
    @IBOutlet weak var minimumRSSILevelMinValLabel: UILabel!
    
    /* ################################################################## */
    /**
     The Label for the Right (maximum) RSSI threshold.
     */
    @IBOutlet weak var minimumRSSILevelMaxValLabel: UILabel!

    /* ################################################################## */
    /**
     The Label for the Current Value of the Minimum RSSI threshold.
     */
    @IBOutlet weak var minimumRSSILevelValueLabel: UILabel!

    /* ################################################################## */
    /**
     The Slider for the Minimum RSSI threshold.
     */
    @IBOutlet weak var minimumRSSILevelSlider: UISlider!
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     This is a utility method that "scrubs" the contents of the passed-in text, so it is an Array of String, containing valid UUID values.
     
     - parameter inTextToParse: The String to be parsed. The Array will be formed from split by linefeed ("\n").
     - returns: an Array of String, containing the UUIDs extracted from the text.
     */
    private class func _parseThisTextForUUIDs(_ inTextToParse: String!) -> [String] { (inTextToParse?.split(separator: "\n").compactMap { $0.uuidFormat } ?? []).map { CBUUID(string: $0).uuidString } }
}

/* ###################################################################################################################################### */
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     Called when the "Continuous Scan" switch is hit.
     This immediately updates our prefs.
     
     - parameter inSwitch: The switch object.
     */
    @IBAction func ignoreDuplicatesSwitchHit(_ inSwitch: UISwitch) {
        CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals = inSwitch.isOn
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called when the label for the switch is hit.
     It toggles the value in the prefs, and forces a UI update, which will change the switch.
     
     - parameter: ignored.
     */
    @IBAction func ignoreDuplicatesButtonHit(_: Any) {
        CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals = !CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals
        updateUI()
    }
    
    /* ################################################################## */
    /**
     - parameter inSlider: The slider instance.
     */
    @IBAction func minimumRSSISliderChanged(_ inSlider: UISlider) {
        let valueAsInt = ceil(inSlider.value)
        inSlider.value = valueAsInt
        CGA_AppDelegate.appDelegateObject.prefs.minimumRSSILevel = Int(valueAsInt)
        updateMInimumRSSIValue()
    }
    
    /* ################################################################## */
    /**
     This dismisses any open keyboard.
     
     - parameter: ignored (and optional).
     */
    @IBAction func dismissKeyboard(_: Any! = nil) {
        deviceFilterTextView?.resignFirstResponder()
        serviceFilterTextView?.resignFirstResponder()
        characteristicFilterTextView?.resignFirstResponder()
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     Updates all the values to match the prefs.
     */
    func updateUI() {
        dismissKeyboard()
        ignoreDuplicatesScanningSwitch?.setOn(CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals, animated: true)
        deviceFilterTextView?.text = CGA_AppDelegate.appDelegateObject.prefs.peripheralFilterIDArray.joined(separator: "\n")
        serviceFilterTextView?.text = CGA_AppDelegate.appDelegateObject.prefs.serviceFilterIDArray.joined(separator: "\n")
        characteristicFilterTextView?.text = CGA_AppDelegate.appDelegateObject.prefs.characteristicFilterIDArray.joined(separator: "\n")
        updateMInimumRSSIValue()
    }
    
    /* ################################################################## */
    /**
     */
    func updateMInimumRSSIValue() {
        minimumRSSILevelValueLabel?.text = String(format: "SLUG-RSSI-LEVEL-FORMAT".localizedVariant, CGA_AppDelegate.appDelegateObject.prefs.minimumRSSILevel)
    }

    /* ################################################################## */
    /**
     Forces a prefs update on the contents of the Peripheral filter TextView.
     */
    func parseDeviceTextView() {
        CGA_AppDelegate.appDelegateObject.prefs.peripheralFilterIDArray = Self._parseThisTextForUUIDs(deviceFilterTextView?.text)
    }
    
    /* ################################################################## */
    /**
     Forces a prefs update on the contents of the Service filter TextView.
     */
    func parseServiceTextView() {
        CGA_AppDelegate.appDelegateObject.prefs.serviceFilterIDArray = Self._parseThisTextForUUIDs(serviceFilterTextView?.text)
    }
    
    /* ################################################################## */
    /**
     Forces a prefs update on the contents of the Characteristic filter TextView.
     */
    func parseCharacteristicTextView() {
        CGA_AppDelegate.appDelegateObject.prefs.characteristicFilterIDArray = Self._parseThisTextForUUIDs(characteristicFilterTextView?.text)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        ignoreDuplicatesSwitchButton?.setTitle(ignoreDuplicatesSwitchButton?.title(for: .normal)?.localizedVariant, for: .normal)
        filterHeaderLabel?.text = filterHeaderLabel?.text?.localizedVariant
        deviceFilterLabel?.text = deviceFilterLabel?.text?.localizedVariant
        serviceFilterLabel?.text = serviceFilterLabel?.text?.localizedVariant
        characteristicFilterLabel?.text = characteristicFilterLabel?.text?.localizedVariant
        minimumRSSILevelLabel?.text = minimumRSSILevelLabel?.text?.localizedVariant
        minimumRSSILevelMinValLabel?.text = minimumRSSILevelMinValLabel?.text?.localizedVariant
        minimumRSSILevelMaxValLabel?.text = minimumRSSILevelMaxValLabel?.text?.localizedVariant
        minimumRSSILevelSlider?.value = Float(CGA_AppDelegate.appDelegateObject.prefs.minimumRSSILevel)
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called before the view is displayed.
     We use this to ensure that the orientation is portrait.
     
     - parameter inAnimated: ignored.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        CGA_AppDelegate.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    /* ################################################################## */
    /**
     This allows us to restart scanning in the main screen, if it was running before we were called.
     It also allows us to restore the orientation.
     
     - parameter inAnimated: ignored.
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        if  let navigationController = presentingViewController as? UINavigationController,
            0 < navigationController.viewControllers.count,
            let presenter = navigationController.viewControllers[0] as? CGA_ScannerViewController {
            CGA_AppDelegate.unlockOrientation()
            if presenter.wasScanning {  // We only reset if we were originally scanning before we came here.
                CGA_AppDelegate.centralManager?.startOver() // Because we can move a lot of cheese, we may start over from scratch. That also means unignoring previously ignored Peripherals.
                presenter.restartScanningIfNecessary()
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - UITextViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController: UITextViewDelegate {
    /* ################################################################## */
    /**
     Called when any of the TextFields change.
     We use this to parse the values.
     
     - parameter inTextView: The TextView that is being changed.
     */
    func textViewDidChange(_ inTextView: UITextView) {
        switch inTextView {
        case deviceFilterTextView:
            parseDeviceTextView()
        case serviceFilterTextView:
            parseServiceTextView()
        case characteristicFilterTextView:
            parseCharacteristicTextView()
        default:
            ()
        }
    }
}
