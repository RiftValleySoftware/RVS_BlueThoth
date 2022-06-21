/**
© Copyright 2019, The Great Rift Valley Software Company

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

import Cocoa
import RVS_BlueThoth

/* ################################################################################################################################## */
// MARK: - Controller List Protocol
/* ################################################################################################################################## */
/**
 This protocol defines the requirements for any View Controller that will be listed by the App Delegate.
 */
protocol RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol {
    /* ################################################################## */
    /**
     This is a String key that uniquely identifies this screen. It must be unique for the Array.
     */
    var key: String { get }
    
    /* ################################################################## */
    /**
     This forces the UI elements to be updated.
     */
    func updateUI()
    
    /* ################################################################## */
    /**
     If the screen is associated with a Peripheral, that Peripheral is exposed here. It can be nil.
     */
    var peripheralInstance: RVS_BlueThoth.DiscoveryData? { get }
}

/* ################################################################################################################################## */
// MARK: - Controller List Protocol Defaults
/* ################################################################################################################################## */
extension RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol {
    /* ################################################################## */
    /**
     Default is nil.
     */
    var peripheralInstance: RVS_BlueThoth.DiscoveryData? { nil }
}

/* ################################################################################################################################## */
// MARK: - The Base (Common) View Controller Class
/* ################################################################################################################################## */
/**
 This class provides some common tools for all view controllers.
 */
class RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController: NSViewController { }

/* ################################################################################################################################## */
// MARK: - Instance Computed Properties
/* ################################################################################################################################## */
extension RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     This is an accessor to our app delegate object. READ-ONLY
     */
    @objc dynamic var appDelegateObject: RVS_BlueThoth_Test_Harness_MacOS_AppDelegate { RVS_BlueThoth_Test_Harness_MacOS_AppDelegate.appDelegateObject }
    
    /* ################################################################## */
    /**
     This is an accessor to our shared prefs object.
     */
    @objc dynamic var prefs: CGA_PersistentPrefs { appDelegateObject.prefs }

    /* ################################################################## */
    /**
     This is the Bluetooth Central Manager instance. Everything goes through this.
     */
    @objc dynamic var centralManager: RVS_BlueThoth? { appDelegateObject.centralManager }
}

/* ################################################################################################################################## */
// MARK: - Instance Methods
/* ################################################################################################################################## */
extension RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     This displays a simple alert, with an OK button.
     
     - parameter header: The header to display at the top.
     - parameter message: A String, containing whatever messge is to be displayed below the header.
     */
    func displayAlert(header inHeader: String, message inMessage: String = "") {
        RVS_BlueThoth_Test_Harness_MacOS_AppDelegate.displayAlert(header: inHeader, message: inMessage)
    }
    
    /* ################################################################## */
    /**
     Sets up the various accessibility labels.
     
     The base implementation is empty.
     */
    @objc func setUpAccessibility() { }
}

/* ################################################################################################################################## */
// MARK: - Basic Split View Component Window Controller Class
/* ################################################################################################################################## */
/**
This is for views designed to be displayed in the split view.
*/
class RVS_BlueThoth_MacOS_Test_Harness_Base_SplitView_ViewController: RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     The main split view
     */
    var mainSplitView: RVS_BlueThoth_Test_Harness_MacOS_SplitViewController! {
        guard let parent = parent as? RVS_BlueThoth_Test_Harness_MacOS_SplitViewController else { return nil }
        
        return parent
    }
}
