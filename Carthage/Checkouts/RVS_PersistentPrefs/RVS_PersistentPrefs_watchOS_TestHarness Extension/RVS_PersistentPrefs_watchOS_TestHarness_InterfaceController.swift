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

import WatchKit
import Foundation

/* ################################################################################################################################## */
// MARK: - Main Interface Controller Class.
/* ################################################################################################################################## */
/**
 This is an interface controller for a super-simple display. It merely has two items, in a vertical stack: The Integer Value and the String Value.
 */
class RVS_PersistentPrefs_watchOS_TestHarness_InterfaceController: WKInterfaceController {
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is an accessor for the prefs instance. It fetches a reference to it from the extension delegate.
     */
    var prefs: RVS_PersistentPrefs_TestSet! {
        return RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate.delegateObject?.prefs
    }
    
    /* ############################################################################################################################## */
    // MARK: - @IBOutlet Instance Properties
    /* ############################################################################################################################## */
    /// The label for the Integer Value display.
    @IBOutlet weak var integerKeyLabel: WKInterfaceLabel!
    /// The actual display for the Integer Value.
    @IBOutlet weak var integerValueLabel: WKInterfaceLabel!
    /// The label for the String Value display.
    @IBOutlet weak var stringKeyLabel: WKInterfaceLabel!
    /// The actual String Value display.
    @IBOutlet weak var stringValueLabel: WKInterfaceLabel!
    /// The RESET button.
    @IBOutlet weak var resetButton: WKInterfaceButton!

    /* ############################################################################################################################## */
    // MARK: - @IBAction Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the RESET button is hit. We reset the prefs, and send an update to the phone.
     */
    @IBAction func resetButtonHit() {
        resetButton.setEnabled(false)   // Disable the button until we hear back from the phone.
        RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate.delegateObject?.sendResetToPhone()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called to set up our labels to reflect the current values.
     */
    func setUpLabels() {
        DispatchQueue.main.async {
            self.resetButton.setTitle("RESET TO DEFAULT".localizedVariant)
            self.prefs?.keys.forEach { key in
                switch key {
                case "Integer Value":
                    if let value = self.prefs[key] as? Int {
                        self.integerKeyLabel?.setText(key.localizedVariant)
                        self.integerValueLabel?.setText(String(value))
                    } else {
                        self.integerKeyLabel?.setText("ERROR!")
                        self.integerValueLabel?.setText("ERROR!")
                    }
                case "String Value":
                    if let value = self.prefs[key] as? String {
                        self.stringKeyLabel?.setText(key.localizedVariant)
                        self.stringValueLabel?.setText(String(value))
                    } else {
                        self.stringKeyLabel?.setText("ERROR!")
                        self.stringValueLabel?.setText("ERROR!")
                    }
                default:
                    ()
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called by the extension delegate to re-enable the disabled RESET button.
     */
    func reEnableButton() {
        resetButton.setEnabled(true)
    }
    
    /* ############################################################################################################################## */
    // MARK: - Base Class Override Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the app awakens, creaks out of its coffin, and demands blood.
     
     - parameter withContext: Any context passed in from the caller.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        setUpLabels()
    }
}
