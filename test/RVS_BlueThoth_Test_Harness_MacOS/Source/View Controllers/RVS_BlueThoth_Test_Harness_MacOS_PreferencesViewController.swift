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
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        ignoreDupesCheckbox?.title = ignoreDupesCheckbox?.title.localizedVariant ?? "ERROR"
        allowEmptyNamesCheckbox?.title = allowEmptyNamesCheckbox?.title.localizedVariant ?? "ERROR"
        onlyConnectableCheckbox?.title = onlyConnectableCheckbox?.title.localizedVariant ?? "ERROR"
        alwaysUseCRLFCheckbox?.title = alwaysUseCRLFCheckbox?.title.localizedVariant ?? "ERROR"
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PreferencesViewController {
    /* ################################################################## */
    /**
     */
    private func _setUpAccessibility() {
        
    }
}
