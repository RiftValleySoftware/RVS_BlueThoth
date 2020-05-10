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
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
/**
 */
class RVS_PersistentPrefs_tvOS_TestHarness_ViewController: UIViewController {
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /// This is the preferences object. It is instantiated at runtime, and left on its own.
    var prefs = RVS_PersistentPrefs_TestSet(key: RVS_PersistentPrefs_tvOS_TestHarness_AppDelegate.prefsKey)
    
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
    // MARK: - @IBOutlet Instance Properties
    /* ############################################################################################################################## */
    /// The label for the Integer value text entry.
    @IBOutlet weak var integerValueLabel: UILabel!
    /// The Integer value text entry.
    @IBOutlet weak var integerValueTextField: UITextField!
    /// The label for the String value text entry.
    @IBOutlet weak var stringValueLabel: UILabel!
    /// The String value text entry.
    @IBOutlet weak var stringValueTextField: UITextField!
    /// The label for the Array values
    @IBOutlet weak var arrayValueLabel: UILabel!
    /// A segmented switch that allows you to select which Array element is to be edited.
    @IBOutlet weak var arraySelectionSegmentedSwitch: UISegmentedControl!
    /// A Text entry that allows you to edit the selected Array element.
    @IBOutlet weak var arrayValueTextField: UITextField!
    /// The label for the Dictionary Items.
    @IBOutlet weak var dictionaryValueLabel: UILabel!
    /// A segmented switch that allows you to select which Dictionary key to use.
    @IBOutlet weak var dictionarySelectionSegmentedSwitch: UISegmentedControl!
    /// The Dictionary text for the selected item.
    @IBOutlet weak var dictionaryValueTextEntry: UITextField!
    
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var dateValueTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    /* ############################################################################################################################## */
    // MARK: - @IBAction Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when text changes in the Integer value text field
     
     - parameter: Ignored.
     */
    @IBAction func integerValueTextFieldChanged(_: UITextField) {
        prefs.int = Int(integerValueTextField?.text ?? "0") ?? 0
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the String value text field
     
     - parameter: Ignored.
     */
    @IBAction func stringValueTextFieldChanged(_: Any) {
        prefs.string = stringValueTextField?.text ?? ""
    }
    
    /* ################################################################## */
    /**
     Called when the Array Item Selection changes.
     
     - parameter: Ignored.
     */
    @IBAction func arraySelectionSegmentedSwitchChanged(_: Any! = nil) {
        // Set up the initial state of the Array text entry value.
        arrayValueTextField?.text = prefs.array[arraySelectionSegmentedSwitch.selectedSegmentIndex]
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the Array value text field
     
     - parameter: Ignored.
     */
    @IBAction func arrayValueTextFieldChanged(_: Any) {
        prefs.array[arraySelectionSegmentedSwitch.selectedSegmentIndex] = arrayValueTextField.text ?? ""
    }
    
    /* ################################################################## */
    /**
     Called when the Dictionary Item Selection changes.
     
     - parameter: Ignored.
     */
    @IBAction func dictionarySelectionSegmentedControlChanged(_: Any! = nil) {
        dictionaryValueTextEntry?.text = prefs.dictionary[dictionaryKeys[dictionarySelectionSegmentedSwitch.selectedSegmentIndex]]
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the Dictionary value text field
     
     - parameter: Ignored.
     */
    @IBAction func dictionaryValueTextFieldChanged(_: Any) {
        prefs.dictionary[dictionaryKeys[dictionarySelectionSegmentedSwitch.selectedSegmentIndex]] = dictionaryValueTextEntry.text ?? ""
    }
    
    /* ################################################################## */
    /**
     Called when text changes in the Date value text field
     
     - parameter: Ignored.
     */
    @IBAction func dateValueTextFieldChanged(_: Any) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.isLenient = true
        
        if  let dateString = dateValueTextField.text,
            let date = dateFormatter.date(from: dateString) {
            prefs.date = date
            if !dateValueTextField.isEditing {  // Tie it up in a neat bow.
                dateValueTextField.text = dateFormatter.string(from: prefs.date)
            }
        }
    }

    /* ################################################################## */
    /**
     Called when the RESET button is hit.
     
     - parameter: Ignored.
     */
    @IBAction func resetButtonHit(_: Any) {
        prefs.reset()
        setValues()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This resets all the values to whatever the prefs have in store for us.
     */
    func setValues() {
        // Set up the initial state of the Integer text entry value.
        integerValueTextField?.text = String(prefs.int)
        
        // Set up the initial state of the String text entry value.
        stringValueTextField?.text = prefs.string
        
        // Set up the initial state of the Array text entry value.
        arrayValueTextField?.text = prefs.array[0]
        
        // Forces the Array Text to set to the selected value (0, usually).
        arraySelectionSegmentedSwitchChanged()
        
        for i in dictionaryKeys.enumerated() {
            dictionarySelectionSegmentedSwitch.setTitle(i.element.localizedVariant, forSegmentAt: i.offset)
        }
        
        // Forces the Dictionary Text to set to the selected value (0, usually).
        dictionarySelectionSegmentedControlChanged()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        
        dateValueTextField.text = dateFormatter.string(from: prefs.date)
    }

    /* ############################################################################################################################## */
    // MARK: - Base Class Override Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view initially loads.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the initial state of the labels.
        integerValueLabel?.text = prefs.intKey.localizedVariant
        stringValueLabel?.text = prefs.stringKey.localizedVariant
        arrayValueLabel?.text = prefs.arrayKey.localizedVariant
        dictionaryValueLabel?.text = prefs.dictionaryKey.localizedVariant
        dateValueLabel?.text = prefs.dateKey.localizedVariant
        arraySelectionSegmentedSwitch.selectedSegmentIndex = 0
        dictionarySelectionSegmentedSwitch.selectedSegmentIndex = 0
        resetButton.setTitle(resetButton.title(for: .normal)?.localizedVariant, for: .normal)
        setValues()
    }
}
