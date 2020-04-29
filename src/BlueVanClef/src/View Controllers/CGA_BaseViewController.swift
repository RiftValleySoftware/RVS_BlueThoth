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
// MARK: - The Base view controller Class -
/* ###################################################################################################################################### */
/**
 This class exists only to manage the background, navbar and logo image.
 If we are in Dark Mode, or High-Contrast Mode, we make the background black, and reduce the prominence of the logo.
 */
class CGA_BaseViewController: UIViewController {
    /* ################################################################## */
    /**
     This is a simple accessor for the app persistent preferences.
     */
    var prefs: CGA_PersistentPrefs! { CGA_AppDelegate.appDelegateObject?.prefs }
    
    /* ################################################################## */
    /**
     Returns true, if we are in Dark or High Contrast Mode.
     */
    var isDarkMode: Bool { UIAccessibility.isDarkerSystemColorsEnabled || .dark == traitCollection.userInterfaceStyle }
    
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
     
     This is used to give our navbar a responsive appearance, and to hide the logo, if we are in high contrast mode.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // We give a black background for either dark mode, or high-contrast mode.
        navigationController?.navigationBar.barTintColor = isDarkMode ? .clear : navigationController?.navigationBar.barTintColor
        // We reduce the contrast for Dark Mode. High-contrast mode hides the logo completely.
        logoImage?.alpha = (.dark == traitCollection.userInterfaceStyle) ? (UIAccessibility.isDarkerSystemColorsEnabled ? 0 : 0.05) : (logoImage?.alpha ?? 0)
    }
}
