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
// MARK: - CBPeripheral Wrapper Class -
/* ###################################################################################################################################### */
/**
 This class is instantiated when a Peripheral is connected, and will handle discovery of Services, Characteristics and Descriptors.
 */
class CGA_Bluetooth_Peripheral: NSObject, RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This is the type we're aggregating.
     */
    typealias Element = CGA_Bluetooth_Service
    
    /* ################################################################## */
    /**
     This holds our Service wrapper instances until we have received all the Characteristics for them.
     */
    var stagedServices: Array<Element> = []
    
    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    var sequence_contents: Array<Element> = []

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Parent instance.
     */
    weak var parent: CGA_Class_Protocol?

    /* ################################################################## */
    /**
     This returns the instance of CBPeripheral that is used by this instance.
     */
    var cbElementInstance: CBPeripheral! { discoveryData?.cbPeripheral }
    
    /* ################################################################## */
    /**
     This holds the discovery data that applies to this instance.
     */
    var discoveryData: CGA_Bluetooth_CentralManager.DiscoveryData!
    
    /* ################################################################## */
    /**
     This holds any Services (as Strings) that were specified when discovery started.
     */
    var discoveryServices: [String] = []

    /* ################################################################## */
    /**
     This casts the parent as a Central Manager.
     */
    var central: CGA_Bluetooth_CentralManager! { parent as? CGA_Bluetooth_CentralManager }

    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    var scanCriteria: CGA_Bluetooth_CentralManager.ScanCriteria! {
        return central?.scanCriteria
    }
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequence_Contents: [Element]) {
        sequence_contents = inSequence_Contents
        super.init()    // Since we derive from NSObject, we must call the super init()
    }
    
    /* ################################################################## */
    /**
     Make sure that we are removed, if we are going away.
     */
    deinit {
        central?.removePeripheral(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral {
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     - parameter discoveryData: The discovery data of the Peripheral.
     - parameter services: An optional parameter that is an Array, holding the String UUIDs of Services we are filtering for. If left out, all available Services are found. If specified, this overrides the scanCriteria.
     */
    convenience init(discoveryData inCBPeriperalDiscoveryData: CGA_Bluetooth_CentralManager.DiscoveryData, services inServices: [String] = []) {
        self.init(sequence_contents: [])
        discoveryData = inCBPeriperalDiscoveryData
        parent = discoveryData?.central
        cbElementInstance?.delegate = self
        
        var services: [CBUUID]! = inServices.compactMap { CBUUID(string: $0) }
        
        if services?.isEmpty ?? false {
            services = scanCriteria?.services?.compactMap { CBUUID(string: $0) }
        }
        
        if services?.isEmpty ?? false {
            services = nil
        }
        
        cbElementInstance?.discoverServices(services)
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Instance Methods
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral {
    /* ################################################################## */
    /**
     This registers us with the Central wrapper.
     */
    private func _registerWithCentral() {
        if let central = central {
            central.addPeripheral(self)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_Protocol Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     This is the required conformance method to update the collection.
     */
    func updateCollection() {
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral: CBPeripheralDelegate {
    /* ################################################################## */
    /**
     */
    func peripheral(_ inPeripheral: CBPeripheral, didDiscoverServices inError: Error?) {
        print("Services Discovered: \(String(describing: inPeripheral.services))")
        
        stagedServices = []
        inPeripheral.services?.forEach {
            let serviceWrapperInstance = CGA_Bluetooth_Service(sequence_contents: [])
            serviceWrapperInstance.parent = self
            serviceWrapperInstance.cbElementInstance = $0
            stagedServices.append(serviceWrapperInstance)
        }
        
        stagedServices.forEach {
            if let service = $0.cbElementInstance {
                inPeripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func peripheral(_ inPeripheral: CBPeripheral, didModifyServices inInvalidatedServices: [CBService]) {
        print("Services Modified: \(String(describing: inInvalidatedServices))")
    }
    
    /* ################################################################## */
    /**
     */
    func peripheral(_ inPeripheral: CBPeripheral, didDiscoverCharacteristicsFor inService: CBService, error inError: Error?) {
        #if DEBUG
        print("Service: \(String(describing: inService)) discovered these Characteristics: \(String(describing: inService.characteristics))")
        #endif
        if let serviceInstance = stagedServices[inService] {
            stagedServices.removeThisService(inService)
            sequence_contents.append(serviceInstance)
            
            if stagedServices.isEmpty {
                // TODO: Remove after getting all the Characteristics loaded.
                _registerWithCentral()
                // END TODO
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
extension Array where Element == CGA_Bluetooth_Peripheral {
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
                } else if nextItem.cbElementInstance.identifier == inItem.identifier {
                    return nextItem
                }
                
                return nil
            }
            
            return current
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
    
    /* ################################################################## */
    /**
     Removes the element (as a CBPeripheral).
     
     - parameter inItem: The CB element we're looking to remove, as the opaque type.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisDevice(_ inItem: CBPeripheral) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            guard let testPeripheral = test.discoveryData?.cbPeripheral else { return false }
            if testPeripheral === inItem {
                success = true
                return true
            } else if testPeripheral.identifier.uuidString == inItem.identifier.uuidString {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }
}
