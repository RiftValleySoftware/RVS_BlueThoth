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

import WatchKit
import Foundation
import RVS_BlueThoth_WatchOS

/* ###################################################################################################################################### */
// MARK: - Base Class for Interface Controllers -
/* ###################################################################################################################################### */
/**
 This is a protocol that allows us to have predictable methods for screen instances.
 */
protocol RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol {
    /* ################################################################## */
    /**
     REQUIRED: This is called to update the UI of the controller to reflect the current state of the driver.
     */
    func updateUI()
}

/* ###################################################################################################################################### */
// MARK: - Base Class for Interface Controllers -
/* ###################################################################################################################################### */
/**
 This is a base class for screen instance View Controllers.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_Base: WKInterfaceController, RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol {
    /* ################################################################## */
    /**
     This is a stored property that each screen sets to its ID.
     */
    var id = ""

    /* ################################################################## */
    /**
     Simple accessor to the main extension delegate instance.
     */
    var extensionDelegateInstance: RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate? { RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.extensionDelegateObject }
    
    /* ################################################################## */
    /**
     Returns the Central manager BlueThoth instance.
     */
    var centralManager: RVS_BlueThoth? { extensionDelegateInstance?.centralManager }
    
    /* ################################################################## */
    /**
     This accesses our stored preferences.
     */
    var prefs: CGA_PersistentPrefs? { extensionDelegateInstance?.prefs }

    /* ################################################################## */
    /**
     Displays an alert.
     
     - parameter inTitle: REQUIRED: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter message: OPTIONAL: a string to be displayed as the message of the alert. It is localized by this method.
     */
    func displayAlert(header inTitle: String, message inMessage: String = "") {
        RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.displayAlert(header: inTitle, message: inMessage, from: self)
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_Base {
    /* ################################################################## */
    /**
     Default does nothing.
     It has to be objc dynamic, to allow override.
     */
    @objc dynamic func updateUI() { }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_Base {
    /* ################################################################## */
    /**
     Called after the view has been set up.
     
     - parameter withContext: The context being passed in.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
    }
    
    /* ################################################################## */
    /**
     Called just before the view activates.
     */
    override func willActivate() {
        super.willActivate()
        let id = self.id
        print("Registering: \(id)")
        extensionDelegateInstance?.screenList[id] = self
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just after the view deactivates.
     */
    override func didDeactivate() {
        super.didDeactivate()
        if  let extensionDelegateObject = RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.extensionDelegateObject,
            1 < extensionDelegateObject.screenList.count {
            extensionDelegateObject.screenList[id] = nil
        }
    }
}
