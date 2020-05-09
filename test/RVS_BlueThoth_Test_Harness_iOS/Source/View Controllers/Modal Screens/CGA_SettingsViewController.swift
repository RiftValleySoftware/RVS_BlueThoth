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
class CGA_SettingsViewController: CGA_BaseViewController {
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
    
    /* ################################################################## */
    /**
     This switch will determine whether or not filtering is applied to the Peripheral scanning, ignoring devices that can't be connected.
     If it is applied, then any device that does not advertise that it can be connected will be ignored.
     False/Off means that all connectables and non-connectables are being discovered. True/On means that only connectable devices will be listed.
     */
    @IBOutlet weak var onlyConnectablesSwitch: UISwitch!
    
    /* ################################################################## */
    /**
     This button is the "label" for the switch. I always like my labels to actuate their targets. This toggles the value of the switch.
     */
    @IBOutlet weak var onlyConnectablesSwitchButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var emptyNamesSwitch: UISwitch!
    
    /* ################################################################## */
    /**
     This button is the "label" for the switch. I always like my labels to actuate their targets. This toggles the value of the switch.
     */
    @IBOutlet weak var emptyNamesSwitchButton: UIButton!
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
    
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    private func _setUpAccessibility() {
        ignoreDuplicatesSwitchButton?.accessibilityLabel = ("SLUG-ACC-CONTINUOUS-UPDATE-BUTTON-O" + (prefs.continuouslyUpdatePeripherals ? "N" : "FF")).localizedVariant
        ignoreDuplicatesScanningSwitch?.accessibilityLabel = ("SLUG-ACC-CONTINUOUS-UPDATE-SWITCH-O" + (prefs.continuouslyUpdatePeripherals ? "N" : "FF")).localizedVariant
        deviceFilterTextView?.accessibilityLabel = "SLUG-ACC-DEVICE-UUIDS".localizedVariant
        serviceFilterTextView?.accessibilityLabel = "SLUG-ACC-SERVICE-UUIDS".localizedVariant
        characteristicFilterTextView?.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-UUIDS".localizedVariant
        onlyConnectablesSwitchButton?.accessibilityLabel = ("SLUG-ACC-CONNECTED-ONLY-BUTTON-O" + (prefs.discoverOnlyConnectableDevices ? "N" : "FF")).localizedVariant
        onlyConnectablesSwitch?.accessibilityLabel = ("SLUG-ACC-CONNECTED-ONLY-SWITCH-O" + (prefs.discoverOnlyConnectableDevices ? "N" : "FF")).localizedVariant
        emptyNamesSwitchButton?.accessibilityLabel = ("SLUG-ACC-EMPTY-NAMES-BUTTON-O" + (prefs.allowEmptyNames ? "N" : "FF")).localizedVariant
        emptyNamesSwitch?.accessibilityLabel = ("SLUG-ACC-EMPTY-NAMES-SWITCH-O" + (prefs.allowEmptyNames ? "N" : "FF")).localizedVariant
        minimumRSSILevelValueLabel?.accessibilityLabel = String(format: "SLUG-ACC-SLIDER-MIN-LABEL".localizedVariant, Int(minimumRSSILevelSlider?.minimumValue ?? -100))
        minimumRSSILevelMaxValLabel?.accessibilityLabel = String(format: "SLUG-ACC-SLIDER-MAX-LABEL".localizedVariant, Int(minimumRSSILevelSlider?.maximumValue ?? 0))
    }
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
        prefs.continuouslyUpdatePeripherals = inSwitch.isOn
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called when the label for the switch is hit.
     It toggles the value in the prefs, and forces a UI update, which will change the switch.
     
     - parameter: ignored.
     */
    @IBAction func ignoreDuplicatesButtonHit(_: Any) {
        prefs.continuouslyUpdatePeripherals = !prefs.continuouslyUpdatePeripherals
        updateUI()
    }
    
    /* ################################################################## */
    /**
     - parameter inSlider: The slider instance.
     */
    @IBAction func minimumRSSISliderChanged(_ inSlider: UISlider) {
        let valueAsInt = ceil(inSlider.value)
        inSlider.value = valueAsInt
        prefs.minimumRSSILevel = Int(valueAsInt)
        updateMInimumRSSIValue()
    }
    
    /* ################################################################## */
    /**
     This dismisses any open keyboard.
     
     - parameter: ignored (and optional).
     */
    @IBAction func dismissKeyboard(_: Any! = nil) {
        resignAllFirstResponders()
    }
    
