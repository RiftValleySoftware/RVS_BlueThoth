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
import RVS_BlueThoth_TVOS

/* ###################################################################################################################################### */
// MARK: - Preferences Extension -
/* ###################################################################################################################################### */
extension CGA_PersistentPrefs {
    /* ################################################################## */
    /**
     This is the scan criteria object to be used for filtering scans.
     It is provided in the struct required by the Bluetooth subsystem.
     */
    var scanCriteria: RVS_BlueThoth.ScanCriteria! { RVS_BlueThoth.ScanCriteria(peripherals: peripheralFilterIDArray, services: serviceFilterIDArray, characteristics: characteristicFilterIDArray) }
}

/* ###################################################################################################################################### */
// MARK: - The Main App Delegate -
/* ###################################################################################################################################### */
/**
 This implements the main application delegate functionality.
 */
@UIApplicationMain
class CGA_AppDelegate: UIResponder {
    /* ################################################################## */
    /**
     This is the Bluetooth Central Manager instance. Everything goes through this.
     */
    static var centralManager: RVS_BlueThoth?

    /* ################################################################## */
    /**
     Quick access to the app delegate object.
     */
    class var appDelegateObject: CGA_AppDelegate! { UIApplication.shared.delegate as? CGA_AppDelegate }

    /* ################################################################## */
    /**
     The required window instance.
     */
    var window: UIWindow?

    /* ################################################################## */
    /**
     This will contain our persistent prefs
     */
    var prefs = CGA_PersistentPrefs()
}

/* ###################################################################################################################################### */
// MARK: - Class Functions -
/* ###################################################################################################################################### */
extension CGA_AppDelegate {
    /* ################################################################## */
    /**
     Displays the given message and title in an alert with an "OK" button.
     
     - parameter header: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter message: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(header inHeader: String, message inMessage: String = "", presentedBy inPresentingViewController: UIViewController! = nil) {
        // This ensures that we are on the main thread.
        DispatchQueue.main.async {
            var presentedBy = inPresentingViewController
            
            if nil == presentedBy {
                presentedBy = (UIApplication.shared.windows.filter { $0.isKeyWindow }.first)?.rootViewController
            }
            
            if nil == presentedBy {
                presentedBy = UIApplication.shared.delegate?.window??.rootViewController
            }

            if nil != presentedBy {
                let style: UIAlertController.Style = ((.pad == presentedBy?.traitCollection.userInterfaceIdiom) || false) ? .alert : .actionSheet
                let alertController = UIAlertController(title: inHeader, message: inMessage, preferredStyle: style)

                let okAction = UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: UIAlertAction.Style.cancel, handler: nil)
                
                alertController.addAction(okAction)
                
                presentedBy?.present(alertController, animated: true, completion: nil)
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
            } else if let value = value as? NSArray {   // An NSArray can be strung together in one line.
                ret += "\(key): " + value.reduce("", { (curr, nxt) -> String in (!curr.isEmpty ? ", " : "") + curr + String(describing: nxt).localizedVariant })
            } else {    // Anything else is just a described instance of something or other.
                ret += "\(key): \(String(describing: value))"
            }

            return ret
        }.split(separator: "\n").map { String($0) }
        
        return retStr
    }
}

/* ###################################################################################################################################### */
// MARK: - UIApplicationDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_AppDelegate: UIApplicationDelegate {
    /* ################################################################## */
    /**
     Called when the application has completed its launch setup.
     
     - parameter: The application instance.
     - parameter didFinishLaunchingWithOptions: The launch options, as a Dictionary.
     
     - returns: true, if the application to finish launch. False will abort the launch.
     */
    func application(_: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { true }
}
