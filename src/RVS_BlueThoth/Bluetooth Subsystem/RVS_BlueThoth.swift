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

import CoreBluetooth

/* ###################################################################################################################################### */
/**
 These are all classes, as opposed to structs, because we want them to be referenced, not copied.
 Also, the Central and Peripheral classes need to derive from NSObject, so they can be delegates.
 */
/* ###################################################################################################################################### */
// MARK: - The Central Manager -
/* ###################################################################################################################################### */
/**
 This is the main class that is instantiated in order to implement the Bluetooth subsystem.
 */
public class RVS_BlueThoth: NSObject, RVS_SequenceProtocol {
    /* ################################################################################################################################## */
    /**
     This is the struct that we use to narrow the search criteria for new instances of the <code>CGA_Bluetooth_CentralManager</code> class.
          
     If you will not be looking for particular Bluetooth instances, then leave the corresponding property nil, or empty.
     
     All members are String, but these will be converted internally into <code>CBUUID</code>s.
     
     These are applied across the board. For example, if you specify a Service, then ALL scans will filter for that Service,
     and if you specify a Characteristic, then ALL Services, for ALL peripherals, will be scanned for that Characteristic.
     */
    public struct ScanCriteria {
        /// This is a list of identifier UUIDs for specific Bluetooth devices.
        public let peripherals: [String]!
        /// This is a list of UUIDs for Services that will be scanned.
        public let services: [String]!
        /// This is a list of UUIDs for specific Characteristics to be discovered within Services.
        public let characteristics: [String]!
        
        /* ############################################################## */
        /**
         This returns true, if all of the specifiers are nil or empty.
         */
        public var isEmpty: Bool { (peripherals?.isEmpty ?? false) && (services?.isEmpty ?? false) && (characteristics?.isEmpty ?? false) }
        
        /* ############################################################## */
        /**
         Standard initializer
         
         - parameters:
            - peripherals: This is a list of identifier UUIDs for specific Bluetooth devices.
            - services: This is a list of UUIDs for Advertised Services that will be scanned.
            - characteristics: This is a list of UUIDs for specific Characteristics to be discovered within Services.
         */
        public  init(peripherals inPeripherals: [String]!, services inServices: [String]!, characteristics inCharacteristics: [String]!) {
            peripherals = inPeripherals
            services = inServices
            characteristics = inCharacteristics
        }
    }
    
    /* ################################################################################################################################## */
    /**
     This struct allows us to apply some data interpretation to the advertisement data.
     */
    public struct AdvertisementData {
        /* ################################################################## */
        /**
         This holds the raw advertisement data that came with the discovery.
         */
        public let advertisementData: [String: Any]
        
        /* ################################################################## */
        /**
         Returns the local name, if provided. If not provided, will return an empty String.
         */
        public var localName: String { advertisementData["kCBAdvDataLocalName"] as? String ?? "" }
        
        /* ################################################################## */
        /**
         Returns true or false. True, if the Peripheral is connectable.
         */
        public var isConnectable: Bool { advertisementData["kCBAdvDataIsConnectable"] as? Bool ?? false }
        
        /* ################################################################## */
        /**
         Returns the transmit power level. Nil, if not provided.
         */
        public var transmitPowerLevel: Int? { advertisementData["kCBAdvDataTxPowerLevel"] as? Int }
        
        /* ################################################################## */
        /**
         Returns the timestamp, as a date. Nil, if not provided.
         */
        public var timestamp: Date? {
            guard let timeInterval = advertisementData["kCBAdvDataTimestamp"] as? Double else { return nil }
            return Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        
        /* ################################################################## */
        /**
         Returns true, if the Peripheral has a primary PHY.
         */
        public var hasPrimaryPHY: Bool { advertisementData["kCBAdvDataRxPrimaryPHY"] as? Bool ?? false }
        
        /* ################################################################## */
        /**
         Returns true, if the Peripheral has a secondary PHY.
         */
        public var hasSecondaryPHY: Bool { advertisementData["kCBAdvDataRxSecondaryPHY"] as? Bool ?? false }
        
        /* ################################################################## */
        /**
         Returns any manufacturer-specific data. Nil, if not provided.
         */
        public var manufacturerData: Data? { advertisementData["kCBAdvDataRxSecondaryPHY"] as? Data }
    }
    
