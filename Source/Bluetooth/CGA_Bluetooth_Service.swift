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
// MARK: - The Main Wrapper Class for Services -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of CBService, adding some functionality, and linking the hierarchy.
 */
class CGA_Bluetooth_Service: RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This is the type we're aggregating.
     */
    typealias Element = CGA_Bluetooth_Characteristic
    
    /* ################################################################## */
    /**
     This holds a list of UUIDs, holding the IDs of Characteristics we are looking for. It is initialized when the class is instantiated.
     */
    private var _discoveryFilter: [CBUUID] = []

    /* ################################################################## */
    /**
     This is a "preview cache." It will aggregate instances of Characteristic wrappers that are still in discovery.
     */
    var stagedCharacteristics: Array<Element> = []
    
    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    var sequence_contents: Array<Element> = []

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Peripheral
     */
    weak var parent: CGA_Class_Protocol?

    /* ################################################################## */
    /**
     This holds the instance of CBService that is used by this instance.
     */
    weak var cbElementInstance: CBService!
    
    /* ################################################################## */
    /**
     This casts the parent as a Peripheral Wrapper.
     */
    var peripheral: CGA_Bluetooth_Peripheral! { parent as? CGA_Bluetooth_Peripheral }
    
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    var scanCriteria: CGA_Bluetooth_CentralManager.ScanCriteria! {
        return (parent as? CGA_Bluetooth_Peripheral)?.scanCriteria
    }
    
    /* ################################################################## */
    /**
     This returns a unique UUID String for the instance.
     */
    var id: String {
        cbElementInstance?.uuid.uuidString ?? "ERROR"
    }
    
    /* ################################################################## */
    /**
     This returns the parent Central Manager
     */
    var central: CGA_Bluetooth_CentralManager? { parent?.central }

    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequence_Contents: [Element]) {
        sequence_contents = inSequence_Contents
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Service {
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     - parameter parent: The Service instance that "owns" this instance.
     - parameter cbElementInstance: This is the actual CBService instance to be associated with this instance.
     */
    convenience init(parent inParent: CGA_Bluetooth_Peripheral, cbElementInstance inCBService: CBService) {
        self.init(sequence_contents: [])
        parent = inParent
        cbElementInstance = inCBService
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance to discover its characteristics.
     
     - parameter characteristics: An optional parameter that is an Array, holding the String UUIDs of Characteristics we are filtering for.
                                  If left out, all available Characteristics are found. If specified, this overrides the scanCriteria.
     */
    func discoverCharacteristics(characteristics inCharacteristics: [String] = []) {
        _discoveryFilter = inCharacteristics.compactMap { CBUUID(string: $0) }

        if _discoveryFilter.isEmpty {
            _discoveryFilter = scanCriteria?.characteristics?.compactMap { CBUUID(string: $0) } ?? []
        }
        
        startOver()
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance about its newly discovered Characteristics.
     This method creates new Characteristic wrappers, and stages them. It then asks each Characteristic to discover its Descriptors.
     
     - parameter inCharacteristics: The discovered Core Bluetooth Characteristics.
     */
    func discoveredCharacteristics(_ inCharacteristics: [CBCharacteristic]) {
        #if DEBUG
            print("Staging These Characteristics: \(inCharacteristics.map { $0.uuid.uuidString }.joined(separator: ", ")) for the \(self) Service.")
        #endif
        
        inCharacteristics.forEach {
            stagedCharacteristics.append(CGA_Bluetooth_Characteristic(parent: self, cbElementInstance: $0))
        }
        
        #if DEBUG
            print("Starting Characteristic Descriptor Discovery for the \(self) Service.")
        #endif
        
        // The reason that we do this separately, is that I want to make sure that we have completely loaded up the staging Array before starting the discovery process.
        // Otherwise, it could short-circuit the load.
        stagedCharacteristics.forEach {
            $0.startOver()
        }
    }
    
    /* ################################################################## */
    /**
     Called to add a Characteristic to our "keeper" Array.
     
     - parameter inCharacteristic: The Characteristic to add.
     */
    func addCharacteristic(_ inCharacteristic: CGA_Bluetooth_Characteristic) {
        if let characteristic = inCharacteristic.cbElementInstance {
            if stagedCharacteristics.contains(characteristic) {
                #if DEBUG
                    print("Adding the \(characteristic.uuid.uuidString) Characteristic to the \(self.id) Service.")
                #endif
                stagedCharacteristics.removeThisCharacteristic(characteristic)
                sequence_contents.append(inCharacteristic)
                
                if stagedCharacteristics.isEmpty {
                    #if DEBUG
                        print("All Characteristics fulfilled. Adding this Service: \(self.id) to this Peripheral: \((parent as? CGA_Bluetooth_Peripheral)?.id ?? "ERROR")")
                    #endif
                    (parent as? CGA_Bluetooth_Peripheral)?.addService(self)
                }
            } else {
                #if DEBUG
                    print("The \(characteristic.uuid.uuidString) Characteristic will not be added to the \(self.id) Service, as it is not staged.")
                #endif
            }
            central?.updateThisCharacteristic(inCharacteristic)
        } else {
            #if DEBUG
                print("ERROR! \(String(describing: inCharacteristic)) does not have a CBCharacteristic instance.")
            #endif
            
            central?.reportError(.internalError(nil))
        }
    }
    
    /* ################################################################## */
    /**
     This eliminates all of the stored and staged results.
     */
    func clear() {
        #if DEBUG
            print("Clearing the decks for a Service: \(self.id).")
        #endif
        
        stagedCharacteristics = []
        sequence_contents = []
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Service: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This eliminates all of the stored results, and asks the Bluetooth subsystem to start over from scratch.
     */
    func startOver() {
        guard let cbElementInstance = cbElementInstance else {
            #if DEBUG
                print("ERROR! No CBService!")
            #endif
            
            central?.reportError(.internalError(nil))

            return
        }
        #if DEBUG
            print("Starting The Characteristic Discovery Over From Scratch for \(self.id).")
        #endif
        
        clear()
        
        let filters: [CBUUID]! = _discoveryFilter.isEmpty ? nil : _discoveryFilter

        peripheral?.cbElementInstance?.discoverCharacteristics(filters, for: cbElementInstance)
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Services Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Services, looking for an exact instance.
 */
extension Array where Element == CGA_Bluetooth_Service {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Service
     
     - parameter inItem: The CBService we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBService) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                if nextItem === inItem {
                    return nextItem
                } else if nextItem.cbElementInstance.uuid == inItem.uuid {
                    return nextItem
                }
                    
                return nil
            }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     This subscript goes through our Services, looking for the one that "owns" the proferred Characteristic.
     
     - parameter inItem: The CBCharacteristic that the Service will aggregate.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBCharacteristic) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                return (nil != nextItem.cbElementInstance?.characteristics?[inItem]) ? nextItem : nil
            }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     This method goes through the Services, looking for the one that "owns" the proferred Characteristic, and then returning the "wrapper" for the Characteristic.
     
     - parameter inItem: The CBCharacteristic that the Service will aggregate.
     - returns: The found Element, or nil, if not found.
     */
    func characteristic(_ inItem: CBCharacteristic) -> CGA_Bluetooth_Characteristic! {
        guard let service: CGA_Bluetooth_Service = self[inItem] else { return nil }
        
        return service.sequence_contents[inItem]
    }

    /* ################################################################## */
    /**
     Removes the element (as a CBService).
     
     - parameter inItem: The CB element we're looking to remove.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisService(_ inItem: CBService) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            guard let testService = test.cbElementInstance else { return false }
            if testService === inItem {
                success = true
                return true
            } else if testService.uuid.uuidString == inItem.uuid.uuidString {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBService) -> Bool { nil != self[inItem] }
}
