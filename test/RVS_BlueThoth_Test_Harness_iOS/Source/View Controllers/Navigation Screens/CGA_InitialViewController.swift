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
// MARK: - Simple Protocol That Defines A Scan Restart Method and a "Was Scanning" property -
/* ###################################################################################################################################### */
/**
 This will allow us to "reflect" on the main view controller, without needing to look at the entire class.
 */
protocol CGA_ScannerViewController {
    /* ################################################################## */
    /**
     This is a method to restart scanning, if it was running beforehand. If not, nothing happens.
     */
    func restartScanningIfNecessary()
    
    /* ################################################################## */
    /**
     Used as a semaphore (yuck) to indicate that the Central was (or was not) scanning before the view disappeared.
     It is also used for editing the table, to prevent it from aborting deletes.
     */
    var wasScanning: Bool { get }
}

/* ###################################################################################################################################### */
// MARK: - Simple Protocol That Defines A UI Updater Method -
/* ###################################################################################################################################### */
/**
 We use this to ensure that all our View Controllers can get a generic "Update Thyself" message.
 */
protocol CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     Do whatever is necessary to update the UI.
     */
    func updateUI()
}

/* ###################################################################################################################################### */
// MARK: - The CGA_InitialViewController_TableRow Class (Denotes One Row of the Table) -
/* ###################################################################################################################################### */
/**
 This is a simple class that will be used to display one row in the initial discovery table.
 */
class CGA_InitialViewController_TableRow: UITableViewCell {
    /* ################################################################## */
    /**
     This will display the advertised name.
     */
    @IBOutlet var nameLabel: UILabel!

    /* ################################################################## */
    /**
     This will display the RSSI level, in dBm.
     */
    @IBOutlet var rssiLabel: UILabel!

    /* ################################################################## */
    /**
     This will wrap a dynamically-generated series of labels that will display the advertising data.
     */
    @IBOutlet var advertisingDataView: UIView!
}

/* ###################################################################################################################################### */
// MARK: - The initial view controller (table of devices) -
/* ###################################################################################################################################### */
/**
 This controls the initial view, which is a basic table of discovered devices.
 
 There are two sections: BLE, and BR/EDR (Classic). Each section has rows of devices that fit in that Bluetooth mode.
 */
