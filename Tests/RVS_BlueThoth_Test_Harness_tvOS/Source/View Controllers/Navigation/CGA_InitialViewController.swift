/*
© Copyright 2020-2022, The Great Rift Valley Software Company

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
import RVS_BlueThoth

/* ###################################################################################################################################### */
// MARK: - Main Discovery View Controller -
/* ###################################################################################################################################### */
/**
 */
class CGA_InitialViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     Used to generate table rows.
     */
    static let discoveryTableCellReuseID = "discovery-table-cell"
    
    /* ################################################################## */
    /**
     The segue ID of the "Show Discovery Details" screen.
     */
    static let showDetailsSegueID = "show-discovery-details"
    
    /* ################################################################## */
    /**
     The segue ID of the "Show Settings" screen.
     */
    static let showSettingsSegueID = "show-settings"
    
    /* ################################################################## */
    /**
     This is a simple accessor for the app Central Manager Instance.
     */
    var centralManager: RVS_BlueThoth! { CGA_AppDelegate.centralManager }

    /* ################################################################## */
    /**
     Returns the pushed device details screen. Nil, if none.
     */
    private var _currentDeviceScreen: CGA_UpdatableScreenViewController! { navigationController?.topViewController as? CGA_UpdatableScreenViewController }

    /* ################################################################## */
    /**
     The image that is displayed if bluetooth is not available.
     */
    @IBOutlet weak var noBTImage: UIImageView!

    /* ################################################################## */
    /**
     This segmented control manages the scanning state of the app.
     */
    @IBOutlet weak var scanningSegmentedControl: UISegmentedControl!

    /* ################################################################## */
    /**
     This table lists all discovered devices.
     */
    @IBOutlet weak var discoveryTableView: UITableView!
    
    /* ################################################################## */
    /**
     Returns true, if the Central Manager is currently scanning.
     */
    var isScanning: Bool { centralManager?.isScanning ?? false }

    /* ################################################################## */
    /**
     Used as a semaphore (yuck) to indicate that the Central was (or was not) scanning before the view disappeared.
     It is also used for editing the table, to prevent it from aborting deletes.
     */
    var wasScanning: Bool = false
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
    }
    
    /* ################################################################## */
    /**
     Starts scanning for Peripherals. If already scanning, nothing happens.
     */
    private func _startScanning() {
        let scanCriteria = prefs.scanCriteria
        centralManager?.startOver()
        centralManager?.scanCriteria = scanCriteria
        centralManager?.minimumRSSILevelIndBm = prefs.minimumRSSILevel
        centralManager?.discoverOnlyConnectablePeripherals = prefs.discoverOnlyConnectableDevices
        centralManager?.allowEmptyNames = prefs.allowEmptyNames
        centralManager?.startScanning(duplicateFilteringIsOn: !prefs.continuouslyUpdatePeripherals)
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
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
        noBTImage?.accessibilityLabel = "SLUG-ACC-NO-BT-IMAGE".localizedVariant
        scanningSegmentedControl?.accessibilityLabel = ("SLUG-ACC-SCANNING-BUTTON-O" + ((centralManager?.isScanning ?? false) ? "N" : "FF")).localizedVariant
        discoveryTableView?.accessibilityLabel = "SLUG-ACC-DEVICELIST-TABLE-MAC".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     Called when the scanning control changes.
     
     - parameter inSegmentedControl: The control that changed.
     */
    @IBAction func scanningControlChanged(_ inSegmentedControl: UISegmentedControl) {
        if 0 == inSegmentedControl.selectedSegmentIndex {
            _startScanning()
        } else {
            _stopScanning()
            if 2 == inSegmentedControl.selectedSegmentIndex {
                performSegue(withIdentifier: Self.showSettingsSegueID, sender: nil)
            }
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
        CGA_AppDelegate.centralManager = RVS_BlueThoth(delegate: self)
        scanningSegmentedControl?.setTitle(scanningSegmentedControl?.titleForSegment(at: 0)?.localizedVariant, forSegmentAt: 0)
        scanningSegmentedControl?.setTitle(scanningSegmentedControl?.titleForSegment(at: 1)?.localizedVariant, forSegmentAt: 1)
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use this to hide the navBar.
     
     - parameter inAnimated: True, if the appearance is animated (we ignore this).
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        // We always make sure that nothing is connected.
        CGA_AppDelegate.centralManager?.forEach { $0.discoveryData?.disconnect() }
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view disappears.
     
     - parameter inAnimated: True, if the appearance is animated (we ignore this).
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        wasScanning = isScanning
        CGA_AppDelegate.centralManager?.stopScanning()
    }
    
    /* ################################################################## */
    /**
     Called just before the discovery details screen is pushed.
     
     - parameter for: The segue that is being executed.
     - parameter sender: The discovery information.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        if  let destination = inSegue.destination as? CGA_DiscoveryDetailsViewController,
            let discoveryData = inSender as? RVS_BlueThoth.DiscoveryData {
            destination.discoveryData = discoveryData
        }
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
        noBTImage?.isHidden = (centralManager?.isBTAvailable ?? true)
        scanningSegmentedControl?.isHidden = !(centralManager?.isBTAvailable ?? false)
        discoveryTableView?.isHidden = !(centralManager?.isBTAvailable ?? false)
        scanningSegmentedControl?.selectedSegmentIndex = (centralManager?.isScanning ?? false) ? 0 : 1
        discoveryTableView?.reloadData()
        discoveryTableView?.isUserInteractionEnabled = !(centralManager?.isScanning ?? false)
        setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     Called to provide the data to display in the indicated table cell.
     
     - parameters:
        - inTableView: The Table View that is asking for this View.
        - cellForRowAt: The IndexPath of the cell.
     
     - returns: A new view, set up for the indicated cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if  let ret = inTableView.dequeueReusableCell(withIdentifier: Self.discoveryTableCellReuseID),
            let centralManager = centralManager {
            let peripheralDiscoveryInfo = centralManager.stagedBLEPeripherals[inIndexPath.row]
            let powerString = " (" + String(format: "SLUG-RSSI-LEVEL-FORMAT".localizedVariant, peripheralDiscoveryInfo.rssi) + ")"
            ret.textLabel?.text = (peripheralDiscoveryInfo.preferredName.isEmpty ? "SLUG-NO-DEVICE-NAME".localizedVariant : peripheralDiscoveryInfo.preferredName) + powerString
            ret.textLabel?.textColor = centralManager.isScanning ? UIColor(white: 1.0, alpha: 0.5) : .white
            return ret
        }
        
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     - returns: The number of rows in the table.
     */
    func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int { centralManager?.stagedBLEPeripherals.count ?? 0 }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter: ignored
     - parameter didSelectRowAt: The IndexPath of the selected row.
     */
    func tableView(_: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        centralManager?.stopScanning()
        performSegue(withIdentifier: Self.showDetailsSegueID, sender: centralManager?.stagedBLEPeripherals[inIndexPath.row])
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
        
        CGA_AppDelegate.displayAlert(header: "SLUG-ERROR".localizedVariant, message: mappableLayers.map { $0.localizedVariant }.joined(separator: "\n"))
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that the state of the Central manager just became "powered on."
     
     - parameter inCentralManager: The central manager that is calling this.
     */
    func centralManagerPoweredOn(_ inCentralManager: RVS_BlueThoth) {
        updateUI()
    }

    /* ################################################################## */
    /**
     Called to tell this controller to recalculate its table.
     
     - parameter inCentralManager: The manager wrapper view that is calling this.
     */
    func updateFrom(_ inCentralManager: RVS_BlueThoth) {
        #if DEBUG
            print("General Update")
        #endif
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a Peripheral device has been connected.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter didConnectThisDevice: The device instance that was connected.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, didConnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Connected Device")
        #endif
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
        #if DEBUG
            print("Disconnecting Device")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance that a Peripheral device has had some change.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter deviceInfoChanged: The device instance that was connected.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, deviceInfoChanged inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Peripheral Update")
        #endif
        _currentDeviceScreen?.updateUI()
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a Service changed.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter changedService: The Service instance that contained the changed Characteristic.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, changedService inService: CGA_Bluetooth_Service) {
        #if DEBUG
            print("Service Update Received")
        #endif
        _currentDeviceScreen?.updateUI()
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a Characteristic changed its notification state.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter changedCharacteristicNotificationState: The Characteristic that was changed.
     */
    func centralManager(_ inCentral: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, changedCharacteristicNotificationState inCharacteristic: CGA_Bluetooth_Characteristic) {
        #if DEBUG
            print("Characteristic Notification State Changed to \(inCharacteristic.isNotifying ? "ON" : "OFF")")
        #endif
        inCharacteristic.forEach { $0.readValue() }
        _currentDeviceScreen?.updateUI()
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
        #if DEBUG
            print("Characteristic Update Received")
            if  let stringValue = inCharacteristic.stringValue {
                print("\tString Value: \"\(stringValue)\"")
            }
        #endif
        if  let currentScreen = _currentDeviceScreen as? CGA_ServiceContainer,
            currentScreen.serviceInstance?.id == inService.id {
            currentScreen.updateUI()
        } else if   let currentScreen = _currentDeviceScreen as? CGA_WriteableElementContainer,
                    currentScreen.writeableElementInstance?.id == inCharacteristic.id {
            currentScreen.updateUI()
        } else {
            _currentDeviceScreen?.updateUI()
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
        #if DEBUG
            print("Descriptor Update")
            if  let stringValue = inCharacteristic.stringValue {
                print("\tCharacteristic String Value: \"\(stringValue)\"")
            }
            if  let stringValue = inDescriptor.stringValue {
                print("\tDescriptor String Value: \"\(stringValue)\"")
            }
        #endif
        _currentDeviceScreen?.updateUI()
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance that a Characteristic write with response received its response.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter characteristicWriteComplete: The Characteristic that had its write completed.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inPeripheral: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, characteristicWriteComplete inCharacteristic: CGA_Bluetooth_Characteristic) {
        #if DEBUG
            print("Characteristic: \(inCharacteristic.id) Wrote Its Value")
            if  let stringValue = inCharacteristic.stringValue {
                print("\tCharacteristic String Value: \"\(stringValue)\"")
            }
        #endif
        CGA_AppDelegate.displayAlert(header: "WRITE-RESPONSE".localizedVariant)
    }
}
