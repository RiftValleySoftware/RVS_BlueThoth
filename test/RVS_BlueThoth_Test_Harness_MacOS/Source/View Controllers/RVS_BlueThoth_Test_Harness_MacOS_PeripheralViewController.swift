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
import RVS_BlueThoth_MacOS

/* ###################################################################################################################################### */
// MARK: - The Peripheral Screen View Controller -
/* ###################################################################################################################################### */
/**
 */
class RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController: RVS_BlueThoth_MacOS_Test_Harness_Base_SplitView_ViewController {
    /* ################################################################## */
    /**
     This is the storyboard ID that we use to create an instance of this view.
     */
    static let storyboardID  = "peripheral-view-controller"
    
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
     This is the outer container of the Services tableView.
     */
    @IBOutlet weak var serviceTableContainerView: NSScrollView!
    
    /* ################################################################## */
    /**
     This is the spinner that is displayed while the device is being connected.
     */
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var disconnectButton: NSButton!
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
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
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController {
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
        disconnectButton?.title = (disconnectButton?.title ?? "").localizedVariant
        setUpAccessibility()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen appears.
     We use this to register with the app delegate.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        #if DEBUG
            print("Connecting to Peripheral.")
        #endif
        appDelegateObject.screenList.addScreen(self)
        peripheralInstance?.connect()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen disappears.
     We use this to un-register with the app delegate.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        #if DEBUG
            print("Disconnecting from Peripheral.")
        #endif
        peripheralInstance?.disconnect()
        appDelegateObject.screenList.removeScreen(self)
    }
    
    /* ################################################################## */
    /**
     Sets up the various accessibility labels.
     */
    override func setUpAccessibility() {
        loadingSpinner?.setAccessibilityLabel("SLUG-ACC-CONNECTING-LABEL".localizedVariant)
        loadingSpinner?.toolTip = "SLUG-ACC-CONNECTING-LABEL".localizedVariant
        
        disconnectButton?.setAccessibilityLabel("SLUG-ACC-DISCONNECT-LABEL".localizedVariant)
        disconnectButton?.toolTip = "SLUG-ACC-DISCONNECT-LABEL".localizedVariant
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
            disconnectButton?.isHidden = true
            serviceTableContainerView?.isHidden = true
            return
        }
        
        if device.isConnected {
            stopLoadingAnimation()
            disconnectButton?.isHidden = false
            serviceTableContainerView?.isHidden = false
        } else {
            serviceTableContainerView?.isHidden = true
            disconnectButton?.isHidden = true
            startLoadingAnimation()
        }
    }
}

/* ################################################################################################################################## */
// MARK: - NSTableViewDelegate/DataSource Methods
/* ################################################################################################################################## */
extension RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController: NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     Called to supply the number of rows in the table.
     
     - parameters:
        - inTableView: The table instance.
     
     - returns: A 1-based Int, with 0 being no rows.
     */
    func numberOfRows(in inTableView: NSTableView) -> Int { 0 }

    /* ################################################################## */
    /**
     This is called to supply the string display for one row that corresponds to a device.
     
     - parameters:
        - inTableView: The table instance.
        - objectValueFor: Container object for the column that holds the row.
        - row: 0-based Int, with the index of the row, within the column.
     
     - returns: A String, with the device name.
     */
    func tableView(_ inTableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row inRow: Int) -> Any? { "ERROR" }
    
    /* ################################################################## */
    /**
     Called to indicate whether or not the row is a group header (indicated by no value).
     
     - parameters:
        - inTableView: The table instance.
        - isGroupRow: The 0-based Int index of the row.
     
     - returns: True, if this is a group header row.
     */
    func tableView(_ inTableView: NSTableView, isGroupRow inRow: Int) -> Bool { false }

    /* ################################################################## */
    /**
     This is called when a row is selected. We match the device to the row, set that in the semaphore, and approve the selection.
     
     - parameters:
        - inTableView: The table instance.
        - shouldSelectRow: 0-based Int, with the index of the row, within the column.
     
     - returns: False (always).
     */
    func tableView(_ inTableView: NSTableView, shouldSelectRow inRow: Int) -> Bool { false }

    /* ################################################################## */
    /**
     Called after the selection was set up and approved.
     
     We open a modal window, with the device info.
     
     - parameter: Ignored
     */
    func tableViewSelectionDidChange(_: Notification) {
    }
}
