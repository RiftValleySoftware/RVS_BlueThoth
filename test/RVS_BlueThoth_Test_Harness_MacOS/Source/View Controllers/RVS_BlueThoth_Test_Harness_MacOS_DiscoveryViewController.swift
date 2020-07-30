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
class RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController: RVS_BlueThoth_MacOS_Test_Harness_Base_SplitView_ViewController {
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
     This is a String key that uniquely identifies this screen.
     */
    let key: String = RVS_BlueThoth_Test_Harness_MacOS_AppDelegate.deviceScreenID
    
    /* ################################################################## */
    /**
     This will map the discovered devices for display in the table. The key is the ID of the Peripheral. The value is all the rows it will display.
     */
    private var _tableMap: [String: [String]] = [:]
    
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
     This is the "Start Over From Scratch" button.
     */
    @IBOutlet weak var reloadButton: NSButton!

    /* ################################################################## */
    /**
     The currently selected device (nil, if no device selected).
     */
    var selectedDevice: RVS_BlueThoth.DiscoveryData?
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     This is a complete count of all advertisement data rows, and headers.
     */
    private var _completeTableMapRowCount: Int { _tableMap.reduce(0) { (current, next) -> Int in current + 1 + next.value.count } }

    /* ################################################################## */
    /**
     This just helps us to keep the table in a predictable order.
     */
    private var _sortedDevices: [String] { _tableMap.keys.sorted() }
    
    /* ################################################################## */
    /**
     This builds a "map" of the device data, so we can build a table from it.
     */
    private func _buildTableMap() {
        _tableMap = [:]
        
        guard let centralManager = centralManager else { return }
        
        for index in 0..<centralManager.stagedBLEPeripherals.count {
            _tableMap[centralManager.stagedBLEPeripherals[index].identifier] = _createAdvertimentStringsFor(index)
        }
    }
    
    /* ################################################################## */
    /**
     - parameter inDeviceID: The key for the device in our table.
     - returns: Index, in the main table Array, for this device. Can be nil.
     */
    private func _indexOfThisDevice(_ inDeviceID: String) -> Int? { _sortedDevices.firstIndex(where: {$0 == inDeviceID}) }
    
    /* ################################################################## */
    /**
     - parameter inDeviceID: The key for the device in our table.
     - returns: The number of advertisement strings for the given device.
     */
    private func _numberOfStringsForThisDevice(_ inDeviceID: String) -> Int { _tableMap[inDeviceID]?.count ?? 0 }

