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

import Cocoa

/* ################################################################################################################################## */
// MARK: - Main View Controller Class
/* ################################################################################################################################## */
/**
 This controls the basic preferences-setting dialog.
 */
class RVS_PersistentPrefs_macOS_TestHarness_ViewController: NSViewController {
    /* ############################################################################################################################## */
    // MARK: - Static Constants
    /* ############################################################################################################################## */
    /// The main prefs key.
    static let prefsKey = "RVS_PersistentPrefs_macOS_TestHarness_Prefs"
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /// This is the preferences object. It is instantiated at runtime, and left on its own.
    private var _prefs: RVS_PersistentPrefs_TestSet!
    
    /* ################################################################## */
    /**
     This is a direct accessor to the prefs object for this controller.
     */
    @objc dynamic var prefs: RVS_PersistentPrefs_TestSet {
        return nil == _prefs ? RVS_PersistentPrefs_TestSet(key: RVS_PersistentPrefs_macOS_TestHarness_ViewController.prefsKey) : _prefs
    }

    /* ############################################################################################################################## */
    // MARK: - Instance @IBOutlet Properties
    /* ############################################################################################################################## */
    /// The label for the Integer Value.
    @IBOutlet weak var integerValueLabel: NSTextField!
    /// The label for the String Value.
    @IBOutlet weak var stringValueLabel: NSTextField!
    /// The label for the Array Value.
    @IBOutlet weak var arrayViewLabel: NSTextField!
    /// The popup menu to select Array elements.
    @IBOutlet weak var arraySelectorPopup: NSPopUpButton!
    /// The text edit field to change values stored in the Array.
    @IBOutlet weak var arrayEditorTextField: NSTextField!
    /// This is the label for the Dictionary Editor.
    @IBOutlet weak var dictionaryValueLabel: NSTextField!
    /// The popup for selecting a Dictionary value.
    @IBOutlet weak var dictionarySelectorPopup: NSPopUpButton!
    ///The Text Field for editing Dictionary Values.
    @IBOutlet weak var dictionaryEditorTextField: NSTextField!
    /// The label for the date picker.
    @IBOutlet weak var dateValueLabel: NSTextField!
    /// The RESET button
    @IBOutlet weak var resetButton: NSButton!
    
    // Unfortunately, in order to make sure that the fields get updated when I reset, I will need to specifically reference them.
    /// This is the text field for Integer entry.
    @IBOutlet weak var integerTextField: NSTextField!
    /// This is the text field for String entry
    @IBOutlet weak var stringTextField: NSTextField!
    /// This is the date picker for the date.
    @IBOutlet weak var dateEntry: NSDatePicker!
    
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
    // MARK: - @IBAction Handler Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the Array popup is changed.
     
     - parameter inPopup: The popup control.
     */
    @IBAction func arraySelectorPopupChanged(_ inPopup: NSPopUpButton) {
        arrayEditorTextField.stringValue = prefs.array[inPopup.indexOfSelectedItem]
    }
    
    /* ################################################################## */
    /**
     Called when the text is changed in the Array editor.
     
     - parameter inEditableTextField: The editable text field.
     */
    @IBAction func arraValueTextChanged(_ inEditableTextField: NSTextField) {
        prefs.array[arraySelectorPopup.indexOfSelectedItem] = inEditableTextField.stringValue
    }
    
    /* ################################################################## */
    /**
     Called when the Dictionary popup is changed.
     
     - parameter inPopup: The popup control.
     */
    @IBAction func dictionarySelectorPopupChanged(_ inPopup: NSPopUpButton) {
        dictionaryEditorTextField.stringValue = prefs.dictionary[dictionaryKeys[inPopup.indexOfSelectedItem]] ?? "ERROR"
    }
    
    /* ################################################################## */
    /**
     Called when the text is changed in the Dictionary editor.
     
     - parameter inEditableTextField: The editable text field.
     */
    @IBAction func dictionaryValueTextChanged(_ inEditableTextField: NSTextField) {
        prefs.dictionary[dictionaryKeys[dictionarySelectorPopup.indexOfSelectedItem]] = inEditableTextField.stringValue
    }
    
    /* ################################################################## */
    /**
     Called when the RESET button is hit.
     
     - parameter ignored.
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
     Sets the values of the various items.
     */
    func setValues() {
        integerTextField.stringValue = String(prefs.int)
        stringTextField.stringValue = prefs.string
        dateEntry.dateValue = prefs.date
        
        arraySelectorPopup.selectItem(at: 0)
        arraySelectorPopupChanged(arraySelectorPopup)
        
        dictionaryValueLabel.stringValue = prefs.dictionaryKey.localizedVariant
        
        dictionarySelectorPopup.selectItem(at: 0)
        dictionarySelectorPopupChanged(dictionarySelectorPopup)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the view has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        integerValueLabel.stringValue = prefs.intKey.localizedVariant
        
        stringValueLabel.stringValue = prefs.stringKey.localizedVariant
        
        arrayViewLabel.stringValue = prefs.arrayKey.localizedVariant
        
        dateValueLabel.stringValue = prefs.dateKey.localizedVariant
        
        resetButton.title = resetButton.title.localizedVariant
        
        arraySelectorPopup.removeAllItems()
        for i in prefs.array.enumerated() {
            arraySelectorPopup.addItem(withTitle: String(i.offset + 1))
        }
        
        dictionarySelectorPopup.removeAllItems()
        dictionaryKeys.forEach {
            dictionarySelectorPopup.addItem(withTitle: $0.localizedVariant)
        }
        
        setValues()
    }
}