    /* ################################################################## */
    /**
     Called when the "Only Connectable Devices" switch is hit.
     This immediately updates our prefs.
     
     - parameter inSwitch: The switch object.
     */
    @IBAction func onlyConnectableSwitchHit(_ inSwitch: UISwitch) {
        prefs.discoverOnlyConnectableDevices = inSwitch.isOn
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called when the label for the switch is hit.
     It toggles the value in the prefs, and forces a UI update, which will change the switch.
     
     - parameter: ignored.
     */
    @IBAction func onlyConnectableButtonHit(_: Any) {
        prefs.discoverOnlyConnectableDevices = !prefs.discoverOnlyConnectableDevices
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called when the "Allow Empty Names" switch is hit.
     This immediately updates our prefs.
     
     - parameter inSwitch: The switch object.
     */
    @IBAction func emptyNamesSwitchHit(_ inSwitch: UISwitch) {
        prefs.allowEmptyNames = inSwitch.isOn
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called when the label for the switch is hit.
     It toggles the value in the prefs, and forces a UI update, which will change the switch.
     
     - parameter: ignored.
     */
    @IBAction func emptyNamesButtonHit(_: Any) {
        prefs.allowEmptyNames = !prefs.allowEmptyNames
        updateUI()
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
        ignoreDuplicatesScanningSwitch?.setOn(prefs.continuouslyUpdatePeripherals, animated: true)
        onlyConnectablesSwitch?.setOn(prefs.discoverOnlyConnectableDevices, animated: true)
        emptyNamesSwitch?.setOn(prefs.allowEmptyNames, animated: true)
        deviceFilterTextView?.text = prefs.peripheralFilterIDArray.joined(separator: "\n")
        serviceFilterTextView?.text = prefs.serviceFilterIDArray.joined(separator: "\n")
        characteristicFilterTextView?.text = prefs.characteristicFilterIDArray.joined(separator: "\n")
        _setUpAccessibility()
        updateMInimumRSSIValue()
    }
    
    /* ################################################################## */
    /**
     */
    func updateMInimumRSSIValue() {
        let minimumRSSILevel = prefs.minimumRSSILevel
        // Sets up our accessibility labels and values for the slider.
        minimumRSSILevelValueLabel?.text = String(format: "SLUG-RSSI-LEVEL-FORMAT".localizedVariant, minimumRSSILevel)
        minimumRSSILevelLabel?.accessibilityLabel = String(format: "SLUG-ACC-SLIDER-LABEL-FORMAT".localizedVariant, minimumRSSILevel)
        minimumRSSILevelValueLabel?.accessibilityLabel = String(format: "SLUG-ACC-SLIDER-VALUE".localizedVariant, minimumRSSILevel)
        minimumRSSILevelSlider?.accessibilityLabel = String(format: "SLUG-ACC-SLIDER-FORMAT".localizedVariant, minimumRSSILevel)
        minimumRSSILevelSlider?.accessibilityValue = String(format: "SLUG-ACC-SLIDER-VALUE".localizedVariant, minimumRSSILevel)
    }

    /* ################################################################## */
    /**
     Forces a prefs update on the contents of the Peripheral filter TextView.
     */
    func parseDeviceTextView() {
        prefs.peripheralFilterIDArray = Self._parseThisTextForUUIDs(deviceFilterTextView?.text)
    }
    
    /* ################################################################## */
    /**
     Forces a prefs update on the contents of the Service filter TextView.
     */
    func parseServiceTextView() {
        prefs.serviceFilterIDArray = Self._parseThisTextForUUIDs(serviceFilterTextView?.text)
    }
    
    /* ################################################################## */
    /**
     Forces a prefs update on the contents of the Characteristic filter TextView.
     */
    func parseCharacteristicTextView() {
        prefs.characteristicFilterIDArray = Self._parseThisTextForUUIDs(characteristicFilterTextView?.text)
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
        onlyConnectablesSwitchButton?.setTitle(onlyConnectablesSwitchButton?.title(for: .normal)?.localizedVariant, for: .normal)
        emptyNamesSwitchButton?.setTitle(emptyNamesSwitchButton?.title(for: .normal)?.localizedVariant, for: .normal)
        filterHeaderLabel?.text = filterHeaderLabel?.text?.localizedVariant
        deviceFilterLabel?.text = deviceFilterLabel?.text?.localizedVariant
        serviceFilterLabel?.text = serviceFilterLabel?.text?.localizedVariant
        characteristicFilterLabel?.text = characteristicFilterLabel?.text?.localizedVariant
        minimumRSSILevelLabel?.text = minimumRSSILevelLabel?.text?.localizedVariant
        minimumRSSILevelMinValLabel?.text = String(format: minimumRSSILevelMinValLabel?.text?.localizedVariant ?? "%d", Int(minimumRSSILevelSlider.minimumValue))
        minimumRSSILevelMaxValLabel?.text = String(format: minimumRSSILevelMaxValLabel?.text?.localizedVariant ?? "%d", Int(minimumRSSILevelSlider.maximumValue))
        minimumRSSILevelSlider?.minimumTrackTintColor = .white
        minimumRSSILevelSlider?.maximumTrackTintColor = .darkGray
        
        minimumRSSILevelSlider?.value = Float(prefs.minimumRSSILevel)
        
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
    override func viewDidDisappear(_ inAnimated: Bool) {
        super.viewDidDisappear(inAnimated)
        CGA_AppDelegate.unlockOrientation()
        if  let nav = CGA_AppDelegate.appDelegateObject?.window?.rootViewController as? UINavigationController,
            let presenter = nav.topViewController as? CGA_InitialViewController {
            if presenter.wasScanning {  //  We only reset if we were previously scanning.
                CGA_AppDelegate.centralManager?.startOver() // Because we can move a lot of cheese, we may start over from scratch. That also means unignoring previously ignored Peripherals.
            }
            presenter.restartScanningIfNecessary()
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
            break
        }
    }
}
