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
import CoreBluetooth

/* ###################################################################################################################################### */
/**
 These are all classes, as opposed to structs, because we want them to be referenced, not copied.
 Remember that Bluetooth is a very dynamic, realtime environment. Caches can be extremely problematic. We want caches, but safe ones.
 Also, the Central and Peripheral classes need to derive from NSObject, so they can be delegates.
 */

/* ###################################################################################################################################### */
// MARK: - The Main Protocol for Each Type -
/* ###################################################################################################################################### */
/**
 This protocol is the "base" protocol to which all the exposed types conform.
 */
protocol CGA_Class_Protocol: class {
    /* ################################################################## */
    /**
     REQUIRED: This is used to reference an "owning instance" of this instance.
     */
    var parent: CGA_Class_Protocol? { get }
    
    /* ################################################################## */
    /**
     REQUIRED: This returns a unique UUID String for the instance.
     */
    var id: String { get }

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: Error)
    
    func clear()
}

/* ###################################################################################################################################### */
// MARK: - Protocol Defaults -
/* ###################################################################################################################################### */
extension CGA_Class_Protocol {
    /* ################################################################## */
    /**
     Default simply passes the buck.
     */
    func handleError(_ inError: Error) {
        if let parent = parent {
            parent.handleError(inError)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_Protocol_UpdateCharacteristic Protocol -
/* ###################################################################################################################################### */
/**
 */
protocol CGA_Class_Protocol_UpdateCharacteristic: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This is called to inform an instance that a Characteristic downstream changed.
     
     - parameter characteristic: The Characteristic wrapper instance that changed.
     */
    func updateThisCharacteristic(_ characteristic: CGA_Bluetooth_Characteristic)
}

/* ###################################################################################################################################### */
// MARK: - Protocol Defaults -
/* ###################################################################################################################################### */
extension CGA_Class_Protocol_UpdateCharacteristic {
    /* ################################################################## */
    /**
     Default simply passes the buck.
     */
    func updateThisCharacteristic(_ inCharacteristic: CGA_Bluetooth_Characteristic) {
        if let parent = parent as? CGA_Class_Protocol_UpdateCharacteristic {
            parent.updateThisCharacteristic(inCharacteristic)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - The CGA_Class_Protocol_UpdateDescriptor Protocol -
/* ###################################################################################################################################### */
/**
 */
protocol CGA_Class_Protocol_UpdateDescriptor: CGA_Class_Protocol_UpdateCharacteristic {
    /* ################################################################## */
    /**
     This is called to inform an instance that a Descriptor downstream changed.
     
     - parameter descriptor: The Descriptor wrapper instance that changed.
     */
    func updateThisDescriptor(_ descriptor: CGA_Bluetooth_Descriptor)
}

/* ###################################################################################################################################### */
// MARK: - Protocol Defaults -
/* ###################################################################################################################################### */
extension CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     Default simply passes the buck.
     */
    func updateThisDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor) {
        if let parent = parent as? CGA_Class_Protocol_UpdateDescriptor {
            parent.updateThisDescriptor(inDescriptor)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - The Central Manager Delegate Protocol -
/* ###################################################################################################################################### */
/**
 All delegate callbacks are made in the main thread.
 */
protocol CGA_Bluetooth_CentralManagerDelegate: class {
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: Error, from: CGA_Bluetooth_CentralManager)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to update its data.
               NOTE: There may be no changes, or many changes. What has changed is not specified.
     
     - parameter centralManager: The central manager that is calling this.
     */
    func updateFrom(_ centralManager: CGA_Bluetooth_CentralManager)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that the state of the Central manager just became "powered on."
     
     - parameter centralManager: The central manager that is calling this.
     */
    func centralManagerPoweredOn(_ centralManager: CGA_Bluetooth_CentralManager)

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Peripheral device has been connected.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter didConnectThisDevice: The device instance that was connected.
     */
    func centralManager(_ centralManager: CGA_Bluetooth_CentralManager, didConnectThisDevice: CGA_Bluetooth_Peripheral)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a peripheral device is about to be disconnected.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter willDisconnectThisDevice: The device instance that will be removed after this call.
     */
    func centralManager(_ centralManager: CGA_Bluetooth_CentralManager, willDisconnectThisDevice: CGA_Bluetooth_Peripheral)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Characteristic changed its value.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter changedCharacteristic: The Characteristic that was changed.
     */
    func centralManager(_ centralManager: CGA_Bluetooth_CentralManager, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, changedCharacteristic: CGA_Bluetooth_Characteristic)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance that a Descriptor changed its value.
     
     - parameter centralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter characteristic: The Characteristic that contains the Descriptor that was changed.
     - parameter changedDescriptor: The Descriptor that was changed.
     */
    func centralManager(_ centralManager: CGA_Bluetooth_CentralManager, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, characteristic: CGA_Bluetooth_Characteristic, changedDescriptor: CGA_Bluetooth_Descriptor)
}

/* ###################################################################################################################################### */
// MARK: - The Central Manager Delegate Defaults -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_CentralManagerDelegate {
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func handleError(_: Error, from: CGA_Bluetooth_CentralManager) { }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func updateFrom(_: CGA_Bluetooth_CentralManager) { }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func centralManagerPoweredOn(_: CGA_Bluetooth_CentralManager) { }

    /* ################################################################## */
    /**
     The default does nothing.
     */
    func centralManager(_: CGA_Bluetooth_CentralManager, didConnectThisDevice: CGA_Bluetooth_Peripheral) { }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func centralManager(_: CGA_Bluetooth_CentralManager, willDisconnectThisDevice: CGA_Bluetooth_Peripheral) { }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func centralManager(_ centralManager: CGA_Bluetooth_CentralManager, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, changedCharacteristic: CGA_Bluetooth_Characteristic) { }
    
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func centralManager(_ centralManager: CGA_Bluetooth_CentralManager, device: CGA_Bluetooth_Peripheral, service: CGA_Bluetooth_Service, characteristic: CGA_Bluetooth_Characteristic, changedDescriptor: CGA_Bluetooth_Descriptor) { }
}

/* ###################################################################################################################################### */
// MARK: - The Central Manager -
/* ###################################################################################################################################### */
/**
 This is the main class that is instantiated in order to implement the Bluetooth subsystem.
 */
class CGA_Bluetooth_CentralManager: NSObject, RVS_SequenceProtocol {
    /* ################################################################################################################################## */
    /**
     This is the struct that we use to narrow the search criteria for new instances of the <code>CGA_Bluetooth_CentralManager</code> class.
          
     If you will not be looking for particular Bluetooth instances, then leave the corresponding property nil, or empty.
     
     All members are String, but these will be converted internally into <code>CBUUID</code>s.
     
     These are applied across the board. For example, if you specify a Service, then ALL scans will filter for that Service,
     and if you specify a Characteristic, then ALL Services, for ALL peripherals, will be scanned for that Characteristic.
     */
    struct ScanCriteria {
        /// This is a list of identifier UUIDs for specific Bluetooth devices.
        let peripherals: [String]!
        /// This is a list of UUIDs for Services that will be scanned.
        let services: [String]!
        /// This is a list of UUIDs for specific Characteristics to be discovered within Services.
        let characteristics: [String]!
        
        /* ############################################################## */
        /**
         This returns true, if all of the specifiers are nil or empty.
         */
        var isEmpty: Bool {
            return (nil == peripherals || peripherals.isEmpty)
                && (nil == services || services.isEmpty)
                && (nil == characteristics || characteristics.isEmpty)
        }
    }
    
    /* ################################################################################################################################## */
    /**
     This is a class, as opposed to a struct, because I want to make sure that it is referenced, and not copied.
     */
    class DiscoveryData {
        /* ############################################################## */
        /**
         The Central manager that "owns" this discovered device. This is a weak reference.
         */
        weak var central: CGA_Bluetooth_CentralManager?
        
        /* ############################################################## */
        /**
         This is the peripheral wrapper that is instantiated when the device is connected. It is nil, if the device is not connected. It is a strong reference.
         */
        var peripheralInstance: CGA_Bluetooth_Peripheral?
        
        /* ############################################################## */
        /**
         The actual Peripheral instance. This is a strong reference.
         This will retain the allocation for the Peripheral until after it has been connected and discovery is complete.
         */
        var peripheral: Any
        
        /* ############################################################## */
        /**
         This holds the advertisement data that came with the discovery.
         */
        let advertisementData: [String: Any]
        
        /* ############################################################## */
        /**
         This is the signal strength, at the time of discovery, in dBm.
         */
        let rssi: Int
        
        /* ############################################################## */
        /**
         The assigned Peripheral Name
         */
        var name: String { cbPeripheral?.name ?? "" }

        /* ############################################################## */
        /**
         This is true, if the Peripheral advertisement data indicates the Peripheral can be connected.
         */
        var canConnect: Bool {
            guard !advertisementData.isEmpty else { return false }
            
            return advertisementData.reduce(false) { (current, next) in
                guard   !current,
                        CBAdvertisementDataIsConnectable == next.key,
                        let value = next.value as? Bool
                else { return current }
                
                return value
            }
        }
        
        /* ############################################################## */
        /**
         This is the "Local Name," from the advertisement data.
         */
        var localName: String {
            guard !advertisementData.isEmpty else { return "" }
            
            return advertisementData.reduce("") { (current, next) in
                guard   current.isEmpty,
                        CBAdvertisementDataLocalNameKey == next.key,
                        let value = next.value as? String
                else { return current }
                
                return value
            }
        }
        
        /* ############################################################## */
        /**
         This is the local name, if available, or the Peripheral name, if the local name is not available.
         */
        var preferredName: String { localName.isEmpty ? name : localName }
        
        /* ############################################################## */
        /**
         The actual Peripheral instance, cast as CBPeripheral.
         */
        var cbPeripheral: CBPeripheral! { peripheral as? CBPeripheral }
        
        /* ############################################################## */
        /**
         Returns the ID UUID as a String.
         */
        var identifier: String { cbPeripheral?.identifier.uuidString ?? "" }
        
        /* ############################################################## */
        /**
         Returns true, if the peripheral is currently connected.
         */
        var isConnected: Bool { .connected == cbPeripheral?.state }
        
        /* ############################################################## */
        /**
         This asks the Central Manager to ignore this device.
         
         - returns: True, if the ignore worked.
         */
        @discardableResult
        func ignore() -> Bool {
            guard   !(central?.ignoredBLEPeripherals.contains(self) ?? false),
                    (central?.stagedBLEPeripherals.contains(self) ?? false)
            else { return false }
            
            central?.ignoredBLEPeripherals.append(self)
            central?.stagedBLEPeripherals.removeThisDevice(self)
            
            return true
        }
        
        /* ############################################################## */
        /**
         This asks the Central Manager to "unignore" this device.
         
         - returns: True, if the unignore worked.
         */
        @discardableResult
        func unignore() -> Bool {
            guard   !(central?.stagedBLEPeripherals.contains(self) ?? false),
                    (central?.ignoredBLEPeripherals.contains(self) ?? false)
            else { return false }
            
            central?.stagedBLEPeripherals.append(self)
            central?.ignoredBLEPeripherals.removeThisDevice(self)
            
            return true
        }
        
        /* ############################################################## */
        /**
         This asks the Central Manager to connect this device.
         
         - returns: True, if the attempt worked (not a guarantee of success, though).
         */
        @discardableResult
        func connect() -> Bool {
            guard   let central = central,
                    !isConnected else { return false }
            
            return central.connect(self)
        }
        
        /* ############################################################## */
        /**
         This asks the Central Manager to disconnect this device.
         
         - returns: True, if the attempt worked (not a guarantee of success, though).
         */
        @discardableResult
        func disconnect() -> Bool {
            guard   let central = central,
                    isConnected else { return false }
            
            return central.disconnect(self)
        }

        /* ############################################################## */
        /**
         Basic Init
         
         - parameters:
            - central: The Central Manager instance that "owns" this instance.
            - peripheral: The CBPeripheral instance associated with this. This will be a strong reference, and will be the "anchor" for this instance.
            - advertisementData: The advertisement data of the discovered Peripheral.
            - rssi: The signal strength, in dBm.
         */
        init(central inCentralManager: CGA_Bluetooth_CentralManager, peripheral inPeripheral: CBPeripheral, advertisementData inAdvertisementData: [String: Any], rssi inRSSI: Int) {
            central = inCentralManager
            peripheral = inPeripheral
            advertisementData = inAdvertisementData
            rssi = inRSSI
        }
    }
    
    /* ################################################################## */
    /**
     This is how many seconds we wait, before declaring a timeout.
     */
    private let _timeoutInSeconds: TimeInterval = 3.0
    
    /* ################################################################## */
    /**
     This is a countdown timer, for use as a timeout trap.
     */
    private var _timer: Timer?
    
    /* ################################################################## */
    /**
     The Central Manager Delegate object.
     */
    weak var delegate: CGA_Bluetooth_CentralManagerDelegate?

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Class_Protocol
     */
    weak var parent: CGA_Class_Protocol?
    
    /* ################################################################## */
    /**
     Returns true, if the current state of the Bluetooth system is powered on.
     */
    var isBTAvailable: Bool { return .poweredOn == cbElementInstance?.state }

    /* ################################################################## */
    /**
     This holds any Services (as Strings) that were specified when scanning started.
     */
    var scanningServices: [String] = []
    
    /* ################################################################## */
    /**
     This holds the instance of CBCentralManager that is used by this instance.
     */
    var cbElementInstance: CBCentralManager!
    
    /* ################################################################## */
    /**
     This will hold BLE Peripherals, as they are being "loaded." Once they are "complete," they go into the main collection, wrapped in our class.
     */
    var stagedBLEPeripherals = [DiscoveryData]()
    
    /* ################################################################## */
    /**
     This will hold BLE Peripherals that have been marked as "ignored."
     */
    var ignoredBLEPeripherals = [DiscoveryData]()
    
    /* ################################################################## */
    /**
     This will contain any required scan criteria.
     */
    var scanCriteria: ScanCriteria!

    /* ################################################################## */
    /**
     We aggregate Peripherals.
     */
    typealias Element = CGA_Bluetooth_Peripheral
    
    /* ################################################################## */
    /**
     This holds our cached Array of Peripheral instances.
     */
    var sequence_contents: Array<Element>
    
    /* ################################################################## */
    /**
     This is the indicator as to whether or not the Bluetooth subsystem is actiively scanning for Peripherals.
     
     This is read-only. Use the <code>startScanning(withServices:)</code> and <code>stopScanning()</code> methods to change the scanning state.
     */
    var isScanning: Bool {
        guard let centralManager = cbElementInstance else {
            #if DEBUG
                print("No Central Manager Instance.")
            #endif
            return false
        }
       
        return centralManager.isScanning
    }
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache. It should be empty.
     */
    required init(sequence_contents inSequenceContents: [Element]) {
        sequence_contents = inSequenceContents
        super.init()    // Since we derive from NSObject, we must call the super init()
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Instance Methods -
/* ###################################################################################################################################### */
/**
 These methods ensure that the delegate calls are made in the main thread.
 */
extension CGA_Bluetooth_CentralManager {
    /* ################################################################## */
    /**
     Called to report an error.
     
     - parameter inError: The error being reported.
     */
    private func _reportError(_ inError: Error) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Reporting \(inError.localizedDescription) as an error.")
            #endif
            self.delegate?.handleError(inError, from: self)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to send the "Update Thyself" message to the delegate.
     */
    private func _updateDelegatePoweredOn() {
        DispatchQueue.main.async {
            #if DEBUG
                print("Telling the delegate that we just powered on.")
            #endif
            self.delegate?.centralManagerPoweredOn(self)
        }
    }

    /* ################################################################## */
    /**
     This is called to send the "Update Thyself" message to the delegate.
     */
    private func _updateDelegate() {
        DispatchQueue.main.async {
            #if DEBUG
                print("Asking delegate to recalculate.")
            #endif
            self.delegate?.updateFrom(self)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to send a new peripheral message to the delegate.
     */
    private func _sendConnectedPeripheral(_ inPeripheral: CGA_Bluetooth_Peripheral) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Sending a connected Peripheral message to the delegate.")
            #endif
            self.delegate?.centralManager(self, didConnectThisDevice: inPeripheral)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to send a disconnecting peripheral message to the delegate.
     */
    private func _sendPeripheralDisconnect(_ inPeripheral: CGA_Bluetooth_Peripheral) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Sending a Peripheral will disconnect message to the delegate.")
            #endif
            self.delegate?.centralManager(self, willDisconnectThisDevice: inPeripheral)
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _startTimeout() {
        #if DEBUG
            print("Starting Timeout.")
        #endif
        _timer = Timer.scheduledTimer(withTimeInterval: _timeoutInSeconds, repeats: false, block: timeout(_:))
    }
    
    /* ################################################################## */
    /**
     */
    private func _cancelTimeout() {
        #if DEBUG
            if let fireDate = _timer?.fireDate {
                print("Ending Timeout after \(_timeoutInSeconds - fireDate.timeIntervalSinceNow) Seconds.")
            } else {
                print("No timer.")
            }
        #endif
        _timer?.invalidate()
        _timer = nil
    }
}

/* ###################################################################################################################################### */
// MARK: - Internal Instance Methods -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_CentralManager {
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     Convenience init. This allows "no parameter" inits, and ones that only have the queue and/or the delegate.
     This will call the delegate's updateFrom(_:) method, upon starting.
     
     - parameter delegate: The delegate instance.
     - parameter scanCriteria: If there are particular scan criteria to be applied to the discovery process, they are supplied here. If left alone, it will be nil, and all entities will be searched.
     - parameter queue: The queue to be used for this instance. If not specified, the main thread is used.
     */
    convenience init(delegate inDelegate: CGA_Bluetooth_CentralManagerDelegate! = nil, scanCriteria inScanCriteria: ScanCriteria! = nil, queue inQueue: DispatchQueue? = nil) {
        self.init(sequence_contents: [])
        delegate = inDelegate
        scanCriteria = inScanCriteria
        cbElementInstance = CBCentralManager(delegate: self, queue: inQueue)
        _updateDelegate()
    }
    
    /* ################################################################## */
    /**
     Asks the Central Manager to start scanning for Peripherals.
     - parameter withServices: An Array of Strings, with the UUID strings. This is optional, and can be left out, in which case all services will be scanned.
     - returns: True, if the scan attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    func startScanning(withServices inWithServices: [String]? = nil) -> Bool {
        guard let cbCentral = cbElementInstance else { return false }
        
        #if DEBUG
            print("Asking Central Manager to Start Scanning.")
            if  let services = inWithServices,
                !services.isEmpty {
                print("\tWith these Services: \(String(describing: services))")
            }
        #endif
        
        // Take off and nuke the entire site from orbit.
        // It's the only way to be sure.
        if cbCentral.isScanning {
            cbCentral.stopScan()
        }
        
        var services: [CBUUID]!
        
        scanningServices = []
        
        // We can always override any previously supplied Service scans.
        if  let inServices = inWithServices,
            !inServices.isEmpty {
            scanningServices = inServices   // Save this, if we need to interrupt scanning.
            services = inServices.compactMap { CBUUID(string: $0) }
        } else if   let services = scanCriteria?.services,
                    !services.isEmpty {
            scanningServices = services
        }
        
        cbCentral.scanForPeripherals(withServices: services, options: nil)
        
        _updateDelegate()

        return true
    }
    
    /* ################################################################## */
    /**
     Asks the Central Manager to start scanning for Peripherals, but reuse any saved filters (as opposed to supplying them).
     - returns: True, if the scan attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    func restartScanning() -> Bool {
        #if DEBUG
            print("Asking Central Manager to Restart Scanning.")
        #endif
        return startScanning(withServices: scanningServices)
    }
    
    /* ################################################################## */
    /**
     Asks the Central Manager to stop scanning for Peripherals.
     - returns: True, if the attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    func stopScanning() -> Bool {
        guard   let cbCentral = cbElementInstance,
                cbCentral.isScanning
        else { return false }
        
        #if DEBUG
            print("Asking Central Manager to Stop Scanning.")
        #endif

        cbCentral.stopScan()
        
        _updateDelegate()

        return true
    }

    /* ################################################################## */
    /**
     This eliminates all of the stored results, and asks the Bluetooth subsystem to start over from scratch.
     */
    func startOver() {
        #if DEBUG
            print("Starting Over From Scratch.")
        #endif
        let wasScanning = isScanning
        stopScanning()
        clear()
        if wasScanning {
            restartScanning()
        }
    }
    
    /* ################################################################## */
    /**
     - returns true, if the given CBPeripheral is in either of our staging lists.
     */
    func iGotThis(_ inPeripheral: CBPeripheral) -> Bool { stagedBLEPeripherals.contains(inPeripheral) || ignoredBLEPeripherals.contains(inPeripheral) }

    /* ################################################################## */
    /**
     Called to initiate a connection (and discovery process) with the peripheral.
     
     - parameter inPeripheral: The Peripheral (CB) to connect, as the opaque DiscoveryData type.
     - returns: True, if the connection attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    func connect(_ inPeripheral: DiscoveryData?) -> Bool {
        guard   let peripheral = inPeripheral?.cbPeripheral,
                let cbCentral = cbElementInstance,
                stagedBLEPeripherals.contains(peripheral)
        else { return false }
        #if DEBUG
            print("Connecting \(String(describing: peripheral.name)).")
        #endif
        _startTimeout()
        cbCentral.connect(peripheral, options: nil)
        
        return true
    }
    
    /* ################################################################## */
    /**
     Called to terminate a connection with the peripheral.
     
     - parameter inPeripheral: The Peripheral (CB) to connect.
     - returns: True, if the disconnection attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    func disconnect(_ inPeripheral: DiscoveryData) -> Bool {
        _cancelTimeout()
        guard   let cbCentral = cbElementInstance,
                let cbPeripheral = inPeripheral.cbPeripheral,
                sequence_contents.contains(cbPeripheral)
        else { return false }
        #if DEBUG
            print("Disconnecting \(inPeripheral.preferredName).")
        #endif
        cbCentral.cancelPeripheralConnection(cbPeripheral)
        
        return true
    }
    
    /* ################################################################## */
    /**
     Called to add a Peripheral to our "keeper" Array.
     
     - parameter inPeripheral: The Peripheral to add.
     */
    func addPeripheral(_ inPeripheral: CGA_Bluetooth_Peripheral) {
        _cancelTimeout()
        #if DEBUG
            print("Adding \(inPeripheral.discoveryData.preferredName).")
        #endif
        inPeripheral.discoveryData.peripheralInstance = inPeripheral
        sequence_contents.append(inPeripheral)
        _sendConnectedPeripheral(inPeripheral)
    }
    
    /* ################################################################## */
    /**
     Called to remove a Peripheral from our main Array.
     
     - parameter inPeripheral: The Peripheral to remove.
     */
    func removePeripheral(_ inPeripheral: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Removing \(inPeripheral.discoveryData.preferredName).")
        #endif
        _sendPeripheralDisconnect(inPeripheral)
        sequence_contents.removeThisDevice(inPeripheral.discoveryData.cbPeripheral)
    }
    
    /* ################################################################## */
    /**
     */
    @objc func timeout(_ inTimer: Timer) {
        #if DEBUG
            print("ERROR! Timeout.")
        #endif
        _cancelTimeout()
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_CentralManager: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This class is the "endpoint" of all errors, so it passes the error back to the delegate.
     */
    func handleError(_ inError: Error) {
        _reportError(inError)
    }
    
    /* ################################################################## */
    /**
     The Central Manager does not have a UUID.
     */
    var id: String { "" }
    
    /* ################################################################## */
    /**
     This is called to inform an instance that a Characteristic downstream changed.
     
     - parameter inCharacteristic: The Characteristic wrapper instance that changed.
     */
    func updateThisCharacteristic(_ inCharacteristic: CGA_Bluetooth_Characteristic) {
    }

    /* ################################################################## */
    /**
     This is called to inform an instance that a Descriptor downstream changed.
     
     - parameter inDescriptor: The Descriptor wrapper instance that changed.
     */
    func updateThisDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor) {
    }
    
    /* ################################################################## */
    /**
     This eliminates all of the stored and staged results.
     */
    func clear() {
        #if DEBUG
            print("Clearing the decks.")
        #endif
        
        stagedBLEPeripherals = []
        ignoredBLEPeripherals = []
        sequence_contents = []
        _updateDelegate()
    }
}

/* ###################################################################################################################################### */
// MARK: - CBCentralManagerDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_CentralManager: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     This is called when the CentralManager state updates.
     
     - parameter inCentralManager: The CBCentralManager instance that is calling this.
     */
    func centralManagerDidUpdateState(_ inCentralManager: CBCentralManager) {
        #if DEBUG
            print("Central Manager State Changed.")
        #endif
        switch inCentralManager.state {
        case .poweredOn:
            #if DEBUG
                print("\tState is Powered On.")
            #endif
            _updateDelegatePoweredOn()
            
        case .poweredOff:
            #if DEBUG
                print("\tState is Powered Off.")
            #endif
            stopScanning()

        case .resetting:
            #if DEBUG
                print("\tState is Resetting.")
            #endif
            stopScanning()

        case .unauthorized:
            #if DEBUG
                print("\tState is Unauthorized.")
            #endif
            stopScanning()

        case .unknown:
            #if DEBUG
                print("\tState is Unknown.")
            #endif
            stopScanning()

        case .unsupported:
            #if DEBUG
                print("\tState is Unsupported.")
            #endif
            stopScanning()

        default:
            #if DEBUG
                print("\tState is Something Else.")
            #endif
            stopScanning()
        }
        
        _updateDelegate()
    }

    /* ################################################################## */
    /**
     This is called when a BLE device has been discovered.
     
     - parameters:
        - inCentralManager: The CBCentralManager instance that is calling this.
        - didDiscover: The CBPeripheral instance that was discovered.
        - advertisementData: The advertisement data that was provided with the discovery.
        - rssi: The signal strength, in DB.
     */
    func centralManager(_ inCentralManager: CBCentralManager, didDiscover inPeripheral: CBPeripheral, advertisementData inAdvertisementData: [String: Any], rssi inRSSI: NSNumber) {
        guard   let name = inPeripheral.name,
                !name.isEmpty
        else {
            #if DEBUG
                print("Discarding empty-name Peripheral: \(inPeripheral.identifier.uuidString).")
            #endif
            return
        }
        
        // See if we have asked for only particular peripherals.
        if  let peripherals = scanCriteria?.peripherals,
            !peripherals.reduce(false, { (current, next) -> Bool in
                current || (next.uppercased() == inPeripheral.identifier.uuidString.uppercased())
            }) {
            #if DEBUG
                print("Discarding Peripheral not on the guest list: \(inPeripheral.identifier.uuidString).")
            #endif
            return
        } else {
            #if DEBUG
                print("Discovered \(name) (BLE).")
            #endif
            guard   !iGotThis(inPeripheral),
                    !inPeripheral.identifier.uuidString.isEmpty
            else {
                #if DEBUG
                    print("Not Adding \(name) (BLE).")
                    if inPeripheral.identifier.uuidString.isEmpty {
                        print("\tBecause the UUID is empty.")
                    }
                #endif
                return
            }
            
            #if DEBUG
                print("Added \(name) (BLE).")
                print("\tUUID: \(inPeripheral.identifier.uuidString)")
                print("\tAdvertising Info:\n\t\t\(String(describing: inAdvertisementData))\n")
            #endif
            stagedBLEPeripherals.append(DiscoveryData(central: self, peripheral: inPeripheral, advertisementData: inAdvertisementData, rssi: inRSSI.intValue))
            _updateDelegate()
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Bluetooth device has been connected (but no discovery yet).
     
     - parameters:
        - inCentralManager: The CBCentralManager instance that is calling this.
        - didConnect: The CBPeripheral instance that was connected.
     */
    func centralManager(_ inCentralManager: CBCentralManager, didConnect inPeripheral: CBPeripheral) {
        guard   !sequence_contents.contains(inPeripheral),
                let discoveredDevice = stagedBLEPeripherals[inPeripheral]
        else {
            #if DEBUG
                print("\(String(describing: inPeripheral.name)) is already connected!")
            #endif
            
            return
        }
        
        #if DEBUG
            print("Connected \(String(describing: inPeripheral.name)).")
        #endif
        
        let newInstance = CGA_Bluetooth_Peripheral(discoveryData: discoveredDevice)
        discoveredDevice.peripheralInstance = newInstance
    }
    
    /* ################################################################## */
    /**
     This is called when a Bluetooth device has been disconnected.
     
     - parameters:
        - inCentralManager: The CBCentralManager instance that is calling this.
        - didDisconnectPeripheral: The CBPeripheral instance that was connected.
        - error: Any error that occurred. It can (and should) be nil.
     */
    func centralManager(_ inCentralManager: CBCentralManager, didDisconnectPeripheral inPeripheral: CBPeripheral, error inError: Error?) {
        guard let peripheralInstance = sequence_contents[inPeripheral] else {
            #if DEBUG
                print("Cannot find \(String(describing: inPeripheral.name)) in the guest list.")
            #endif
            return
        }
        
        _sendPeripheralDisconnect(peripheralInstance)
        
        guard let peripheralObject = peripheralInstance.discoveryData?.peripheralInstance else {
            #if DEBUG
                print("The Peripheral \(peripheralInstance.discoveryData?.preferredName ?? "ERROR") has a bad instance!")
            #endif
            return
        }
        
        #if DEBUG
            print("Disconnected \(peripheralInstance.discoveryData?.preferredName ?? "ERROR").")
        #endif
        
        peripheralObject.clear()
        peripheralInstance.discoveryData?.peripheralInstance = nil

        removePeripheral(peripheralObject)
    }
    
    /* ################################################################## */
    /**
     This is called when a Bluetooth device connection has failed.
     
     - parameters:
        - inCentralManager: The CBCentralManager instance that is calling this.
        - didFailToConnect: The CBPeripheral instance that was not connected.
        - error: Any error that occurred. It can be nil.
     */
    func centralManager(_ inCentralManager: CBCentralManager, didFailToConnect inPeripheral: CBPeripheral, error inError: Error?) {
        #if DEBUG
            print("Connecting \(String(describing: inPeripheral.name)) Failed.")
            if let error = inError {
                print("\tWith error: \(error.localizedDescription).")
            }
        #endif
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Peripherals Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Peripherals in our staged Arrays, looking for an exact instance.
 */
extension Array where Element == CGA_Bluetooth_CentralManager.DiscoveryData {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Peripheral (as the opaque type).
     
     - parameter inItem: The Peripheral we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: Element) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                if nextItem === inItem {
                    return nextItem
                } else if nextItem.identifier == inItem.identifier {
                    return nextItem
                }
               
                return nil
            }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Peripheral
     
     - parameter inItem: The Peripheral we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBPeripheral) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                if nextItem === inItem {
                    return nextItem
                } else if nextItem.cbPeripheral.identifier == inItem.identifier {
                    return nextItem
                }
               
                return nil
            }
            
            return current
        }
    }

    /* ################################################################## */
    /**
     Removes the element (as the opaque type).
     
     - parameter inItem: The CB element we're looking to remove, as the opaque type.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisDevice(_ inItem: Element) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            if test === inItem {
                success = true
                return true
            } else if test.identifier == inItem.identifier {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element (as the opaque type).
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: Element) -> Bool { return nil != self[inItem] }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBPeripheral) -> Bool { return nil != self[inItem] }
}
