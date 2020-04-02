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
    var parent: CGA_Class_Protocol? { get set }
    
    /* ################################################################## */
    /**
     REQUIRED: This is called to tell the instance to do whatever it needs to do to update its collection.
     */
    func updateCollection()

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: Error)
}

/* ###################################################################################################################################### */
// MARK: - Defaults
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
     */
    func updateFrom(_ manager: CGA_Bluetooth_CentralManager)
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
}

/* ###################################################################################################################################### */
// MARK: - The Central Manager -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_CentralManager: NSObject, RVS_SequenceProtocol {
    struct DiscoveryData {
        /* ############################################################## */
        /**
         The actual Peripheral instance.
         */
        let peripheral: CBPeripheral
        
        /* ############################################################## */
        /**
         The initial Peripheral Name
         */
        let name: String
        
        /* ############################################################## */
        /**
         */
        let advertisementData: [String: Any]
        
        /* ############################################################## */
        /**
         */
        let rssi: Int
        
        /* ############################################################## */
        /**
         */
        var canConnect: Bool {
            if !advertisementData.isEmpty {
                return advertisementData.reduce(false) { (current, next) in
                    if  !current,
                        CBAdvertisementDataIsConnectable == next.key {
                        if let value = next.value as? Int {
                            return 1 == value
                        }
                    }
                    
                    return current || false
                }
            }
            
            return false
        }
        
        /* ############################################################## */
        /**
         */
        var localName: String {
            if !advertisementData.isEmpty {
                return advertisementData.reduce("") { (current, next) in
                    if  current.isEmpty,
                        CBAdvertisementDataLocalNameKey == next.key {
                        if let value = next.value as? String {
                            return value
                        }
                    }
                    
                    return current
                }
            }
            
            return ""
        }
        
        /* ############################################################## */
        /**
         */
        var preferredName: String {
            var ret = localName
            
            if ret.isEmpty {
                ret = name
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     The Central Manager Delegate object.
     */
    weak var delegate: CGA_Bluetooth_CentralManagerDelegate?
    
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Class_Protocol
     */
    var parent: CGA_Class_Protocol?
    
    /* ################################################################## */
    /**
     Returns true, if the current state of the Bluetooth system is powered on.
     */
    var isBTAvailable: Bool {
        if let instance = cbElementInstance {
            return .poweredOn == instance.state
        }
        return false
    }

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
     
     It is really an accessor that reflects the behavior of the Central Manager CB object, and will also notify the delegate of changes in the state.
     */
    var isScanning: Bool {
        get {
            guard let centralManager = cbElementInstance else {
                #if DEBUG
                    print("No Central Manager Instance.")
                #endif
                return false
            }
           
            return centralManager.isScanning
        }
        
        set {
            guard let centralManager = cbElementInstance else {
                #if DEBUG
                    print("No Central Manager Instance.")
                #endif
                return
            }

            let oldValue = centralManager.isScanning
            
            #if DEBUG
                print("Central Manager was \(oldValue ? "" : "not ")scanning.")
                print("Turning scanning \(newValue ? "on" : "off").")
            #endif
            
            if newValue {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            } else if centralManager.isScanning {
                centralManager.stopScan()
            }

            _updateDelegate()
        }
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
    private func _updateDelegate() {
        DispatchQueue.main.async {
            #if DEBUG
                print("Asking delegate to recaclculate.")
            #endif
            self.delegate?.updateFrom(self)
        }
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
     - parameter queue: The queue to be used for this instance. If not specified, the main thread is used.
     */
    convenience init(delegate inDelegate: CGA_Bluetooth_CentralManagerDelegate! = nil, queue inQueue: DispatchQueue? = nil) {
        self.init(sequence_contents: [])
        delegate = inDelegate
        cbElementInstance = CBCentralManager(delegate: self, queue: inQueue)
        _updateDelegate()
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
        isScanning = false
        stagedBLEPeripherals = []
        sequence_contents = []
        _updateDelegate()
        isScanning = wasScanning
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_Protocol Support -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_CentralManager: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This class is the "endpoint" of all errors, so it passes the error back to the delegate.
     */
    func handleError(_ inError: Error) {
        _reportError(inError)
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance to do whatever it needs to do to update its collection.
     We define this here, so it ca be overriddden.
     */
    func updateCollection() {
        _updateDelegate()
    }
}

/* ###################################################################################################################################### */
// MARK: - CBCentralManagerDelegate Support -
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
            isScanning = true

        case .poweredOff:
            #if DEBUG
                print("\tState is Powered Off.")
            #endif
            isScanning = false

        case .resetting:
            #if DEBUG
                print("\tState is Resetting.")
            #endif
            isScanning = false

        case .unauthorized:
            #if DEBUG
                print("\tState is Unauthorized.")
            #endif
            isScanning = false

        case .unknown:
            #if DEBUG
                print("\tState is Unknown.")
            #endif
            isScanning = false

        case .unsupported:
            #if DEBUG
                print("\tState is Unsupported.")
            #endif
            isScanning = false

        default:
            #if DEBUG
                print("\tState is Something Else.")
            #endif
            isScanning = false
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
        if  let name = inPeripheral.name,
            !name.isEmpty {
            #if DEBUG
                print("Discovered \(name) (BLE).")
            #endif
            if  !stagedBLEPeripherals.contains(inPeripheral),
                !sequence_contents.contains(inPeripheral) {
                #if DEBUG
                    print("Added \(name) (BLE).")
                #endif
                stagedBLEPeripherals.append(DiscoveryData(peripheral: inPeripheral, name: name, advertisementData: inAdvertisementData, rssi: inRSSI.intValue))
                _updateDelegate()
            } else {
                #if DEBUG
                    print("Not Adding \(name) (BLE).")
                #endif
            }
        }
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
     Special subscript that allows us to retrieve an Element by its contained Peripheral
     
     - parameter inItem: The Peripheral we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBPeripheral) -> Element! {
        return reduce(nil) { (current, nextItem) in
            return nil == current ? (nextItem.peripheral.identifier == inItem.identifier ? nextItem : nil) : current
        }
    }
    
    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBPeripheral) -> Bool {
        return nil != self[inItem]
    }
}
