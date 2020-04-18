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
// MARK: - The Main Application Delegate -
/* ###################################################################################################################################### */
/**
 The primary application delegate for the app.
 */
@UIApplicationMain
class CGA_AppDelegate: UIResponder, UIApplicationDelegate {
    /* ################################################################## */
    /**
     Displays the given message and title in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter message: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    static func displayAlert(_ inTitle: String, message inMessage: String ) {
        #if DEBUG
            print("ALERT:\t\(inTitle)\n\t\t\(inMessage)")
        #endif
        DispatchQueue.main.async {  // In case we're called off-thread...
            if let presentedBy = appDelegateObject.window?.rootViewController {
                let alertController = UIAlertController(title: inTitle, message: inMessage, preferredStyle: .actionSheet)
                
                let okAction = UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: UIAlertAction.Style.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy.present(alertController, animated: true, completion: nil)
            } else {
                #if DEBUG
                    print("ERROR! No top view controller!")
                #endif
            }
        }
    }
    
    /* ################################################################## */
    /**
     This will change the app orientation mask to what is provided.
     It can be used to force orientation of the interface.
     It records the interface orientation prior to the change, so that can be restored later.
     
     - parameter inOrientation: The orientation that should be locked.
     */
    class func lockOrientation(_ inOrientation: UIInterfaceOrientationMask) {
        Self.appDelegateObject?.orientationLock = inOrientation
    }
    
    /* ################################################################## */
    /**
     This will force the screen to ignore the accelerometer setting and force the screen into that orientation.
     
     - parameter inOrientation: The orientation that should be locked.
     - parameter andRotateTo: The orientation that should be forced.
     */
    class func lockOrientation(_ inOrientation: UIInterfaceOrientationMask, andRotateTo inRotateOrientation: UIInterfaceOrientation) {
        lockOrientation(inOrientation)
        UIDevice.current.setValue(inRotateOrientation.rawValue, forKey: "orientation")
    }
    
    /* ################################################################## */
    /**
     This will return the app orientation to the state it was before the orientation was locked.
     This is not 100% perfect. If, for example, the device was landscape, then the user physically rotated it to portrait after this call, the rotation will return to landscape, even if the device is still portrait.
     */
    class func unlockOrientation() {
        lockOrientation(.allButUpsideDown)
    }

    /* ################################################################## */
    /**
     This is the Bluetooth Central Manager instance. Everything goes through this.
     */
    static var centralManager: CGA_Bluetooth_CentralManager?

    /* ################################################################## */
    /**
     Used to force orientation for the Settings screen.
     */
    var orientationLock = UIInterfaceOrientationMask.allButUpsideDown
    
    /* ################################################################## */
    /**
     The required window property.
     */
    var window: UIWindow?
    
    /* ################################################################## */
    /**
     Quick access to the app delegate object.
     */
    class var appDelegateObject: CGA_AppDelegate! { UIApplication.shared.delegate as? CGA_AppDelegate }
    
    /* ################################################################## */
    /**
     This will contain our persistent prefs
     */
    var prefs = CGA_PersistentPrefs()

    /* ################################################################## */
    /**
     Called upon application initialization and setup.
     
     - returns: True (always)
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
    
    /* ################################################################## */
    /**
     This is used to lock the orientation while the timer editor is up.
     
     - parameter: ignored
     - parameter supportedInterfaceOrientationsFor: ignored
     */
    func application(_: UIApplication, supportedInterfaceOrientationsFor: UIWindow?) -> UIInterfaceOrientationMask { orientationLock }
}
