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
    class func displayAlert(_ inTitle: String, message inMessage: String ) {
        #if DEBUG
            print("ALERT:\t\(inTitle)\n\t\t\(inMessage)")
        #endif
        DispatchQueue.main.async {  // In case we're called off-thread...
            if  let navController = appDelegateObject.window?.rootViewController as? UINavigationController,
                let presentedBy = navController.topViewController {
                // We use an alert for iPads, as action sheets are more complicated than we need for this.
                let alertController = UIAlertController(title: inTitle, message: inMessage, preferredStyle: .pad == presentedBy.traitCollection.userInterfaceIdiom ? .alert : .actionSheet)
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
     This creates an Array of String, containing the advertisement data from the indexed device.
     
     - parameter inIndex: The 0-based index of the device to fetch.
     - returns: An Array of String, with the advertisement data in "key: value" form.
     */
    class func createAdvertimentStringsFor(_ inIndex: Int) -> [String] {
        guard let centralManager = centralManager, (0..<centralManager.stagedBLEPeripherals.count).contains(inIndex) else { return [] }
        
        let id = centralManager.stagedBLEPeripherals[inIndex].identifier
        let adData = centralManager.stagedBLEPeripherals[inIndex].advertisementData
        
        return createAdvertimentStringsFor(adData, id: id)
    }
    
    /* ################################################################## */
    /**
     This creates an Array of String, containing the advertisement data from the indexed device.
     
     - parameter inAdData: The advertisement data.
     - parameter id: The ID string.
     - returns: An Array of String, with the advertisement data in "key: value" form.
     */
    class func createAdvertimentStringsFor(_ inAdData: RVS_BlueThoth.AdvertisementData?, id inID: String) -> [String] {
        // This gives us a predictable order of things.
        guard let sortedAdDataKeys = inAdData?.advertisementData.keys.sorted() else { return [] }
        let sortedAdData: [(key: String, value: Any?)] = sortedAdDataKeys.compactMap { (key:$0, value: inAdData?.advertisementData[$0]) }

        let retStr = sortedAdData.reduce("SLUG-ID".localizedVariant + ": \(inID)") { (current, next) in
            let key = next.key.localizedVariant
            let value = next.value
            var ret = "\(current)\n"
            
            if let asStringArray = value as? [String] {
                ret += current + asStringArray.reduce("\(key): ") { (current2, next2) in
                    return "\(current2)\n\(next2.localizedVariant)"
                }
            } else if let value = value as? String {
                ret += "\(key): \(value.localizedVariant)"
            } else if let value = value as? Bool {
                ret += "\(key): \(value ? "true" : "false")"
            } else if let value = value as? Int {
                ret += "\(key): \(value)"
            } else if let value = value as? Double {
                if "kCBAdvDataTimestamp" == next.key {  // If it's the timestamp, we can translate that, here.
                    let date = Date(timeIntervalSinceReferenceDate: value)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "SLUG-MAIN-LIST-DATE-FORMAT".localizedVariant
                    let displayedDate = dateFormatter.string(from: date)
                    ret += "\(key): \(displayedDate)"
                } else {
                    ret += "\(key): \(value)"
                }
            } else {    // Anything else is just a described instance of something or other.
                ret += "\(key): \(String(describing: value))"
            }
            
            return ret
        }.split(separator: "\n").map { String($0) }
        
        return retStr
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
    static var centralManager: RVS_BlueThoth?

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
     
     - parameter: Ignored
     - parameter didFinishLaunchingWithOptions: Ignored
     - returns: True (always)
     */
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
    
    /* ################################################################## */
    /**
     This is used to lock the orientation while the timer editor is up.
     
     - parameter: ignored
     - parameter supportedInterfaceOrientationsFor: ignored
     */
    func application(_: UIApplication, supportedInterfaceOrientationsFor: UIWindow?) -> UIInterfaceOrientationMask { orientationLock }
    
    /* ################################################################## */
    /**
     Called when the application is about to enter the background.
     
     - parameter: Ignored
     */
    func applicationDidEnterBackground(_: UIApplication) {
        Self.centralManager?.disconnectAllPeripherals()
    }
}
