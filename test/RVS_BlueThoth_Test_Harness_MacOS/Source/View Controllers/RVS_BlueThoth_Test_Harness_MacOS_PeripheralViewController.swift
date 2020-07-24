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

import Cocoa
import CoreBluetooth
import RVS_BlueThoth_MacOS

/* ###################################################################################################################################### */
// MARK: - The Peripheral Screen View Controller -
/* ###################################################################################################################################### */
/**
 */
class RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController: RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     This is the storyboard ID that we use to create an instance of this view.
     */
    static let storyboardID  = "peripheral-view-controller"
    
    /* ################################################################## */
    /**
     This is the spinner that is displayed while the device is being connected.
     */
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var disconnectButton: NSButton!
    
    /* ################################################################## */
    /**
     This is the Peripheral instance associated with this screen.
     */
    var peripheralInstance: RVS_BlueThoth.DiscoveryData? {
        didSet {
            updateUI()
        }
    }

    /* ################################################################## */
    /**
     The main split view
     */
    var mainSplitView: RVS_BlueThoth_Test_Harness_MacOS_SplitViewController! {
        guard let parent = parent as? RVS_BlueThoth_Test_Harness_MacOS_SplitViewController else { return nil }
        
        return parent
    }
}

extension RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController {
    /* ################################################################## */
    /**
     Called when the disconnect button is hit, or we want to disconnect the device.
     
     - parameter: ignored. Can be omitted.
     */
    @IBAction func disconnectThisPeripheral(_: Any! = nil) {
        peripheralInstance?.disconnect()
        mainSplitView?.setDetailsViewController()
    }

    /* ################################################################## */
    /**
     This shows and starts the loading spinner.
     */
    func startLoadingAnimation() {
        loadingSpinner?.startAnimation(nil)
        loadingSpinner?.isHidden = false
    }
    
    /* ################################################################## */
    /**
     This stops and hides the loading spinner.
     */
    func stopLoadingAnimation() {
        loadingSpinner?.isHidden = true
        loadingSpinner?.stopAnimation(nil)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController {
    /* ################################################################## */
    /**
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen appears.
     We use this to register with the app delegate.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        #if DEBUG
            print("Connecting to Peripheral From Screen.")
        #endif
        appDelegateObject.screenList.addScreen(self)
        startLoadingAnimation()
        peripheralInstance?.connect()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen disappears.
     We use this to un-register with the app delegate.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        peripheralInstance?.disconnect()
        appDelegateObject.screenList.removeScreen(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController: RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol {
    /* ################################################################## */
    /**
     This is a String key that uniquely identifies this screen.
     */
    var key: String { peripheralInstance?.identifier ?? "ERROR" }

    /* ################################################################## */
    /**
     This forces the UI elements to be updated.
     */
    func updateUI() {
        guard let device = peripheralInstance else {
            stopLoadingAnimation()
            return
        }
        
        if device.isConnected {
            stopLoadingAnimation()
        } else {
            startLoadingAnimation()
        }
    }
}
