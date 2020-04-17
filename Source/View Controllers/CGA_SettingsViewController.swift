/*
© Copyright 2020, Little Green Viper Software Development LLC

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

Little Green Viper Software Development LLC: https://littlegreenviper.com
*/

import UIKit

/* ###################################################################################################################################### */
// MARK: - The Settings View Controller -
/* ###################################################################################################################################### */
/**
 This controls the settings view.
 */
class CGA_SettingsViewController: UIViewController {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var ignoreDuplicatesScanningSwitch: UISwitch!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var ignoreDuplicatesSwitchButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     */
    @IBAction func ignoreDuplicatesSwitchHit(_ inSwitch: UISwitch) {
        CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals = inSwitch.isOn
        updateUI()
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func ignoreDuplicatesButtonHit(_: Any) {
        CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals = !CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     */
    func updateUI() {
        ignoreDuplicatesScanningSwitch?.setOn(CGA_AppDelegate.appDelegateObject.prefs.continuouslyUpdatePeripherals, animated: true)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension CGA_SettingsViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        ignoreDuplicatesSwitchButton?.setTitle(ignoreDuplicatesSwitchButton?.title(for: .normal)?.localizedVariant, for: .normal)
        updateUI()
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