class CGA_InitialViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     These are the indexes for our sections.
     */
    private enum _SectionIndexes: Int {
        /// The BLE section index.
        case ble
        /// Because we are Int, this will have the number of sections (1-based).
        case numSections
    }
    
    /* ################################################################## */
    /**
     The time between repeats of the RSSI update timer.
     */
    private static let _rssiTimerIntervalInSeconds: TimeInterval = 0.5
    
    /* ################################################################## */
    /**
     This is how high each section header will be.
     */
    private static let _sectionHeaderHeightInDisplayUnits: CGFloat = 21.0

    /* ################################################################## */
    /**
     This is how high the labels that comprise one row will need per line of text.
     */
    private static let _labelRowHeightInDisplayUnits: CGFloat = 21.0

    /* ################################################################## */
    /**
     The reuse ID that we use for creating new table cells.
     */
    private static let _deviceRowReuseID = "device-row"
    
    /* ################################################################## */
    /**
     The ID of the segue that is executed to display device details.
     */
    private static let _deviceDetailSegueID = "show-device-detail"

    /* ################################################################## */
    /**
     This implements a "pull to refresh."
     */
    private let _refreshControl = UIRefreshControl()
    
    /* ################################################################## */
    /**
     Returns the pushed device details screen. Nil, if none.
     */
    private var _currentDeviceScreen: CGA_UpdatableScreenViewController! { navigationController?.topViewController as? CGA_UpdatableScreenViewController }

    /* ################################################################## */
    /**
     Returns true, if the Central Manager is currently scanning.
     */
    var isScanning: Bool { CGA_AppDelegate.centralManager?.isScanning ?? false }
    
    /* ################################################################## */
    /**
     Used as a semaphore (yuck) to indicate that the Central was (or was not) scanning before the view disappeared.
     It is also used for editing the table, to prevent it from aborting deletes.
     */
    var wasScanning: Bool = false

    /* ################################################################## */
    /**
     This is the label above the table.
     */
    @IBOutlet weak var deviceLabel: UILabel!
    
    /* ################################################################## */
    /**
     This is the table that will list the discovered devices.
     */
    @IBOutlet weak var deviceTableView: UITableView!
    
    /* ################################################################## */
    /**
     This image is displayed if there is no bluetooth available.
     */
    @IBOutlet weak var noBTImage: UIImageView!
    
    /* ################################################################## */
    /**
     This will animate when the central is scanning.
     */
    @IBOutlet weak var scanningButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var editButtonStackView: UIStackView!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var editButton: UIButton!
    
    /* ################################################################## */
    /**
     This is the about/info button.
     */
    @IBOutlet weak var infoButton: UIButton!
    
    /* ################################################################## */
    /**
     This is the settings button.
     */
    @IBOutlet weak var settingsButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     This is called by the table's "pull to refresh" handler.
     
     When this is called, the Bluetooth subsystem wipes out all of its cached Peripherals, and starts over from scratch.
     
     - parameter: ignored.
     */
    @objc func startOver(_: Any) {
        CGA_AppDelegate.centralManager?.startOver()
        _refreshControl.endRefreshing()
    }
    
    /* ################################################################## */
    /**
     This is called when the "Scanning/Not Scanning" button is hit.
     
     - parameter: ignored.
     */
    @IBAction func scanningButtonHit(_: Any) {
        _toggleScanningMode()
        scanningButton.isEnabled = false
    }

    /* ################################################################## */
    /**
     
     - parameter: ignored.
     */
    @IBAction func editButtonHit(_: Any) {
        if !isScanning {
            deviceTableView?.isEditing = !(deviceTableView?.isEditing ?? true)
            updateUI()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Overridden Superclass Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        _refreshControl.tintColor = .white
        deviceTableView?.refreshControl = _refreshControl
        _refreshControl.addTarget(self, action: #selector(startOver(_:)), for: .valueChanged)
        CGA_AppDelegate.centralManager = RVS_BlueThoth(delegate: self)
        navigationItem.backBarButtonItem?.title = navigationItem.backBarButtonItem?.title?.localizedVariant
        scanningButton.setTitle(scanningButton.title(for: .normal)?.localizedVariant, for: .normal)
        deviceLabel?.text = deviceLabel?.text?.localizedVariant ?? "ERROR"
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use this to hide the navBar.
     
     - parameter inAnimated: True, if the appearance is animated (we ignore this).
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        deviceTableView?.deselectAll(animated: true)
        // We always make sure that nothing is connected.
        CGA_AppDelegate.centralManager?.forEach { $0.discoveryData?.disconnect() }
        
        navigationController?.navigationBar.isHidden = true
        if wasScanning {
            CGA_AppDelegate.centralManager?.restartScanning()
        }
        
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view disappears. We use this to show the navBar.
     
     - parameter inAnimated: True, if the appearance is animated (we ignore this).
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        wasScanning = isScanning
        CGA_AppDelegate.centralManager?.stopScanning()
        navigationController?.navigationBar.isHidden = false
        scanningButton?.isEnabled = false
    }
    
    /* ################################################################## */
    /**
     This is called just before we bring in the device screen (or the about screen).
     
     - parameter for: The segue being executed.
     - parameter sender: The data we want passed into the destination.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        // We only go further if we are looking at device details.
        guard   let destination = inSegue.destination as? CGA_PeripheralViewController,
                let senderData = inSender as? RVS_BlueThoth.DiscoveryData else {
                    wasScanning = isScanning
                    CGA_AppDelegate.centralManager?.stopScanning()
                    scanningButton?.isEnabled = false
            return
        }
        
        destination.deviceAdvInfo = senderData
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     Make sure that the Navigation Controller is at tits baseline.
     */
    private func _resetToRoot() {
        navigationController?.popToRootViewController(animated: false)
        deviceTableView?.deselectAll()
    }
    
    /* ################################################################## */
    /**
     Calling this toggles the scanning mode.
     */
    private func _toggleScanningMode() {
        if isScanning {
            _stopScanning()
        } else {
            _startScanning()
        }
    }
    
    /* ################################################################## */
    /**
     Starts scanning for Peripherals. If already scanning, nothing happens.
     */
    private func _startScanning() {
        let scanCriteria = prefs.scanCriteria
        deviceTableView.isEditing = false
        CGA_AppDelegate.centralManager?.scanCriteria = scanCriteria
        CGA_AppDelegate.centralManager?.minimumRSSILevelIndBm = prefs.minimumRSSILevel
        CGA_AppDelegate.centralManager?.discoverOnlyConnectablePeripherals = prefs.discoverOnlyConnectableDevices
        CGA_AppDelegate.centralManager?.allowEmptyNames = prefs.allowEmptyNames
        CGA_AppDelegate.centralManager?.startScanning(duplicateFilteringIsOn: !prefs.continuouslyUpdatePeripherals)
        deviceTableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     Makes sure that we have all devices disconnected.
     */
    private func _clearAllConnections() {
        CGA_AppDelegate.centralManager?.forEach { $0.disconnect() }
    }
    
    /* ################################################################## */
    /**
     Stops scanning for Peripherals. If already stopped, nothing happens.
     */
    private func _stopScanning() {
        CGA_AppDelegate.centralManager?.stopScanning()
    }
    
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    private func _setUpAccessibility() {
        scanningButton?.accessibilityLabel = ("SLUG-ACC-SCANNING-BUTTON-O" + (isScanning ? "N" : "FF")).localizedVariant
        noBTImage?.accessibilityLabel = "SLUG-ACC-NO-BT-IMAGE".localizedVariant
        editButton?.accessibilityLabel = ("SLUG-ACC-EDIT-BUTTON-" + ((deviceTableView?.isEditing ?? false) ? "DONE" : "EDIT")).localizedVariant
        deviceTableView?.accessibilityLabel = "SLUG-ACC-DEVICELIST-TABLE".localizedVariant
        settingsButton?.accessibilityLabel = "SLUG-ACC-SETTINGS-BUTTON".localizedVariant
        infoButton?.accessibilityLabel = "SLUG-ACC-INFO-BUTTON".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_ScannerViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: CGA_ScannerViewController {
    /* ################################################################## */
    /**
     This is called from presented view controllers, and will restart scanning, if we were scanning before. If not, nothing happens.
     */
    func restartScanningIfNecessary() {
        if wasScanning {
            _startScanning()
            deviceTableView?.reloadData()
        }
        
        scanningButton?.isEnabled = true
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the table is displayed if BT is available, or the "No BT" image is shown, if it is not.
     */
    func updateUI() {
        let isBTAvailable = CGA_AppDelegate.centralManager?.isBTAvailable ?? false
        if !isBTAvailable { // Make sure that we are at the initial view, if BT is not available.
            _resetToRoot()
        }
        
        noBTImage?.isHidden = isBTAvailable
        deviceTableView?.isHidden = !isBTAvailable
        scanningButton?.isHidden = !isBTAvailable
        editButtonStackView?.isHidden = !isBTAvailable
        editButton?.isHidden = isScanning
        
        editButton.setTitle((deviceTableView.isEditing ? "SLUG-DONE" : "SLUG-EDIT").localizedVariant, for: .normal)
        
        scanningButton?.isEnabled = true
        
        var title: String = " " + "SLUG-NOT-SCANNING".localizedVariant + " "
        var color: UIColor = .red
        
        if  isScanning {
            title = " " + "SLUG-SCANNING".localizedVariant + " "
            color = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1.0)
        }
        
        scanningButton?.setTitle(title, for: .normal)
        scanningButton?.titleLabel?.text = title    // We do this to prevent that "flash" of old text.
        scanningButton?.backgroundColor = color
        
        _setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_BlueThoth_Delegate Conformance -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: CGA_BlueThoth_Delegate {
    /* ################################################################## */
    /**
     Called to report an error.
     
     - parameter inError: The error being reported.
     - parameter from: The manager wrapper view that is calling this.
     */
    func handleError(_ inError: CGA_Errors, from inCentralManager: RVS_BlueThoth) {
        _resetToRoot()
        var mappableLayers = inError.layeredDescription
        
        if  1 < mappableLayers.count,
            let lastError = mappableLayers.popLast() {
            mappableLayers.insert(lastError, at: 1)
        }
        
        CGA_AppDelegate.displayAlert("SLUG-ERROR".localizedVariant, message: mappableLayers.map { $0.localizedVariant }.joined(separator: "\n"))
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that the state of the Central manager just became "powered on."
     
     - parameter inCentralManager: The central manager that is calling this.
     */
    func centralManagerPoweredOn(_ inCentralManager: RVS_BlueThoth) {
        _startScanning()
    }

    /* ################################################################## */
    /**
     Called to tell this controller to recalculate its table.
     
     - parameter inCentralManager: The manager wrapper view that is calling this.
     */
    func updateFrom(_ inCentralManager: RVS_BlueThoth) {
        updateUI()
        deviceTableView?.reloadData()
    }
    /* ################################################################## */
    /**
     Called to tell the instance that a Peripheral device has been connected.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter didConnectThisDevice: The device instance that was connected.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, didConnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        _currentDeviceScreen?.updateUI()
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a peripheral device is about to be disconnected.
     We use this to reset the view stack to the initial (Peripheral List) screen.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter willDisconnectThisDevice: The device instance that will be removed after this call.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, willDisconnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        _resetToRoot()
    }
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Peripheral device has had some change.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter deviceInfoChanged: The device instance that was connected.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, deviceInfoChanged inDevice: CGA_Bluetooth_Peripheral) {
        if let currentScreen = _currentDeviceScreen as? CGA_InitialViewController {
            currentScreen.deviceTableView.reloadData()
        }
    }

    /* ################################################################## */
    /**
     Called to tell the instance that a Service changed.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter changedService: The Service instance that contained the changed Characteristic.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, changedService inService: CGA_Bluetooth_Service) {
        if let currentScreen = _currentDeviceScreen as? CGA_ServiceViewController {
            currentScreen.updateUI()
        }
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a Characteristic changed its value.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter changedCharacteristic: The Characteristic that was changed.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, changedCharacteristic inCharacteristic: CGA_Bluetooth_Characteristic) {
        if let currentScreen = _currentDeviceScreen as? CGA_ServiceViewController {
            currentScreen.updateUI()
        } else if let currentScreen = _currentDeviceScreen as? CGA_CharacteristicViewController {
            currentScreen.updateUI()
        }
    }

    /* ################################################################## */
    /**
     Called to tell the instance that a Descriptor changed.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter characteristic: The Characteristic that contains the Descriptor that was changed.
     - parameter changedDescriptor: The Descriptor that was changed.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, characteristic inCharacteristic: CGA_Bluetooth_Characteristic, changedDescriptor inDescriptor: CGA_Bluetooth_Descriptor) {
        if let currentScreen = _currentDeviceScreen as? CGA_CharacteristicViewController {
            currentScreen.updateUI()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     This returns the number of available sections.
     
     There will be 2 sections: Classic, and BLE.
     
     - parameter in: The table view that is asking for the section count.
     */
    func numberOfSections(in inTableView: UITableView) -> Int { _SectionIndexes.numSections.rawValue }
    
    /* ################################################################## */
    /**
     This returns the height of the requested section header.
     
     - parameter inTableView: The table view that is asking for the header (ignored).
     - parameter heightForHeaderInSection: The 0-based section index being queried (ignored).
     - returns: The height, in display units, of the header for the section.
     */
    func tableView(_ inTableView: UITableView, heightForHeaderInSection inSection: Int) -> CGFloat { Self._sectionHeaderHeightInDisplayUnits }
    
    /* ################################################################## */
    /**
     Returns a section header.
     
     - parameter inTableView: The table view that is asking for the header.
     - parameter viewForHeaderInSection: The 0-based section index being queried.
     - returns: The header for the section, as a view (a label).
     */
    func tableView(_ inTableView: UITableView, viewForHeaderInSection inSection: Int) -> UIView? {
        guard 1 < _SectionIndexes.numSections.rawValue else { return nil }
        
        let ret = UILabel()
        
        ret.text = ("SLUG-SECTION-HEADER-" + (_SectionIndexes.ble.rawValue == inSection ? "BLE" : "CLASSIC")).localizedVariant
        ret.textColor = .blue
        ret.textAlignment = .center
        ret.backgroundColor = .white
        ret.font = .boldSystemFont(ofSize: Self._sectionHeaderHeightInDisplayUnits)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter numberOfRowsInSection: The 0-based section index being queried.
     - returns: The number of rows in the given section.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        guard  let centralManager = CGA_AppDelegate.centralManager,
                _SectionIndexes.ble.rawValue == inSection,
                !centralManager.stagedBLEPeripherals.isEmpty
        else { return 0 }
       
        return centralManager.stagedBLEPeripherals.count
    }
    
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter heightForRowAt: The index of the row.
     - returns: The height of the row, in display units.
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        guard  let centralManager = CGA_AppDelegate.centralManager,
            (0..<centralManager.stagedBLEPeripherals.count).contains(inIndexPath.row)
        else { return 0.0 }
        
        return (Self._labelRowHeightInDisplayUnits) + (CGFloat(CGA_AppDelegate.createAdvertimentStringsFor(inIndexPath.row).count) * Self._labelRowHeightInDisplayUnits)
    }
    
    /* ################################################################## */
    /**
     This returns a view, with the data for the given row and section.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter cellForRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        /* ################################################################## */
        /**
         This allows us to easily add a new subview to a view, and keep it tied to the one above.
         
         - parameter inSubView: The view we are adding.
         - parameter to: The view we are embedding it in.
         - parameter under: The bottom constraint of the view just above this one.
         - returns: The bottom anchor of the embedded view (to be used as "under" in the next iteration).
         */
        func _addContainedSubView(_ inSubView: UIView, to inToView: UIView, under inUnderAnchor: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
            inToView.addSubview(inSubView)
            
            inSubView.translatesAutoresizingMaskIntoConstraints = false
            
            inSubView.topAnchor.constraint(equalTo: inUnderAnchor, constant: 0).isActive = true
            inSubView.leadingAnchor.constraint(equalTo: inToView.leadingAnchor, constant: 0).isActive = true
            inSubView.trailingAnchor.constraint(equalTo: inToView.trailingAnchor, constant: 0).isActive = true
            
            return inSubView.bottomAnchor
        }

        let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self._deviceRowReuseID, for: inIndexPath)
        
        // We populate the cell dynamically, creating new labels for each of the advertising data rows.
        if  let tableCell = tableCell as? CGA_InitialViewController_TableRow,
            let centralManager = CGA_AppDelegate.centralManager,
            (0..<centralManager.stagedBLEPeripherals.count).contains(inIndexPath.row) {
            let fontColor = UIColor(white: 1.0, alpha: centralManager.stagedBLEPeripherals[inIndexPath.row].canConnect ? 1.0 : prefs.textColorForUnselectableCells)
            tableCell.nameLabel?.textColor = fontColor
            tableCell.rssiLabel?.textColor = fontColor
            tableCell.nameLabel?.text = centralManager.stagedBLEPeripherals[inIndexPath.row].name
            tableCell.rssiLabel?.text = String(format: "(%d dBm)", centralManager.stagedBLEPeripherals[inIndexPath.row].rssi)
            let advertisingData = CGA_AppDelegate.createAdvertimentStringsFor(inIndexPath.row)
            if  let containerView = tableCell.advertisingDataView {
                containerView.subviews.forEach { $0.removeFromSuperview() }
                var topAnchor: NSLayoutYAxisAnchor = containerView.topAnchor

                // Each row of advertising data is turned into a new label, which is added to the container view; just under the previous label.
                advertisingData.forEach {
                    if !$0.isEmpty {
                        let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: containerView.bounds.size.width, height: Self._labelRowHeightInDisplayUnits))
                        let newLabel = UILabel(frame: bounds)
                        newLabel.text = $0
                        newLabel.adjustsFontSizeToFitWidth = true
                        newLabel.minimumScaleFactor = 0.75
                        newLabel.font = .systemFont(ofSize: Self._labelRowHeightInDisplayUnits * 0.75)
                        newLabel.textColor = fontColor
                        topAnchor = _addContainedSubView(newLabel, to: containerView, under: topAnchor)
                    }
                }
            
                // Tie the last one off to the bottom of the view.
                topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
            }
            
            // Set up the accessibility stuff.
            if !centralManager.stagedBLEPeripherals[inIndexPath.row].advertisementData.localName.isEmpty {
                tableCell.nameLabel?.accessibilityLabel = String(format: "SLUG-ACC-DEVICELIST-TABLE-NAME-ADVERTISED-FORMAT".localizedVariant, centralManager.stagedBLEPeripherals[inIndexPath.row].advertisementData.localName)
            } else if !centralManager.stagedBLEPeripherals[inIndexPath.row].name.isEmpty {
                tableCell.nameLabel?.accessibilityLabel = String(format: "SLUG-ACC-DEVICELIST-TABLE-NAME-SIMPLE-FORMAT".localizedVariant, centralManager.stagedBLEPeripherals[inIndexPath.row].name)
            } else {
                tableCell.nameLabel?.accessibilityLabel = "SLUG-ACC-DEVICELIST-TABLE-NAME-NONE".localizedVariant
            }
            tableCell.advertisingDataView?.accessibilityLabel = "SLUG-ACC-DEVICELIST-TABLE-ADVERTISING-DATA".localizedVariant
            tableCell.rssiLabel?.accessibilityLabel = String(format: "SLUG-ACC-DEVICELIST-TABLE-RSSI-FORMAT".localizedVariant, centralManager.stagedBLEPeripherals[inIndexPath.row].rssi)
            // This sets the order of the elements in voiceover. We want the RSSI label to come before the advertising data.
            tableCell.accessibilityElements = [tableCell.nameLabel!, tableCell.rssiLabel!, tableCell.advertisingDataView!]
        }
        
        // This ensures that we maintain a consistent background color upon selection.
        tableCell.selectedBackgroundView = UIView()
        tableCell.selectedBackgroundView?.backgroundColor = UIColor(cgColor: prefs.tableSelectionBackgroundColor)

        return tableCell
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called to test whether or not to allow a row to be selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter willSelectRowAt: The index path (section, row) for the cell.
     - returns: The IndexPath of the cell, if approved, or nil, if not.
     */
    func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? {
        // No double-dips.
        if  let indexPaths = inTableView.indexPathsForSelectedRows,
            indexPaths.contains(inIndexPath) {
            return nil
        }
        
        if let centralManager = CGA_AppDelegate.centralManager,
            centralManager.stagedBLEPeripherals[inIndexPath.row].canConnect {
            return inIndexPath
        } else {
            return nil
        }
    }
    
    /* ################################################################## */
    /**
     Called to test whether or not to allow a row to be higlighted.
     
     This prevents the unselectable row from "flashing" when someone touches it.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter shouldHighlightRowAt: The index path (section, row) for the cell.
     - returns: The IndexPath of the cell, if approved, or nil, if not.
     */
    func tableView(_ inTableView: UITableView, shouldHighlightRowAt inIndexPath: IndexPath) -> Bool { nil != tableView(inTableView, willSelectRowAt: inIndexPath) }
    
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter didSelectRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        guard let centralManager = CGA_AppDelegate.centralManager  else { return }
      
        performSegue(withIdentifier: Self._deviceDetailSegueID, sender: centralManager.stagedBLEPeripherals[inIndexPath.row])
    }
    
    /* ################################################################## */
    /**
     Indicate that a row can be edited (for left-swipe delete).
     
     - parameter: Ignored
     - parameter canEditRowAt: Ignored
     
     - returns: true, but only if we are not scanning. If we are scanning, we can't edit table rows.
     */
    func tableView(_: UITableView, canEditRowAt: IndexPath) -> Bool { !isScanning }
    
    /* ################################################################## */
    /**
     Called to do a delete action.
     
     - parameter inTableView: The table view being edited
     - parameter commit: The action to perform.
     - parameter forRowAt: The indexpath of the row to be deleted.
     */
    func tableView(_ inTableView: UITableView, commit inEditingStyle: UITableViewCell.EditingStyle, forRowAt inIndexPath: IndexPath) {
        if  inEditingStyle == UITableViewCell.EditingStyle.delete,
            let centralManager = CGA_AppDelegate.centralManager {
            centralManager.stagedBLEPeripherals[inIndexPath.row].ignore()
            inTableView.reloadData()
        }
    }
}
