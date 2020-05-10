/**
 © Copyright 2019, The Great Rift Valley Software Company
 
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

/* ################################################################################################################################## */
// MARK: - Extension of UIView
/* ################################################################################################################################## */
/**
 This returns whatever the first responder is (if any).
 */
extension UIView {
    /* ################################################################## */
    /**
     - returns: the first responder view. Nil, if no view is a first responder.
     */
    var currentFirstResponder: UIResponder! {
        if isFirstResponder {
            return self
        }
        
        for view in subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }
        
        return nil
    }
}

/* ################################################################################################################################## */
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
/**
 In iOS, we don't have good support for KVO, so we rely on good old-fashioned IBAction handlers and setup.
 */
class RVS_PersistentPrefs_iOS_TestHarness_ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /// This is the preferences object. It is instantiated at runtime, and left on its own.
    var prefs = RVS_PersistentPrefs_TestSet(key: RVS_PersistentPrefs_iOS_TestHarness_AppDelegate.prefsKey)
    
    /* ############################################################################################################################## */
    // MARK: - @IBOutlet Instance Properties
    /* ############################################################################################################################## */
    /// The Label for the Integer Text Entry.
    @IBOutlet weak var intLabel: UILabel!
    /// The Integer Text Entry.
    @IBOutlet weak var intTextEntry: UITextField!
    /// The Label for the String Text Entry.
    @IBOutlet weak var stringLabel: UILabel!
    /// The String Text Entry.
    @IBOutlet weak var stringTextEntry: UITextField!
    /// The Label for the Array Group.
    @IBOutlet weak var arrayLabel: UILabel!
    /// The Array Selection Picker.
    @IBOutlet weak var arrayPickerView: UIPickerView!
    /// The Array Editor.
    @IBOutlet weak var arrayTextEntry: UITextField!
    /// The Label for the Dictionary Group.
    @IBOutlet weak var dictionaryLabel: UILabel!
    /// The Dictionary Selection Picker.
    @IBOutlet weak var dictionaryPickerView: UIPickerView!
    /// The Dictionary Editor.
    @IBOutlet weak var dictionaryTextEntry: UITextField!
    /// The Label for the Date Picker.
    @IBOutlet weak var dateLabel: UILabel!
    /// The Date Picker
    @IBOutlet weak var datePicker: UIDatePicker!
    /// The Reset Button
    @IBOutlet weak var resetButton: UIButton!
    
    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     The keys for the Dictionary, as a sorted Array of String
     */
    var dictionaryKeys: [String] {
        return prefs.dictionary.keys.compactMap { $0 }.sorted {
            let desiredOrder = ["One", "Two", "Three", "Four", "Five"]
            let indexofA = desiredOrder.firstIndex(of: $0) ?? 0
            let indexofB = desiredOrder.firstIndex(of: $1) ?? 0
            
            return indexofA < indexofB
        }
    }

    /* ############################################################################################################################## */
    // MARK: - IBAction Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the reset button is hit.
     
     - parameter: Ignored (also, optional)
     */
    @IBAction func resetButtonHit(_: UIButton! = nil) {
        prefs.reset()
        saveDefaultsToSettings()
        setValues()
        
        // Select the first row of each.
        arrayPickerView?.selectRow(0, inComponent: 0, animated: false)
        dictionaryPickerView?.selectRow(0, inComponent: 0, animated: false)
        
        // Make sure the text field gets updated.
        pickerView(arrayPickerView, didSelectRow: 0, inComponent: 0)
        pickerView(dictionaryPickerView, didSelectRow: 0, inComponent: 0)
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the Integer Text Entry Text Field.
     
     - parameter: Ignored (also, optional)
     */
    @IBAction func integerTextEntryChanged(_: UITextField! = nil) {
        prefs.int = Int(intTextEntry?.text ?? "0") ?? 0
        saveDefaultsToSettings()
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the String Text Entry Text Field.
     
     - parameter: Ignored (also, optional)
     */
    @IBAction func stringTextEntryChanged(_: UITextField! = nil) {
        prefs.string = stringTextEntry?.text ?? ""
        saveDefaultsToSettings()
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the Selected Array Element Text Entry Text Field.
     
     - parameter: Ignored (also, optional)
     */
    @IBAction func arrayTextEntryChanged(_: UITextField! = nil) {
        let selectedElement = arrayPickerView.selectedRow(inComponent: 0)
        prefs.array[selectedElement] = arrayTextEntry.text ?? ""
        saveDefaultsToSettings()
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the Selected Dictionary Element Text Entry Text Field.
     
     - parameter: Ignored (also, optional)
     */
    @IBAction func dictionaryTextEntryChanged(_: UITextField! = nil) {
        prefs.dictionary[dictionaryKeys[dictionaryPickerView.selectedRow(inComponent: 0)]] = dictionaryTextEntry.text ?? ""
        saveDefaultsToSettings()
    }
    
    /* ################################################################## */
    /**
     Called when the Date Picker changes.
     
     - parameter: Ignored (also, optional)
     */
    @IBAction func dateChanged(_: UIDatePicker! = nil) {
        prefs.date = datePicker.date
        saveDefaultsToSettings()
    }
    
    /* ################################################################## */
    /**
     Called when the user taps in the main view. We close the keyboard.
     
     - parameter: Ignored (also, optional)
     */
    @IBAction func closeKeyboard(_: Any! = nil) {
        view.currentFirstResponder?.resignFirstResponder()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This loads the values from the main defaults, and sets them into our stored prefs.
     */
    func loadDefaultsFromSettings() {
        #if DEBUG
            print("Loading Defaults from Settings")
        #endif
        prefs.keys.forEach {
            if let value = UserDefaults.standard.object(forKey: $0) {
                #if DEBUG
                    print("\t\($0) is Being Set to \(value)")
                #endif
                switch $0 {
                case "Integer Value":
                    if let valTmp = value as? String, let value = Int(valTmp) {
                        prefs[$0] = value
                    }
                    
                case "String Value":
                    if let value = value as? String {
                        prefs[$0] = value
                    }

                default:
                    ()
                }
            }
        }
        view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     This takes what's in our stored prefs, and saves them to the main defaults.
     */
    func saveDefaultsToSettings() {
        prefs.keys.forEach {
            switch $0 {
            case "Integer Value":
                if let value = prefs[$0] as? Int {
                    UserDefaults.standard.set(String(value), forKey: $0)
                }
                
            case "String Value":
                if let value = prefs[$0] as? String {
                    UserDefaults.standard.set(value, forKey: $0)
                }

            default:
                ()
            }
            UserDefaults.standard.set(prefs[$0], forKey: $0)
        }
    }
    
    /* ################################################################## */
    /**
     This resets all the values to whatever the prefs have in store for us.
     */
    func setValues() {
        // Set up the initial state of the Integer text entry value.
        intTextEntry?.text = String(prefs.int)
        
        // Set up the initial state of the String text entry value.
        stringTextEntry?.text = prefs.string
        
        // Set up the initial state of the Date label and picker.
        datePicker?.date = prefs.date
        arrayPickerView.reloadAllComponents()
        dictionaryPickerView.reloadAllComponents()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view initially loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get whatever is in settings, in case the user changed them while we were out.
        loadDefaultsFromSettings()
        // Set up the initial state of the Integer label and text entry value.
        intLabel?.text = prefs.intKey.localizedVariant
        
        // Set up the initial state of the String label and text entry value.
        stringLabel?.text = prefs.stringKey.localizedVariant
        
        // Set up the initial state of the Array label.
        arrayLabel?.text = prefs.arrayKey.localizedVariant
        
        // Set up the initial state of the Dictionary label.
        dictionaryLabel?.text = prefs.dictionaryKey.localizedVariant
        
        // Set up the initial state of the Date label and picker.
        dateLabel?.text = prefs.dateKey.localizedVariant
        
        // Set up the localized title of the reset button.
        resetButton?.setTitle(resetButton?.title(for: .normal)?.localizedVariant, for: .normal)
        
        // Select the first row of each.
        arrayPickerView?.selectRow(0, inComponent: 0, animated: false)
        dictionaryPickerView?.selectRow(0, inComponent: 0, animated: false)
        
        setValues()

        // Make sure the text field gets updated.
        pickerView(arrayPickerView, didSelectRow: 0, inComponent: 0)
        pickerView(dictionaryPickerView, didSelectRow: 0, inComponent: 0)
    }
    
    /* ################################################################## */
    /**
     Called when the view will lay out its subviews.
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setValues()
    }
    
    /* ############################################################################################################################## */
    // MARK: - UIPickerViewDataSource Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is the call to tell the Picker View how many components (always 1)
     
     - parameter inPickerView: The PickerView that is making the call (Ignored).
     
     - returns: 1 (always)
     */
    func numberOfComponents(in inPickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     This is the call to tell the Picker View how many components (always 1)
     
     - parameter inPickerView: The PickerView that is making the call (Ignored).
     - parameter numberOfRowsInComponent: The Selected Component (Ignored).
     
     - returns: 5 (always)
     */
    func pickerView(_ inPickerView: UIPickerView, numberOfRowsInComponent inComponent: Int) -> Int {
        return 5
    }
    
    /* ############################################################################################################################## */
    // MARK: - UIPickerViewDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is called to get the PickerView to return a Title.
     
     - parameter inPickerView: The PickerView that is making the call.
     - parameter titleForRow: The Selected Row.
     - parameter forComponent: The Selected Component.

     - returns: The title for the selected row, in the selected component of the selected picker.
     */
    func pickerView(_ inPickerView: UIPickerView, titleForRow inRow: Int, forComponent inComponent: Int) -> String? {
        if inPickerView == arrayPickerView {
            return String(inRow + 1)
        } else if 0 < dictionaryKeys.count {
            return dictionaryKeys[inRow].localizedVariant
        } else {
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a new row is selected in a picker. It sets up the text entry field.
     
     - parameter inPickerView: The PickerView that is making the call.
     - parameter titleForRow: The Selected Row.
     - parameter inComponent: The Selected Component (ignored).
     */
    func pickerView(_ inPickerView: UIPickerView, didSelectRow inRow: Int, inComponent: Int) {
        if inPickerView == arrayPickerView, 0 < prefs.array.count {
            arrayTextEntry?.text = String(prefs.array[inRow])
        } else if 0 < dictionaryKeys.count {
            dictionaryTextEntry?.text = prefs.dictionary[dictionaryKeys[inRow]]
        }
    }
}
