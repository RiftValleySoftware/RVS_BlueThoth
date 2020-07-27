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
 */
class RVS_BlueThoth_Test_Harness_MacOS_PreferencesViewController: RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var ignoreDupesCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var allowEmptyNamesCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var onlyConnectableCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var alwaysUseCRLFCheckbox: NSButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var minimumRSSILabel: NSTextFieldCell!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var minimumRSSIFixedLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var rssiValueLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var maximumRSSIFixedLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var minimumRSSISlider: NSSlider!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var filterUUIDsLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var deviceFiltersLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet var deviceFilterTextView: NSTextView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var serviceFiltersLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet var serviceFiltersTextView: NSTextView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var characteristicsFiltersLabel: NSTextFieldCell!

    /* ################################################################## */
    /**
     */
    @IBOutlet var characteristicsFiltersTextView: NSTextView!
    
    /* ################################################################## */
    /**
     */
    @IBAction func minimumRSSIChanged(_ inSlider: NSSlider) {
        prefs.minimumRSSILevel = Int(inSlider.intValue)
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
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
     */
    override func setUpAccessibility() {
        let ignoreDupesString = "SLUG-ACC-CONTINUOUS-UPDATE-CHECKBOX"
        ignoreDupesCheckbox?.setAccessibilityLabel(ignoreDupesString.localizedVariant)
        ignoreDupesCheckbox?.toolTip = ignoreDupesString.localizedVariant
        
        let emptyNamesString = "SLUG-ACC-EMPTY-NAMES-CHECKBOX"
        allowEmptyNamesCheckbox?.setAccessibilityLabel(emptyNamesString.localizedVariant)
        allowEmptyNamesCheckbox?.toolTip = emptyNamesString.localizedVariant
        
        let onlyConnectableString = "SLUG-ACC-CONNECTED-ONLY-CHECKBOX"
        onlyConnectableCheckbox?.setAccessibilityLabel(onlyConnectableString.localizedVariant)
        onlyConnectableCheckbox?.toolTip = onlyConnectableString.localizedVariant

        let crlfString = "SLUG-ACC-ALWAYS-USE-CRLF-CHECKBOX"
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
     */
    func updateUI() {
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
