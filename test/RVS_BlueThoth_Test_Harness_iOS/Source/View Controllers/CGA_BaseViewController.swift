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
import RVS_BlueThoth_iOS

/* ###################################################################################################################################### */
// MARK: - Simple Protocol That Defines A UI Updater Method -
/* ###################################################################################################################################### */
/**
 We use this to ensure that all our View Controllers can get a generic "Update Thyself" message.
 */
protocol CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     Do whatever is necessary to update the UI.
     */
    func updateUI()
}

/* ###################################################################################################################################### */
// MARK: - The CGA_ServiceContainer Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows us to associate a Service instance with any instance we want.
 */
protocol CGA_ServiceContainer: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     The Service that is associated with this instance.
     */
    var serviceInstance: CGA_Bluetooth_Service? { get }
}

/* ###################################################################################################################################### */
// MARK: - The CGA_CharacteristicContainer Protocol -
/* ###################################################################################################################################### */
/**
 This protocol allows us to associate a Characteristic instance with any instance we want.
 */
protocol CGA_CharacteristicContainer: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     The Characteristic that is associated with this instance.
     */
    var characteristicInstance: CGA_Bluetooth_Characteristic? { get }
}

/* ###################################################################################################################################### */
// MARK: - The Base view controller Class -
/* ###################################################################################################################################### */
/**
 This class exists only to manage the background, navbar and logo image.
 If we are in Dark Mode, or High-Contrast Mode, we make the background darker (and possibly monochromatic), and reduce the prominence of the logo.
 */
class CGA_BaseViewController: UIViewController {
    // These are all the colors and transparencies that we use for the various combinations of dark mode and high-contrast mode.
    
    // The NavBar
    // We adjust the NavBar color to fit the mode. Dark, High-Contrast Mode is just black.
    private let _darkMode_navbar_color: UIColor = UIColor(white: 0.065, alpha: 1.0)
    private let _darkMode_high_contrast_navbar_color: UIColor = .black
    private let _lightMode_navbar_color: UIColor = UIColor(red: 0.1, green: 0.9, blue: 0.4, alpha: 1.0)
    private let _lightMode_high_contrast_navbar_color: UIColor = UIColor(red: 0, green: 0.69, blue: 0.08, alpha: 1.0)
    
    // The BlueVanClef Logo
    // We reduce the alpha for Dark Mode. Dark, High-contrast Mode hides the logo completely.
    private let _darkMode_logo_alpha: CGFloat = 0.05
    private let _darkMode_high_contrast_logo_alpha: CGFloat = 0
    private let _lightMode_logo_alpha: CGFloat = 0.15
    private let _lightMode_high_contrast_logo_alpha: CGFloat = 0
    
    // The Background Gradient
    // In High-contrast Mode, we darken the background gradient a bit.
    private let _background_alpha: CGFloat = 1.0
    private let _high_contrast_background_alpha: CGFloat = 0.6

    /* ################################################################## */
    /**
     This is a simple accessor for the app persistent preferences.
     */
    var prefs: CGA_PersistentPrefs! { CGA_AppDelegate.appDelegateObject?.prefs }
    
    /* ################################################################## */
    /**
     This is the background gradient image behind each screen.
     */
    @IBOutlet weak var backgroundGradientImage: UIImageView!
    
    /* ################################################################## */
    /**
     This is the BlueVanClef logo image, displayed in the center of the screen.
     */
    @IBOutlet weak var logoImage: UIImageView!
    
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     
     This is used to set up the common elements for the appropriate mode.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = isHighContrastModeMode ?
            (isDarkMode ? _darkMode_high_contrast_navbar_color : _lightMode_high_contrast_navbar_color)
                : (isDarkMode ? _darkMode_navbar_color : _lightMode_navbar_color)
        
        logoImage?.alpha = isHighContrastModeMode ?
            (isDarkMode ? _darkMode_high_contrast_logo_alpha : _lightMode_high_contrast_logo_alpha)
                : (isDarkMode ? _darkMode_logo_alpha : _lightMode_logo_alpha)
        
        backgroundGradientImage?.alpha = isHighContrastModeMode ? _high_contrast_background_alpha : _background_alpha
    }
}
