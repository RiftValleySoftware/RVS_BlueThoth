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
// MARK: - CBCentralManagerDelegate Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     Called to set up the CB instance.
     We define this here, so we can break this file out (for purposes of documentation).
     
     - parameter inQueue: The dispatch queue we'll be using for this. If nil, then the main thread will be used.
     */
    internal func setCBInstance(_ inQueue: DispatchQueue?) {
        cbElementInstance = CBCentralManager(delegate: self, queue: inQueue)
    }
    
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
            reportError(.internalError(error: nil, id: nil))
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
        
        var name: String = "ERROR"
        
        if !allowEmptyNames {
            guard   let tempName = inPeripheral.name ?? (inAdvertisementData[CBAdvertisementDataLocalNameKey] as? String),
                    !tempName.isEmpty
            else {
                #if DEBUG
                    print("Discarding empty-name Peripheral: \(inPeripheral.identifier.uuidString).")
                #endif
                return
            }
            
            name = tempName
        } else if inPeripheral.name?.isEmpty ?? true {
            #if DEBUG
                print("Assigning \"\("SLUG-NO-DEVICE-NAME")\" as the name for this Peripheral: \(inPeripheral.identifier.uuidString).")
            #endif
            name = "SLUG-NO-DEVICE-NAME"
        }
        
        // See if we have asked for only particular peripherals.
        if  let peripherals = scanCriteria?.peripherals,
            0 < peripherals.count,
            !peripherals.contains(where: { ($0.uppercased() == inPeripheral.identifier.uuidString.uppercased()) }) {
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
                    print("Not Processing \(name), because the identifier is empty.")
                #endif
                return
            }
            
            #if DEBUG
                print("Processing \(name).")
                print("\tUUID: \(inPeripheral.identifier.uuidString)")
                print("\tAdvertising Info:\n\t\t\(String(describing: inAdvertisementData))\n")
            #endif
            
            if  let deviceInStaging = stagedBLEPeripherals[inPeripheral] {
                #if DEBUG
                    print("Updating previously staged peripheral.")
                #endif
                deviceInStaging.advertisementData = AdvertisementData(advertisementData: inAdvertisementData)
                deviceInStaging.rssi = inRSSI.intValue
            } else {
                #if DEBUG
                    print("Adding new peripheral to the end of the staging Array (\(stagedBLEPeripherals.count) items).")
                #endif
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
            print("Connected \(inPeripheral.identifier.uuidString).")
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
            reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, peripheral: inPeripheral))
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
            
            let id = peripheralInstance.id
            let wasExpected = peripheralInstance.disconnectionRequested
            
            peripheralObject.clear()
            peripheralInstance.discoveryData?.peripheralInstance = nil
            removePeripheral(peripheralObject)
            
            if !wasExpected {
                reportError(.unexpectedDisconnection(id))
            }
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
            reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, peripheral: inPeripheral))
        }
    }
}