    /* ################################################################## */
    /**
     This returns the Peripheral wrapper instance, associated with a particular table index.

     - parameter inIndex: The 0-based row index.
     - returns: The discovery data struct for the indexed device.
     */
    private func _getIndexedDevice(_ inIndex: Int) -> RVS_BlueThoth.DiscoveryData? {
        var index: Int = 0
        
        for key in _sortedDevices {
            guard let device = centralManager?.stagedBLEPeripherals[key] else { return nil }
            
            if index == inIndex {
                return device
            } else if let advertisingData = _tableMap[key] {
                for _ in 0..<advertisingData.count {
                    if index == inIndex {
                        return device
                    }
                    index += 1
                }
            }
            
            index += 1
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This returns the row string, along with whether or not it is a header, for the indexed row.
     
     - parameter inIndex: The 0-based row index.
     - returns: a tuple, containing the string value, and a boolean flag, indicating whether or not it is a header.
     */
    private func _getIndexedTableMapRow(_ inIndex: Int) -> (value: String, isHeader: Bool) {
        var index: Int = 0
        
        for key in _sortedDevices {
            guard let device = centralManager?.stagedBLEPeripherals[key] else { return (value: "", isHeader: false) }
            
            if index == inIndex {
                return (value: device.preferredName.isEmpty ? device.localName.isEmpty ? device.name.isEmpty ? "SLUG-NO-DEVICE-NAME".localizedVariant : device.name : device.localName : device.preferredName, isHeader: true)
            } else if let advertisingData = _tableMap[key] {
                for advData in advertisingData {
                    index += 1
                    if index == inIndex {
                        return (value: advData, isHeader: false)
                    }
                }
            }
            
            index += 1
        }
        
        return (value: "", isHeader: false)
    }
    
    /* ################################################################## */
    /**
     This returns a range, with the row indexes of all the rows belonging to the device that contains the given row.
     
     - parameter inIndex: The 0-based index of the selected row.
     - returns: An Int Range, containing all the indexes involved in the selected device.
     */
    private func _getAllRowIndexesForGroupContainingThisRowIndex(_ inIndex: Int) -> Range<Int>? {
        var totalIndex = 0

        for group in _tableMap {
            let range = (totalIndex..<totalIndex + group.value.count + 1)
            if range.contains(inIndex) {
                return range
            }
            totalIndex = range.upperBound
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     Returns a string, with the name of a staged (discovered, but not connected) device.
     
     - parameter inDeviceIndex: The 0-based index of the device, in the staged Array.
     - returns: A String, with the device name, or text explaining the error.
     */
    private func _stagedDeviceName(_ inDeviceIndex: Int) -> String {
        guard let device = centralManager?.stagedBLEPeripherals[inDeviceIndex] else { return "SLUG-NO-DEVICE-FOUND".localizedVariant }
        
        return  !device.preferredName.isEmpty ? device.preferredName :
                !device.localName.isEmpty ? device.localName :
                !device.name.isEmpty ? device.name : "SLUG-NO-DEVICE-NAME".localizedVariant
    }
    
    /* ################################################################## */
    /**
     This creates an Array of String, containing the advertisement data from the indexed device.
     
     - parameter inIndex: The 0-based index of the device to fetch.
     - returns: An Array of String, with the advertisement data in "key: value" form.
     */
    private func _createAdvertimentStringsFor(_ inIndex: Int) -> [String] {
        guard let centralManager = centralManager, (0..<centralManager.stagedBLEPeripherals.count).contains(inIndex) else { return [] }
        
        let id = centralManager.stagedBLEPeripherals[inIndex].identifier
        let adData = centralManager.stagedBLEPeripherals[inIndex].advertisementData
        
        return _createAdvertimentStringsFor(adData, id: id)
    }
    
    /* ################################################################## */
    /**
     This creates an Array of String, containing the advertisement data from the indexed device.
     
     - parameter inAdData: The advertisement data.
     - parameter id: The ID string.
     - returns: An Array of String, with the advertisement data in "key: value" form.
     */
    private func _createAdvertimentStringsFor(_ inAdData: RVS_BlueThoth.AdvertisementData?, id inID: String) -> [String] {
        // This gives us a predictable order of things.
        guard let sortedAdDataKeys = inAdData?.advertisementData.keys.sorted() else { return [] }
        let sortedAdData: [(key: String, value: Any?)] = sortedAdDataKeys.compactMap { (key:$0, value: inAdData?.advertisementData[$0]) }

        let retStr = sortedAdData.reduce("SLUG-ID".localizedVariant + ": \(inID)") { (current, next) in
            let key = next.key.localizedVariant
            let value = next.value
            var ret = "\(current)\n"
            
            if let asStringArray = value as? [String] {
                ret += current + asStringArray.reduce("\t\(key): ") { (current2, next2) in "\(current2)\n\(next2.localizedVariant)" }
            } else if let value = value as? String {
                ret += "\t\(key): \(value.localizedVariant)"
            } else if let value = value as? Bool {
                ret += "\t\(key): \(value ? "true" : "false")"
            } else if let value = value as? Int {
                ret += "\t\(key): \(value)"
            } else if let value = value as? Double {
                if "kCBAdvDataTimestamp" == next.key {  // If it's the timestamp, we can translate that, here.
                    let date = Date(timeIntervalSinceReferenceDate: value)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "SLUG-MAIN-LIST-DATE-FORMAT".localizedVariant
                    let displayedDate = dateFormatter.string(from: date)
                    ret += "\t\(key): \(displayedDate)"
                } else {
                    ret += "\t\(key): \(value)"
                }
            } else {    // Anything else is just a described instance of something or other.
                ret += "\t\(key): \(String(describing: value))"
            }
            
            return ret
        }.split(separator: "\n").map { String($0) }
        
        return retStr
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController {
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
    
    /* ################################################################## */
    /**
     Sets up the various accessibility labels.
     */
    override func setUpAccessibility() {
        reloadButton?.setAccessibilityLabel("SLUG-ACC-RELOAD-BUTTON".localizedVariant)
        reloadButton?.toolTip = "SLUG-ACC-RELOAD-BUTTON".localizedVariant
        scanningModeSegmentedSwitch?.setAccessibilityLabel(("SLUG-ACC-SCANNING-BUTTON-O" + ((ScanningModeSwitchValues.notScanning.rawValue == scanningModeSegmentedSwitch?.selectedSegment) ? "FF" : "N").localizedVariant))
        scanningModeSegmentedSwitch?.toolTip = ("SLUG-ACC-SCANNING-BUTTON-O" + ((ScanningModeSwitchValues.notScanning.rawValue == scanningModeSegmentedSwitch?.selectedSegment) ? "FF" : "N")).localizedVariant
        
        tableContainerScrollView?.setAccessibilityLabel("SLUG-ACC-DEVICELIST-TABLE-MAC".localizedVariant)
        tableContainerScrollView?.toolTip = "SLUG-ACC-DEVICELIST-TABLE-MAC".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Handlers -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     Called when the scanning/not scanning segmented switch changes.
     
     - parameter inSwitch: The switch object.
     */
    @IBAction func scanningChanged(_ inSwitch: NSSegmentedControl) {
        if ScanningModeSwitchValues.notScanning.rawValue == inSwitch.selectedSegment {
            centralManager?.stopScanning()
        } else {
            centralManager?.scanCriteria = prefs.scanCriteria
            centralManager?.minimumRSSILevelIndBm = prefs.minimumRSSILevel
            centralManager?.discoverOnlyConnectablePeripherals = prefs.discoverOnlyConnectableDevices
            centralManager?.allowEmptyNames = prefs.allowEmptyNames
            _tableMap = [:]
            deviceTable?.reloadData()
            centralManager?.startScanning(duplicateFilteringIsOn: !prefs.continuouslyUpdatePeripherals)
        }
        
        updateUI()
    }

    /* ################################################################## */
    /**
     This is the "Start Over From Scratch" button.
     
     - parameter: ignored
     */
    @IBAction func reloadButtonHit(_: NSButton) {
        mainSplitView?.setPeripheralViewController()
        centralManager?.startOver()
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController: RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol {
    /* ################################################################## */
    /**
     This forces the UI elements to be updated.
     */
    func updateUI() {
        scanningModeSegmentedSwitch?.isHidden = !(centralManager?.isBTAvailable ?? false)
        tableContainerScrollView?.isHidden = !(centralManager?.isBTAvailable ?? false)
        noBTImage?.isHidden = !(tableContainerScrollView?.isHidden ?? true)
        reloadButton?.isHidden = (0 == (centralManager?.stagedBLEPeripherals.count ?? 0))
        scanningModeSegmentedSwitch?.setSelected(true, forSegment: (centralManager?.isScanning ?? false) ? ScanningModeSwitchValues.scanning.rawValue : ScanningModeSwitchValues.notScanning.rawValue)
        
        setUpAccessibility()
        _buildTableMap()
        
        if nil == selectedDevice {
            deviceTable?.deselectAll(nil)
        }
        
        deviceTable?.reloadData()
    }
}

/* ################################################################################################################################## */
// MARK: - NSTableViewDelegate/DataSource Methods
/* ################################################################################################################################## */
extension RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController: NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     Called to supply the number of rows in the table.
     
     - parameters:
        - inTableView: The table instance.
     
     - returns: A 1-based Int, with 0 being no rows.
     */
    func numberOfRows(in inTableView: NSTableView) -> Int { _completeTableMapRowCount }

    /* ################################################################## */
    /**
     This is called to supply the string display for one row that corresponds to a device.
     
     - parameters:
        - inTableView: The table instance.
        - objectValueFor: Container object for the column that holds the row.
        - row: 0-based Int, with the index of the row, within the column.
     
     - returns: A String, with the device name.
     */
    func tableView(_ inTableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row inRow: Int) -> Any? { _getIndexedTableMapRow(inRow).value }
    
    /* ################################################################## */
    /**
     Called to indicate whether or not the row is a group header (indicated by no value).
     
     - parameters:
        - inTableView: The table instance.
        - isGroupRow: The 0-based Int index of the row.
     
     - returns: True, if this is a group header row.
     */
    func tableView(_ inTableView: NSTableView, isGroupRow inRow: Int) -> Bool { _getIndexedTableMapRow(inRow).isHeader }

    /* ################################################################## */
    /**
     This is called when a row is selected. We match the device to the row, set that in the semaphore, and approve the selection.
     
     - parameters:
        - inTableView: The table instance.
        - shouldSelectRow: 0-based Int, with the index of the row, within the column.
     
     - returns: False (always).
     */
    func tableView(_ inTableView: NSTableView, shouldSelectRow inRow: Int) -> Bool {
        deviceTable?.deselectAll(nil)
        if  let peripheral = _getIndexedDevice(inRow),
            selectedDevice?.identifier != peripheral.identifier {
            #if DEBUG
                print("Row \(inRow) was selected.")
            #endif
            selectedDevice = peripheral
            if let selectedRange = _getAllRowIndexesForGroupContainingThisRowIndex(inRow) {
                deviceTable?.selectRowIndexes(IndexSet(integersIn: selectedRange), byExtendingSelection: true)
            }
        }

        return false
    }

    /* ################################################################## */
    /**
     Called after the selection was set up and approved.
     
     We open a modal window, with the device info.
     
     - parameter: Ignored
     */
    func tableViewSelectionDidChange(_: Notification) {
        if  let device = selectedDevice,
            let newController = storyboard?.instantiateController(withIdentifier: RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController.storyboardID) as? RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController {
            #if DEBUG
                print("Connecting to another Peripheral.")
            #endif
            newController.peripheralInstance = device
            mainSplitView?.setPeripheralViewController(newController)
        }
    }
}
