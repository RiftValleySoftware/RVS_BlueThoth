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
// MARK: - Main Discovery View Controller -
/* ###################################################################################################################################### */
/**
 */
class CGA_InitialViewController: CGA_BaseViewController {
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
        scanningSegmentedControl?.selectedSegmentIndex = (centralManager?.isScanning ?? false) ? 0 : 1
        setUpAccessibility()
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
        _startScanning()
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
        _resetToRoot()
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
        if let currentScreen = _currentDeviceScreen as? CGA_InitialViewController {
            currentScreen.updateUI()
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
        #if DEBUG
            print("Service Update Received")
        #endif
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
