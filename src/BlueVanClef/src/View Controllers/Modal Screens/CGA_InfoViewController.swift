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

/* ###################################################################################################################################### */
// MARK: - The About view controller -
/* ###################################################################################################################################### */
/**
 This controls the about this app view.
 */
class CGA_InfoViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     The label that displays the app name.
     */
    @IBOutlet weak var appNameLabel: UILabel!
    
    /* ################################################################## */
    /**
     The label just below the app name label, displaying the version.
     */
    @IBOutlet weak var appVersionLabel: UILabel!

    /* ################################################################## */
    /**
     The button at the bottom that will link to the site.
     */
    @IBOutlet weak var copyrightButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_InfoViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    private func _setUpAccessibility() {
        appNameLabel?.accessibilityLabel = String(format: "SLUG-ACC-APP-NAME-LABEL-FORMAT".localizedVariant, Bundle.main.appDisplayName)
        appVersionLabel?.accessibilityLabel = String(format: "SLUG-ACC-APP-VERSION-LABEL-FORMAT".localizedVariant, Bundle.main.appVersionString, Bundle.main.appVersionBuildString)
        copyrightButton?.accessibilityLabel = "SLUG-ACC-COPYRIGHT-BUTTON".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_InfoViewController {
    /* ################################################################## */
    /**
     Called when the copyright button is hit.
     
     - parameter: ignored
     */
    @IBAction func copyrightButtonHit(_: Any) {
        guard let uri = Bundle.main.siteURI else { return }
        
        UIApplication.shared.open(uri)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension CGA_InfoViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        appNameLabel?.text = Bundle.main.appDisplayName
        appVersionLabel?.text = String(format: "SLUG-VERSION-FORMAT".localizedVariant, Bundle.main.appVersionString, Bundle.main.appVersionBuildString)
        copyrightButton.setTitle(Bundle.main.copyrightString, for: .normal)
        _setUpAccessibility()
    }
    
    /* ################################################################## */
    /**
     This allows us to restart scanning in the main screen, if it was running before we were called.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if  let navigationController = presentingViewController as? UINavigationController,
            0 < navigationController.viewControllers.count,
            let presenter = navigationController.viewControllers[0] as? CGA_ScannerViewController {
            presenter.restartScanningIfNecessary()
        }
    }
}
