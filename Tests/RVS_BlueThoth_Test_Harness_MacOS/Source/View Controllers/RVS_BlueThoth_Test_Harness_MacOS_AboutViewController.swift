/*
© Copyright 2020-2022, The Great Rift Valley Software Company

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
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - The About Screen View Controller -
/* ###################################################################################################################################### */
/**
 This is the Info/About screen.
 */
class RVS_BlueThoth_Test_Harness_MacOS_AboutViewController: NSViewController {
    /* ################################################################## */
    /**
     The app version label.
     */
    @IBOutlet weak var versionLabel: NSTextField!
    
    /* ################################################################## */
    /**
     The label that contains the main app info.
     */
    @IBOutlet weak var mainInfoLabel: NSTextField!
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_AboutViewController {
    /* ################################################################## */
    /**
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = title?.localizedVariant
        versionLabel?.stringValue = String(format: "SLUG-VERSION-FORMAT".localizedVariant, Bundle.main.appVersionString, Bundle.main.appVersionBuildString)
        mainInfoLabel?.stringValue = (mainInfoLabel?.stringValue ?? "ERROR").localizedVariant
        _setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_AboutViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    private func _setUpAccessibility() {
        versionLabel?.setAccessibilityTitle(String(format: "SLUG-ACC-APP-VERSION-LABEL-FORMAT".localizedVariant, Bundle.main.appVersionString, Bundle.main.appVersionBuildString))
    }
}