    /* ################################################################################################################################## */
    /**
     This is a class, as opposed to a struct, because I want to make sure that it is referenced, and not copied.
     */
    public class DiscoveryData {
        /* ################################################################## */
        /**
         This is a countdown timer, for use as a timeout trap during connection.
         */
        private var _timer: Timer?
        
        /* ############################################################## */
        /**
         This holds the advertisement data that came with the discovery.
         */
        public var advertisementData: AdvertisementData!
        
        /* ############################################################## */
        /**
         This is the signal strength, at the time of discovery, in dBm.
         This is also updated, as we receive RSSI change notifications.
         */
        public var rssi: Int
        
        /* ############################################################## */
        /**
         This is the peripheral wrapper that is instantiated when the device is connected. It is nil, if the device is not connected. It is a strong reference.
         */
        public var peripheralInstance: CGA_Bluetooth_Peripheral? {
            didSet {
                clear()
            }
        }
        
        /* ############################################################## */
        /**
         The Peripheral is capable of sending writes back (without response).
         */
        public var canSendWriteWithoutResponse: Bool { cbPeripheral?.canSendWriteWithoutResponse ?? false }

        /* ############################################################## */
        /**
         The assigned Peripheral Name
         */
        public var name: String { cbPeripheral?.name ?? "" }

        /* ############################################################## */
        /**
         This is true, if the Peripheral advertisement data indicates the Peripheral can be connected.
         */
        public var canConnect: Bool { advertisementData.isConnectable }
        
        /* ############################################################## */
        /**
         This is the "Local Name," from the advertisement data.
         */
        public var localName: String { advertisementData.localName }
        
        /* ############################################################## */
        /**
         This is the local name, if available, or the Peripheral name, if the local name is not available.
         */
        public var preferredName: String { localName.isEmpty ? name : localName }
        
        /* ############################################################## */
        /**
         Returns the ID UUID as a String.
         */
        public var identifier: String { cbPeripheral?.identifier.uuidString ?? "" }
        
        /* ############################################################## */
        /**
         Returns true, if the peripheral is currently connected.
         */
        public var isConnected: Bool { .connected == cbPeripheral?.state }
        
