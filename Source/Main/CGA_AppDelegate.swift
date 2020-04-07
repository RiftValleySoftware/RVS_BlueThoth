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
// MARK: -
/* ###################################################################################################################################### */
/**
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
    static func displayAlert(_ inTitle: String, message inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        #if DEBUG
            print("ALERT:\t\(inTitle)\n\t\t\(inMessage)")
        #endif
        DispatchQueue.main.async {  // In case we're called off-thread...
            guard let presentedBy = inPresentingViewController else { return }
            
            let alertController = UIAlertController(title: inTitle, message: inMessage, preferredStyle: .actionSheet)
            
            let okAction = UIAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: UIAlertAction.Style.cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            presentedBy.present(alertController, animated: true, completion: nil)
        }
    }

    /* ################################################################## */
    /**
     */
    static var centralManager: CGA_Bluetooth_CentralManager?

    /* ################################################################## */
    /**
     */
    var window: UIWindow?
    
    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableView Extension -
/* ###################################################################################################################################### */
extension UITableView {
    /* ################################################################## */
    /**
     This will deselect all selected rows.
     
     - parameter animated: This can be ignored (defaults to false). If true, the deselection is animated.
     - returns: an Array of IndexPath, denoting the rows that were deselected. Can be ignored.
     */
    @discardableResult
    func deselectAll(animated inAnimated: Bool = false) -> [IndexPath] {
        if  let indexPaths = indexPathsForSelectedRows,
            !indexPaths.isEmpty {
            indexPaths.forEach {
                deselectRow(at: $0, animated: inAnimated)
            }
            
            return indexPaths
        }
        return []
    }
}
