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

import WatchKit
import Foundation
import RVS_BlueThoth_WatchOS

/* ###################################################################################################################################### */
// MARK: - Prefs Modal Screen Controller -
/* ###################################################################################################################################### */
/**
 This controls the modal prefs ("more") screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_AboutInterfaceController: WKInterfaceController {
    /* ################################################################## */
    /**
     This label displays the app version, extracted from the bundle.
     */
    @IBOutlet weak var versionLabel: WKInterfaceLabel!
    
    /* ################################################################## */
    /**
     This displays the info text.
     */
    @IBOutlet weak var infoLabel: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_AboutInterfaceController {
    /* ################################################################## */
    /**
     Establishes accessibility labels.
     */
    func setAccessibility() {
        versionLabel?.setAccessibilityLabel(String(format: "SLUG-ACC-APP-VERSION-LABEL-FORMAT".localizedVariant, Bundle.main.appVersionString, Bundle.main.appVersionBuildString))
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_AboutInterfaceController {
    /* ################################################################## */
    /**
     Called as the View is set up.
     
     - parameter withContext: The context provided to the view, as it was instantiated.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        setTitle("SLUG-DONE".localizedVariant)
        versionLabel?.setText(String(format: "SLUG-VERSION-FORMAT".localizedVariant, Bundle.main.appVersionString, Bundle.main.appVersionBuildString))
        infoLabel.setText("SLUG-MAIN-INFO-TEXT".localizedVariant)
        setAccessibility()
    }
}
