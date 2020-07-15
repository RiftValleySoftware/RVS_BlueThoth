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
// MARK: - The Initial Screen View Controller -
/* ###################################################################################################################################### */
/**
 */
class RVS_BlueThoth_Test_Harness_MacOS_InitialViewController: RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController {
    /* ################################################################## */
    /**
     This enum has the scanning on/off states, expressed as 0-based Int.
     */
    enum ScanningModeSwitchValues: Int {
        /// The SDK is not scanning for Peripherals.
        case notScanning
        /// The SDK is scanning for Peripherals.
        case scanning
    }
    
    /* ################################################################## */
    /**
     The segue ID for displaying a peripheral window.
     */
    static private let _peripheralWindowSegueID = "peripheral-window-display"

    /* ################################################################## */
    /**
     This is a String key that uniquely identifies this screen.
     */
    let key: String = RVS_BlueThoth_Test_Harness_MacOS_AppDelegate.mainScreenID
    
    /* ################################################################## */
    /**
     The currently selected device (nil, if no device selected).
     */
    private var _selectedDevice: CGA_Bluetooth_Peripheral?
    
    /* ################################################################## */
    /**
     This is a segmented switch that reflects the state of the scanning.
     */
    @IBOutlet weak var scanningModeSegmentedSwitch: NSSegmentedControl!
    
    /* ################################################################## */
    /**
     This contains the Peripheral List table.
     */
    @IBOutlet weak var tableContainerScrollView: NSScrollView!

    /* ################################################################## */
    /**
     This is the Peripheral List table.
     */
    @IBOutlet weak var deviceTable: NSTableView!
    
    /* ################################################################## */
    /**
     This is the image that is shown if Bluetooth is not available.
     */
    @IBOutlet weak var noBTImage: NSImageView!
    
    /* ################################################################## */
    /**
     Called when the scanning/not scanning sgmented switch changes.
     
     - parameter inSwitch: The switch object.
     */
    @IBAction func scanningChanged(_ inSwitch: NSSegmentedControl) {
        if ScanningModeSwitchValues.notScanning.rawValue == inSwitch.selectedSegment {
            centralManager?.stopScanning()
        } else {
            centralManager?.startScanning()
        }
        
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - P{rivate Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_InitialViewController {
    /* ################################################################## */
    /**
     Sets up the various accessibility labels.
     */
    private func _setUpAccessibility() {
        scanningModeSegmentedSwitch?.setAccessibilityLabel("SLUG-ACC-SCANNING-BUTTON-O" + ((ScanningModeSwitchValues.notScanning.rawValue == scanningModeSegmentedSwitch?.selectedSegment) ? "FF" : "N"))
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_InitialViewController {
    /* ################################################################## */
    /**
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        scanningModeSegmentedSwitch?.setLabel(scanningModeSegmentedSwitch?.label(forSegment: ScanningModeSwitchValues.notScanning.rawValue)?.localizedVariant ?? "ERROR", forSegment: ScanningModeSwitchValues.notScanning.rawValue)
        scanningModeSegmentedSwitch?.setLabel(scanningModeSegmentedSwitch?.label(forSegment: ScanningModeSwitchValues.scanning.rawValue)?.localizedVariant ?? "ERROR", forSegment: ScanningModeSwitchValues.scanning.rawValue)
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen appears.
     We use this to register with the app delegate.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        appDelegateObject.screenList.addScreen(self)
    }
    
    /* ################################################################## */
    /**
     Called just before the screen disappears.
     We use this to un-register with the app delegate.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        appDelegateObject.screenList.removeScreen(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_InitialViewController: RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol {
    /* ################################################################## */
    /**
     This forces the UI elements to be updated.
     */
    func updateUI() {
        scanningModeSegmentedSwitch?.isHidden = !(centralManager?.isBTAvailable ?? false)
        tableContainerScrollView?.isHidden = !(centralManager?.isBTAvailable ?? false)
        noBTImage?.isHidden = !(tableContainerScrollView?.isHidden ?? true)
        
        scanningModeSegmentedSwitch?.setSelected(true, forSegment: (centralManager?.isScanning ?? false) ? ScanningModeSwitchValues.scanning.rawValue : ScanningModeSwitchValues.notScanning.rawValue)
        
        _setUpAccessibility()
        
        deviceTable?.reloadData()
    }
}

/* ################################################################################################################################## */
// MARK: - NSTableViewDelegate/DataSource Methods
/* ################################################################################################################################## */
extension RVS_BlueThoth_Test_Harness_MacOS_InitialViewController: NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     Called to supply the number of rows in the table.
     
     - parameters:
        - inTableView: The table instance.
     
     - returns: A 1-based Int, with 0 being no rows.
     */
    func numberOfRows(in inTableView: NSTableView) -> Int { centralManager?.stagedBLEPeripherals.count ?? 0 }

    /* ################################################################## */
    /**
     This is called to supply the string display for one row that corresponds to a device.
     
     - parameters:
        - inTableView: The table instance.
        - objectValueFor: Container object for the column that holds the row.
        - row: 0-based Int, with the index of the row, within the column.
     
     - returns: A String, with the device name.
     */
    func tableView(_ inTableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row inRow: Int) -> Any? {
        if  let device = centralManager?.stagedBLEPeripherals[inRow],
            !device.preferredName.isEmpty {
            return device.preferredName
        }
        
        return "NO DEVICE NAME"
    }
    
    /* ################################################################## */
    /**
     This is called when a row is selected. We match the device to the row, set that in the semaphore, and approve the selection.
     
     - parameters:
        - inTableView: The table instance.
        - shouldSelectRow: 0-based Int, with the index of the row, within the column.
     
     - returns: False (always).
     */
    func tableView(_ inTableView: NSTableView, shouldSelectRow inRow: Int) -> Bool {
        if  let device = centralManager?.stagedBLEPeripherals[inRow] {
            #if DEBUG
                print("Row \(inRow) was selected.")
            #endif
            _selectedDevice = device.peripheralInstance
            return true
        }
        
        _selectedDevice = nil
        return false
    }
    
    /* ################################################################## */
    /**
     Called after the selection was set up and approved.
     
     We open a modal window, with the device info.
     
     - parameter: Ignored
     */
    func tableViewSelectionDidChange(_: Notification) {
        if  let device = _selectedDevice,
            let newController = storyboard?.instantiateController(withIdentifier: RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController.storyboardID) as? RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController {
            newController.peripheralInstance = device
            presentAsModalWindow(newController)
        }
        
        _selectedDevice = nil
        deviceTable.deselectAll(nil)
    }
}