        /* ############################################################## */
        /**
         This asks the Central Manager to ignore this device.
         
         - returns: True, if the ignore worked.
         */
        @discardableResult
        public func ignore() -> Bool {
            clear()
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
        public func unignore() -> Bool {
            clear()
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
        public func connect() -> Bool {
            clear()
            guard   let central = central,
                    !isConnected else { return false }
            _startTimeout()
            return central.connect(self)
        }
        
        /* ############################################################## */
        /**
         This asks the Central Manager to disconnect this device.
         
         - returns: True, if the attempt worked (not a guarantee of success, though).
         */
        @discardableResult
        public func disconnect() -> Bool {
            clear()
            guard   let central = central,
                    isConnected else { return false }
            return central.disconnect(self)
        }

        /* ############################################################## */
        /**
         Cancels the timeout.
         */
        public func clear() {
            _cancelTimeout()
        }

        /* ############################################################## */
        /**
         The actual Peripheral instance. This is a strong reference.
         This will retain the allocation for the Peripheral, so it is a strong reference.
         */
        internal var peripheral: Any
        
        /* ############################################################## */
        /**
         The Central manager that "owns" this discovered device. This is a weak reference.
         */
        internal weak var central: RVS_BlueThoth?

        /* ############################################################## */
        /**
         The actual Peripheral instance, cast as CBPeripheral.
         */
        internal var cbPeripheral: CBPeripheral! { peripheral as? CBPeripheral }
        
        /* ################################################################## */
        /**
         This is the callback for the timeout Timer firing.
         It is @objc, because it is a Timer callback.
         
         - parameter inTimer: The timer instance that fired.
         */
        @objc internal func timeout(_ inTimer: Timer) {
            #if DEBUG
                print("ERROR! Timeout.")
            #endif
            clear()
            central?.reportError(CGA_Errors.timeoutError(self))
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
        internal init(central inCentralManager: RVS_BlueThoth, peripheral inPeripheral: CBPeripheral, advertisementData inAdvertisementData: [String: Any], rssi inRSSI: Int) {
            central = inCentralManager
            peripheral = inPeripheral
            advertisementData = AdvertisementData(advertisementData: inAdvertisementData)
            rssi = inRSSI
        }
        
        /* ############################################################## */
        /**
         Make sure that we don't leave any open timers.
         */
        deinit {
            clear()
        }
        
        /* ################################################################## */
        /**
         Calling this starts the timeout clock.
         */
        private func _startTimeout() {
            #if DEBUG
                print("Starting Timeout.")
            #endif
            clear() // Just to be sure...
            _timer = Timer.scheduledTimer(withTimeInterval: _static_timeoutInSeconds, repeats: false, block: timeout(_:))
        }
        
        /* ################################################################## */
        /**
         This stops the timeout clock, invalidates the timer, and clears the Timer instance.
         */
        private func _cancelTimeout() {
            #if DEBUG
                if let fireDate = _timer?.fireDate {
                    print("Ending Timeout after \(_static_timeoutInSeconds - fireDate.timeIntervalSinceNow) Seconds.")
                } else {
                    print("No timer.")
                }
            #endif
            _timer?.invalidate()
            _timer = nil
        }
    }

    /* ################################################################## */
    /**
     The Central Manager Delegate object.
     */
    public weak var delegate: CGA_Bluetooth_CentralManagerDelegate?

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Class_Protocol
     */
    public weak var parent: CGA_Class_Protocol?
    
    /* ################################################################## */
    /**
     Returns true, if the current state of the Bluetooth system is powered on.
     */
    public var isBTAvailable: Bool { return .poweredOn == cbElementInstance?.state }

    /* ################################################################## */
    /**
     If tue (default), then scanning is done with duplicate filtering on, which reduces the number of times the discovery callback is made.
     */
    public var duplicateFilteringIsOn: Bool = true
    
    /* ################################################################## */
    /**
     This Bool will be true, if we only want to discover devices that can be connected. Default is false.
     */
    public var discoverOnlyConnectablePeripherals: Bool = false
    
    /* ################################################################## */
    /**
     This Bool will be true, if we will allow devices that don't broadcast names to be discovered. Default is false.
     */
    public var allowEmptyNames: Bool = false
    
    /* ################################################################## */
    /**
     This is a "Minimum RSSI Level" for filtering. If a device is discovered with an RSSI less than this, it is ignored.
     The Default is -100. It can be changed by the SDK user, for subsequent scans.
     */
    public var minimumRSSILevelIndBm: Int = -100

    /* ################################################################## */
    /**
     This will hold BLE Peripherals, as they are being "loaded." Once they are "complete," they go into the main collection, wrapped in our class.
     */
    public var stagedBLEPeripherals = [DiscoveryData]()
    
    /* ################################################################## */
    /**
     This will hold BLE Peripherals that have been marked as "ignored."
     */
    public var ignoredBLEPeripherals = [DiscoveryData]()
    
    /* ################################################################## */
    /**
     This will contain any required scan criteria.
     */
    public var scanCriteria: ScanCriteria!

    /* ################################################################## */
    /**
     We aggregate Peripherals.
     */
    public typealias Element = CGA_Bluetooth_Peripheral
    
    /* ################################################################## */
    /**
     This holds our cached Array of Peripheral instances.
     */
    public var sequence_contents: Array<Element>
    
    /* ################################################################## */
    /**
     This is the indicator as to whether or not the Bluetooth subsystem is actiively scanning for Peripherals.
     
     This is read-only. Use the <code>startScanning(withServices:)</code> and <code>stopScanning()</code> methods to change the scanning state.
     */
    public var isScanning: Bool {
        guard let centralManager = cbElementInstance else {
            #if DEBUG
                print("No Central Manager Instance.")
            #endif
            return false
        }
       
        return isBTAvailable && centralManager.isScanning
    }
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache. It should be empty.
     */
    public required init(sequence_contents inSequenceContents: [Element]) {
        sequence_contents = inSequenceContents
        super.init()    // Since we derive from NSObject, we must call the super init()
    }
    
    /* ################################################################## */
    /**
     This holds any Services (as Strings) that were specified when scanning started.
     */
    internal var scanningServices: [String] = []
    
    /* ################################################################## */
    /**
     This holds the instance of CBCentralManager that is used by this instance.
     */
    internal var cbElementInstance: CBCentralManager!
    
    /* ################################################################## */
    /**
     This is how many seconds we wait, before declaring a timeout.
     Default is 5 seconds, but the value can be changed.
     */
    private static var _static_timeoutInSeconds: TimeInterval = 5.0
}

/* ###################################################################################################################################### */
// MARK: - Private Instance Methods -
/* ###################################################################################################################################### */
/**
 These methods ensure that the delegate calls are made in the main thread.
 */
extension RVS_BlueThoth {
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
     This is called to send a Device update message to the delegate.
     */
    private func _sendDeviceUpdate(_ inDevice: CGA_Bluetooth_Peripheral) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Sending a Device Update message to the delegate.")
            #endif
            self.delegate?.centralManager(self, deviceInfoChanged: inDevice)
        }
    }
    
