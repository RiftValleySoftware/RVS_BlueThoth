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
 */
protocol CGA_Class_Protocol: class {
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Class_Protocol
     */
    var parent: CGA_Class_Protocol? { get set }

    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: Error)
    
    /* ################################################################## */
    /**
     REQUIRED: This is called to tell the instance to do whatever it needs to do to update its collection.
     */
    func updateCollection()
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
// MARK: - The Main Protocol for Each Type -
/* ###################################################################################################################################### */
/**
 */
protocol CGA_Bluetooth_CentralManagerDelegate: class {
    /* ################################################################## */
    /**
     REQUIRED: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: Error, from: CGA_Bluetooth_CentralManager)
    
    /* ################################################################## */
    /**
     REQUIRED: This is called to tell the instance to do whatever it needs to do to update its data.
     */
    func updateFrom(_ manager: CGA_Bluetooth_CentralManager)
}

/* ###################################################################################################################################### */
// MARK: - The Central Manager -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_CentralManager: NSObject, RVS_SequenceProtocol {
    struct DiscoveryData {
        let peripheral: CBPeripheral
        let name: String
        let advertisementData: [String: Any]
        let rssi: Double
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
     This will hold Classic Peripherals, as they are being "loaded." Once they are "complete," they go into the main collection, wrapped in our class.
     */
    var stagedClassicPeripherals = [DiscoveryData]()
    
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
     */
    var isScanning: Bool = false {
        didSet {
            if let centralManager = cbElementInstance {
                if isScanning && !oldValue {
                    centralManager.scanForPeripherals(withServices: nil, options: nil)
                } else if !isScanning && oldValue {
                    centralManager.stopScan()
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequenceContents: [Element]) {
        sequence_contents = inSequenceContents
        super.init()    // Since we derive from NSObject, we must call the super init()
        #if targetEnvironment(simulator)
            centralManagerDidUpdateState(CBCentralManager())
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance to do whatever it needs to do to update its collection.
     We define this here, so it ca be overriddden.
     */
    func updateCollection() {
        #if targetEnvironment(simulator)
            #if DEBUG
                print("Generating Mocks for the Central Manager")
            #endif
        #else
        #endif
        
        delegate?.updateFrom(self)
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_CentralManager {
    /* ################################################################## */
    /**
     Convenience init. This allows "no parameter" inits, and ones that only have the queue.
     
     - parameter delegate: The delegate instance.
     - parameter queue: The queue to be used for this instance. If not specified, the main thread is used.
     */
    convenience init(delegate inDelegate: CGA_Bluetooth_CentralManagerDelegate! = nil, queue inQueue: DispatchQueue? = nil) {
        self.init(sequence_contents: [])
        delegate = inDelegate
        #if !targetEnvironment(simulator)
            cbElementInstance = CBCentralManager(delegate: self, queue: inQueue)
        #endif
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_CentralManager: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This class is the "endpoint" of all errors, so it passes the error back to the delegate.
     */
    func handleError(_ inError: Error) {
        delegate?.handleError(inError, from: self)
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_CentralManager: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     This is called when the CentralManager state updates.
     
     - parameter inCentralManager: The CBCentralManager instance that is calling this.
     */
    func centralManagerDidUpdateState(_ inCentralManager: CBCentralManager) {
        switch inCentralManager.state {
        case .poweredOn:
            isScanning = true
            updateCollection()

        case .poweredOff:
            isScanning = false
            #if targetEnvironment(simulator)    // If we are using a simulator, we pretend we got a .poweredOn state.
                isScanning = true
                updateCollection()
            #else
                break
            #endif

        default:
            isScanning = false
            updateCollection()
        }
    }

    /* ################################################################## */
    /**
     This is called when a Classic device has been connected.
     
     - parameters:
        - inCentralManager: The CBCentralManager instance that is calling this.
        - connectionEventDidOccur: The Connection event.
        - for: The CBPeripheral instance that was discovered.
     */
    func centralManager(_ inCentralManager: CBCentralManager, connectionEventDidOccur inConnectionEvent: CBConnectionEvent, for inPeripheral: CBPeripheral) {
        if  let name = inPeripheral.name,
            !name.isEmpty {
            print("Discovered \(name) (Classic).")
            if !stagedClassicPeripherals.contains(inPeripheral) {
                print("Added \(name) (Classic).")
                stagedClassicPeripherals.append(DiscoveryData(peripheral: inPeripheral, name: name, advertisementData: [:], rssi: 0))
                updateCollection()
            }
        }
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
    func centralManager(_ inCentralManager: CBCentralManager, didDiscover inPeripheral: CBPeripheral, advertisementData inAdvertisementData: [String : Any], rssi inRSSI: NSNumber) {
        if  let name = inPeripheral.name,
            !name.isEmpty {
            print("Discovered \(name) (BLE).")
            if !stagedBLEPeripherals.contains(inPeripheral) {
                print("Added \(name) (BLE).")
                stagedBLEPeripherals.append(DiscoveryData(peripheral: inPeripheral, name: name, advertisementData: inAdvertisementData, rssi: Double(truncating: inRSSI)))
                updateCollection()
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Peripherals Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Peripherals, looking for an exact instance.
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
            return nil == current ? (nextItem.peripheral === inItem ? nextItem : nil) : current
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
