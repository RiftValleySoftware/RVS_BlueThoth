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
import RVS_Persistent_Prefs

/* ###################################################################################################################################### */
// MARK: - The Preferences Screen View Controller -
/* ###################################################################################################################################### */
/**
 This is the Preferences/Settings modal screen.
 */
class RVS_BlueThoth_Test_Harness_MacOS_PreferencesViewController: RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     The checkbox that allows us to continuously update while scanning.
     */
    @IBOutlet weak var ignoreDupesCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     The checkbox that allows scanning to include Peripherals with no names.
     */
    @IBOutlet weak var allowEmptyNamesCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     The checkbox that allows non-connectbale device to be read (or only connectable)
     */
    @IBOutlet weak var onlyConnectableCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     The checkbox that ensures that all linefeeds/carriage returns be sent as a full CRLF pair.
     */
    @IBOutlet weak var alwaysUseCRLFCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     The label for the RSSI slider.
     */
    @IBOutlet weak var minimumRSSILabel: NSTextFieldCell!

    /* ################################################################## */
    /**
     The label for the low end of the slider.
     */
    @IBOutlet weak var minimumRSSIFixedLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     The label that displays the current slider value.
     */
    @IBOutlet weak var rssiValueLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     The label for the upper end of the slider.
     */
    @IBOutlet weak var maximumRSSIFixedLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     The slider.
     */
    @IBOutlet weak var minimumRSSISlider: NSSlider!
    
    /* ################################################################## */
    /**
     The label for the filters section.
     */
    @IBOutlet weak var filterUUIDsLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     The label for the devices filter.
     */
    @IBOutlet weak var deviceFiltersLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     The devices text view.
     */
    @IBOutlet var deviceFilterTextView: NSTextView!
    
    /* ################################################################## */
    /**
     The label for the services filter.
     */
    @IBOutlet weak var serviceFiltersLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     The services filter text view.
     */
    @IBOutlet var serviceFiltersTextView: NSTextView!
    
    /* ################################################################## */
    /**
     The label for the characteristic text view.
     */
    @IBOutlet weak var characteristicsFiltersLabel: NSTextFieldCell!

    /* ################################################################## */
    /**
     The Characteristic text view.
     */
    @IBOutlet var characteristicsFiltersTextView: NSTextView!
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PreferencesViewController {
    /* ################################################################## */
    /**
     Called when the RSSI slider changes value.
     
     - parameter inSlider: The RSSI slider object.
     */
    @IBAction func minimumRSSIChanged(_ inSlider: NSSlider) {
        prefs.minimumRSSILevel = Int(inSlider.intValue)
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PreferencesViewController {
    /* ################################################################## */
    /**
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = title?.localizedVariant
        centralManager?.stopScanning()
        centralManager?.startOver()
        ignoreDupesCheckbox?.title = ignoreDupesCheckbox?.title.localizedVariant ?? "ERROR"
        allowEmptyNamesCheckbox?.title = allowEmptyNamesCheckbox?.title.localizedVariant ?? "ERROR"
        onlyConnectableCheckbox?.title = onlyConnectableCheckbox?.title.localizedVariant ?? "ERROR"
        alwaysUseCRLFCheckbox?.title = alwaysUseCRLFCheckbox?.title.localizedVariant ?? "ERROR"
        minimumRSSIFixedLabel?.title = String(format: (minimumRSSIFixedLabel?.title ?? "%d").localizedVariant, -100)
        maximumRSSIFixedLabel?.title = String(format: (maximumRSSIFixedLabel?.title ?? "%d").localizedVariant, 0)
        minimumRSSILabel?.title = String(format: (minimumRSSILabel?.title ?? "%d").localizedVariant, 0)
        minimumRSSISlider?.intValue = Int32(prefs.minimumRSSILevel)
        filterUUIDsLabel?.title = String(format: (filterUUIDsLabel?.title ?? "%d").localizedVariant, 0)
        deviceFiltersLabel?.title = String(format: (deviceFiltersLabel?.title ?? "%d").localizedVariant, 0)
        deviceFilterTextView?.string = prefs.peripheralFilterIDArray.joined(separator: "\n")
        serviceFiltersLabel?.title = String(format: (serviceFiltersLabel?.title ?? "%d").localizedVariant, 0)
        serviceFiltersTextView?.string = prefs.serviceFilterIDArray.joined(separator: "\n")
        characteristicsFiltersLabel?.title = String(format: (characteristicsFiltersLabel?.title ?? "%d").localizedVariant, 0)
        characteristicsFiltersTextView?.string = prefs.characteristicFilterIDArray.joined(separator: "\n")
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Sets up all the accessibility items.
     */
    override func setUpAccessibility() {
        let ignoreDupesString = "SLUG-ACC-CONTINUOUS-UPDATE-SWITCH-O" + (prefs.continuouslyUpdatePeripherals ? "N" : "FF")
        ignoreDupesCheckbox?.setAccessibilityLabel(ignoreDupesString.localizedVariant)
        ignoreDupesCheckbox?.toolTip = ignoreDupesString.localizedVariant
        
        let emptyNamesString = "SLUG-ACC-EMPTY-NAMES-SWITCH-O" + (prefs.allowEmptyNames ? "N" : "FF")
        allowEmptyNamesCheckbox?.setAccessibilityLabel(emptyNamesString.localizedVariant)
        allowEmptyNamesCheckbox?.toolTip = emptyNamesString.localizedVariant
        
        let onlyConnectableString = "SLUG-ACC-CONNECTED-ONLY-SWITCH-O" + (prefs.discoverOnlyConnectableDevices ? "N" : "FF")
        onlyConnectableCheckbox?.setAccessibilityLabel(onlyConnectableString.localizedVariant)
        onlyConnectableCheckbox?.toolTip = onlyConnectableString.localizedVariant

        let crlfString = "SLUG-ACC-ALWAYS-USE-CRLF-O" + (prefs.alwaysUseCRLF ? "N" : "FF")
        alwaysUseCRLFCheckbox?.setAccessibilityLabel(crlfString.localizedVariant)
        alwaysUseCRLFCheckbox?.toolTip = crlfString.localizedVariant

        minimumRSSIFixedLabel?.setAccessibilityLabel("SLUG-ACC-SLIDER-MIN-LABEL".localizedVariant)
        maximumRSSIFixedLabel?.setAccessibilityLabel("SLUG-ACC-SLIDER-MAX-LABEL".localizedVariant)
        minimumRSSILabel?.setAccessibilityLabel("SLUG-ACC-SLIDER-LABEL".localizedVariant)
        
        let sliderString = "SLUG-ACC-SLIDER"
        minimumRSSISlider?.setAccessibilityLabel(sliderString.localizedVariant)
        minimumRSSISlider?.toolTip = sliderString.localizedVariant

        let devicesString = "SLUG-ACC-DEVICE-UUIDS"
        deviceFilterTextView?.setAccessibilityLabel(devicesString.localizedVariant)
        deviceFilterTextView?.toolTip = devicesString.localizedVariant
        
        let servicesString = "SLUG-ACC-SERVICE-UUIDS"
        serviceFiltersTextView?.setAccessibilityLabel(servicesString.localizedVariant)
        serviceFiltersTextView?.toolTip = servicesString.localizedVariant
        
        let characteristicsString = "SLUG-ACC-CHARACTERISTIC-UUIDS"
        characteristicsFiltersTextView?.setAccessibilityLabel(characteristicsString.localizedVariant)
        characteristicsFiltersTextView?.toolTip = characteristicsString.localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PreferencesViewController {
    /* ################################################################## */
    /**
     Called to force the UI elements and accessibility to update.
     
     - parameter: ignored.
     */
    @IBAction func updateUI(_: Any! = nil) {
        rssiValueLabel?.title = String(format: (maximumRSSIFixedLabel?.placeholderString ?? "%d").localizedVariant, prefs.minimumRSSILevel)
        setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - NSTextViewDelegate Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PreferencesViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        prefs.peripheralFilterIDArray = deviceFilterTextView.string.split(separator: "\n").compactMap { $0.uuidFormat }
        prefs.serviceFilterIDArray = serviceFiltersTextView.string.split(separator: "\n").compactMap { $0.uuidFormat }
        prefs.characteristicFilterIDArray = characteristicsFiltersTextView.string.split(separator: "\n").compactMap { $0.uuidFormat }
    }
}