    /* ################################################################## */
    /**
     This is called to send a Service update message to the delegate.
     */
    private func _sendServiceUpdate(_ inService: CGA_Bluetooth_Service) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Sending a Service Update message to the delegate.")
            #endif
            if  let device = inService.peripheral {
                self.delegate?.centralManager(self, device: device, changedService: inService)
            }
        }
    }

    /* ################################################################## */
    /**
     This is called to send a Characteristic update message to the delegate.
     */
    private func _sendCharacteristicUpdate(_ inCharacteristic: CGA_Bluetooth_Characteristic) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Sending a Characteristic Update message to the delegate.")
            #endif
            if  let service = inCharacteristic.service,
                let device = service.peripheral {
                self.delegate?.centralManager(self, device: device, service: service, changedCharacteristic: inCharacteristic)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is called to send a Descriptor update message to the delegate.
     */
    private func _sendDescriptorUpdate(_ inDescriptor: CGA_Bluetooth_Descriptor) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Sending a Descriptor Update message to the delegate.")
            #endif
            if  let characteristic = inDescriptor.characteristic,
                let service = characteristic.service,
                let device = service.peripheral {
                self.delegate?.centralManager(self, device: device, service: service, characteristic: characteristic, changedDescriptor: inDescriptor)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Public Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth {
    /* ################################################################## */
    /**
     Called to report an error.
     
     - parameter inError: The error being reported.
     */
    public func reportError(_ inError: CGA_Errors) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Reporting \(inError.localizedDescription) as an error.")
            #endif
            self.delegate?.handleError(inError, from: self)
        }
    }
    
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     Convenience init. This allows "no parameter" inits, and ones that only have the queue and/or the delegate.
     This will call the delegate's updateFrom(_:) method, upon starting.
     
     - parameter delegate: The delegate instance.
     - parameter scanCriteria: If there are particular scan criteria to be applied to the discovery process, they are supplied here. If left alone, it will be nil, and all entities will be searched.
     - parameter queue: The queue to be used for this instance. If not specified, the main thread is used.
     */
    public convenience init(delegate inDelegate: CGA_Bluetooth_CentralManagerDelegate! = nil, scanCriteria inScanCriteria: ScanCriteria! = nil, queue inQueue: DispatchQueue? = nil) {
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
     - parameter duplicateFilteringIsOn: If true, then scans will be made with duplicate filtering, which reduces the number of times the discovery callback is made.
     - returns: True, if the scan attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    public func startScanning(withServices inWithServices: [String]? = nil, duplicateFilteringIsOn inDuplicateFilteringIsOn: Bool = true) -> Bool {
        guard let cbCentral = cbElementInstance else { return false }
        #if DEBUG
            print("Asking Central Manager to Start Scanning.")
            if  let services = inWithServices,
                !services.isEmpty {
                print("\tWith these Services: \(String(describing: services))")
            }
        #endif
        
        duplicateFilteringIsOn = inDuplicateFilteringIsOn
        
        // Take off and nuke the entire site from orbit.
        // It's the only way to be sure.
        if cbCentral.isScanning {
            cbCentral.stopScan()
        }
        
        var services: [CBUUID]!
        let options: [String: Any]! = duplicateFilteringIsOn ? nil : [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        
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
        
        services = scanningServices.compactMap { CBUUID(string: $0) }
        
        cbCentral.scanForPeripherals(withServices: services, options: options)
        
        _updateDelegate()

        return true
    }
    
    /* ################################################################## */
    /**
     Asks the Central Manager to start scanning for Peripherals, but reuse any saved filters (as opposed to supplying them).
     - returns: True, if the scan attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    public func restartScanning() -> Bool {
        #if DEBUG
            print("Asking Central Manager to Restart Scanning.")
        #endif
        return startScanning(withServices: scanningServices, duplicateFilteringIsOn: duplicateFilteringIsOn)
    }
    
    /* ################################################################## */
    /**
     Asks the Central Manager to stop scanning for Peripherals.
     - returns: True, if the attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    public func stopScanning() -> Bool {
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
    public func startOver() {
        #if DEBUG
            print("Starting The Central Manager Peripheral Discovery Over From Scratch.")
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
     Called to initiate a connection (and discovery process) with the peripheral.
     
     - parameter inPeripheral: The Peripheral (CB) to connect, as the opaque DiscoveryData type.
     - returns: True, if the connection attempt was made (not a guarantee of success, though). Can be ignored.
     */
    @discardableResult
    public func connect(_ inPeripheral: DiscoveryData?) -> Bool {
        guard   let peripheral = inPeripheral?.cbPeripheral,
                let cbCentral = cbElementInstance,
                stagedBLEPeripherals.contains(peripheral)
        else {
            #if DEBUG
                print("ERROR! \(String(describing: inPeripheral?.name)) cannot be connected, because of an internal error.")
            #endif
            reportError(CGA_Errors.internalError(nil))
            return false
        }
        #if DEBUG
            print("Connecting \(String(describing: peripheral.name)).")
        #endif
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
    public func disconnect(_ inPeripheral: DiscoveryData) -> Bool {
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
}

/* ###################################################################################################################################### */
// MARK: - Internal Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth {
    /* ################################################################## */
    /**
     Called to add a Peripheral to our "keeper" Array.
     
     - parameter inPeripheral: The Peripheral to add.
     */
    internal func addPeripheral(_ inPeripheral: CGA_Bluetooth_Peripheral) {
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
    internal func removePeripheral(_ inPeripheral: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Removing \(inPeripheral.discoveryData.preferredName).")
        #endif
        _sendPeripheralDisconnect(inPeripheral)
        sequence_contents.removeThisDevice(inPeripheral.discoveryData.cbPeripheral)
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This returns the parent Central Manager(Ourself)
     */
    public var central: RVS_BlueThoth? { self }

    /* ################################################################## */
    /**
     This class is the "endpoint" of all errors, so it passes the error back to the delegate.
     */
    public func handleError(_ inError: CGA_Errors) {
        reportError(inError)
    }
    
    /* ################################################################## */
    /**
     The Central Manager does not have a UUID.
     */
    public var id: String { "" }
    
    /* ################################################################## */
    /**
     This is called to inform an instance that a Device changed.
     
     - parameter inDevice: The Peripheral wrapper instance that changed.
     */
    public func updateThisDevice(_ inDevice: CGA_Bluetooth_Peripheral) {
        _sendDeviceUpdate(inDevice)
    }
    
    /* ################################################################## */
    /**
     This is called to inform an instance that a Service changed.
     
     - parameter inService: The Service wrapper instance that changed.
     */
    public func updateThisService(_ inService: CGA_Bluetooth_Service) {
        _sendServiceUpdate(inService)
    }

    /* ################################################################## */
    /**
     This is called to inform an instance that a Characteristic downstream changed.
     
     - parameter inCharacteristic: The Characteristic wrapper instance that changed.
     */
    public func updateThisCharacteristic(_ inCharacteristic: CGA_Bluetooth_Characteristic) {
        _sendCharacteristicUpdate(inCharacteristic)
    }

    /* ################################################################## */
    /**
     This is called to inform an instance that a Descriptor downstream changed.
     
     - parameter inDescriptor: The Descriptor wrapper instance that changed.
     */
    public func updateThisDescriptor(_ inDescriptor: CGA_Bluetooth_Descriptor) {
        _sendDescriptorUpdate(inDescriptor)
    }
    
    /* ################################################################## */
    /**
     This eliminates all of the stored and staged results.
     */
    public func clear() {
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
extension RVS_BlueThoth: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     This is called when the CentralManager state updates.
     
     - parameter inCentralManager: The CBCentralManager instance that is calling this.
     */
    public func centralManagerDidUpdateState(_ inCentralManager: CBCentralManager) {
        switch inCentralManager.state {
        case .poweredOn:
            #if DEBUG
                print("Central Manager State Changed to Powered On.")
            #endif
            _updateDelegatePoweredOn()
            
        case .poweredOff:
            #if DEBUG
                print("Central Manager State Changed to Powered Off.")
            #endif
            stopScanning()

        case .resetting:
            #if DEBUG
                print("Central Manager State Changed to Resetting.")
            #endif
            stopScanning()

        case .unauthorized:
            #if DEBUG
                print("Central Manager State Changed to Unauthorized.")
            #endif
            stopScanning()

        case .unknown:
            #if DEBUG
                print("Central Manager State Changed to Unknown.")
            #endif
            stopScanning()

        case .unsupported:
            #if DEBUG
                print("Central Manager State Changed to Unsupported.")
            #endif
            stopScanning()

        default:
            #if DEBUG
                print("ERROR! Central Manager Changed to an Unknown State!")
            #endif
            stopScanning()
            central?.reportError(.internalError(nil))
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
    public func centralManager(_ inCentralManager: CBCentralManager, didDiscover inPeripheral: CBPeripheral, advertisementData inAdvertisementData: [String: Any], rssi inRSSI: NSNumber) {
        var name: String = "EMPTY"
        
        if !allowEmptyNames {
            guard   let tempName = inPeripheral.name,
                    !tempName.isEmpty
            else {
                #if DEBUG
                    print("Discarding empty-name Peripheral: \(inPeripheral.identifier.uuidString).")
                #endif
                return
            }
            
            name = tempName
        }
        
        guard minimumRSSILevelIndBm <= inRSSI.intValue else {
            #if DEBUG
                print("Discarding Peripheral: \(inPeripheral.identifier.uuidString), because its RSSI level of \(inRSSI.intValue) is less than our minimum RSSI threshold of \(minimumRSSILevelIndBm)")
            #endif
            return
        }
        
        if discoverOnlyConnectablePeripherals {
            guard let connectableAdvertisementData = inAdvertisementData["kCBAdvDataIsConnectable"] as? Bool,
                connectableAdvertisementData else {
                #if DEBUG
                    print("Discarding Peripheral: \(inPeripheral.identifier.uuidString), because it is not connectable.")
                #endif
                return
            }
        }
        
        // See if we have asked for only particular peripherals.
        if  let peripherals = scanCriteria?.peripherals,
            0 < peripherals.count,
            !peripherals.reduce(false, { (current, next) -> Bool in
                current || (next.uppercased() == inPeripheral.identifier.uuidString.uppercased())
            }) {
            #if DEBUG
                print("Discarding Peripheral not on the guest list: \(inPeripheral.identifier.uuidString).")
            #endif
            return
        } else if !ignoredBLEPeripherals.contains(inPeripheral) {
            #if DEBUG
                print("Discovered \(name) (BLE).")
            #endif
            guard   !inPeripheral.identifier.uuidString.isEmpty
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
            if  let deviceInStaging = stagedBLEPeripherals[inPeripheral] {
                deviceInStaging.advertisementData = AdvertisementData(advertisementData: inAdvertisementData)
                deviceInStaging.rssi = inRSSI.intValue
            } else {
                stagedBLEPeripherals.append(DiscoveryData(central: self, peripheral: inPeripheral, advertisementData: inAdvertisementData, rssi: inRSSI.intValue))
            }
            
            _updateDelegate()
        } else {
            #if DEBUG
                print("Discarding Ignored Peripheral: \(inPeripheral.identifier.uuidString).")
            #endif
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Bluetooth device has been connected (but no discovery yet).
     
     - parameters:
        - inCentralManager: The CBCentralManager instance that is calling this.
        - didConnect: The CBPeripheral instance that was connected.
     */
    public func centralManager(_ inCentralManager: CBCentralManager, didConnect inPeripheral: CBPeripheral) {
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
    public func centralManager(_ inCentralManager: CBCentralManager, didDisconnectPeripheral inPeripheral: CBPeripheral, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            reportError(.internalError(error))
        } else {
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
    }
    
    /* ################################################################## */
    /**
     This is called when a Bluetooth device connection has failed.
     
     - parameters:
        - inCentralManager: The CBCentralManager instance that is calling this.
        - didFailToConnect: The CBPeripheral instance that was not connected.
        - error: Any error that occurred. It can be nil.
     */
    public func centralManager(_ inCentralManager: CBCentralManager, didFailToConnect inPeripheral: CBPeripheral, error inError: Error?) {
        #if DEBUG
            print("Connecting \(String(describing: inPeripheral.name)) Failed.")
            if let error = inError {
                print("\tWith error: \(error.localizedDescription).")
            }
        #endif
        if let error = inError {
            central?.reportError(.internalError(error))
        }
    }
}
