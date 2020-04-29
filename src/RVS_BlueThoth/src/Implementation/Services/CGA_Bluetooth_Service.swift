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
// MARK: - The Main Wrapper Class for Services -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of CBService, adding some functionality, and linking the hierarchy.
 */
public class CGA_Bluetooth_Service: CGA_Bluetooth_Service_Protocol_Internal {
    // MARK: Public Properties
    
    /* ################################################################## */
    /**
     This is the type we're aggregating.
     */
    public typealias Element = CGA_Bluetooth_Characteristic
    
    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    public var sequence_contents: Array<Element> = []

    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Peripheral
     */
    public weak var parent: CGA_Class_Protocol?
    
    /* ################################################################## */
    /**
     This returns a unique UUID String for the instance.
     */
    public var id: String { cbElementInstance?.uuid.uuidString ?? "ERROR" }
    
    /* ################################################################## */
    /**
     This returns the parent Central Manager
     */
    public var central: RVS_BlueThoth? { parent?.central }

    // MARK: Public Methods
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    public required init(sequence_contents inSequence_Contents: [Element]) {
        sequence_contents = inSequence_Contents
    }
    
    // MARK: Internal Properties
    
    /* ################################################################## */
    /**
     Root class does nothing.
     */
    internal class var uuid: String { "" }

    /* ################################################################## */
    /**
     This holds the instance of CBService that is used by this instance.
     */
    internal weak var cbElementInstance: CBService!
    
    /* ################################################################## */
    /**
     This casts the parent as a Peripheral Wrapper.
     */
    internal var peripheral: CGA_Bluetooth_Peripheral! { parent as? CGA_Bluetooth_Peripheral }
    
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    internal var scanCriteria: RVS_BlueThoth.ScanCriteria! { peripheral?.scanCriteria }
    
    /* ################################################################## */
    /**
     This is a "preview cache." It will aggregate instances of Characteristic wrappers that are still in discovery.
     */
    internal var stagedCharacteristics: Array<Element> = []

    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     - parameter parent: The Service instance that "owns" this instance.
     - parameter cbElementInstance: This is the actual CBService instance to be associated with this instance.
     */
    internal required convenience init(parent inParent: CGA_Bluetooth_Peripheral, cbElementInstance inCBService: CBService) {
        self.init(sequence_contents: [])
        parent = inParent
        cbElementInstance = inCBService
    }
    
    // MARK: Private Properties
    
    /* ################################################################## */
    /**
     This holds a list of UUIDs, holding the IDs of Characteristics we are looking for. It is initialized when the class is instantiated.
     */
    private var _discoveryFilter: [CBUUID] = []
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Service {
    /* ################################################################## */
    /**
     Called to tell the instance to discover its characteristics.
     
     - parameter characteristics: An optional parameter that is an Array, holding the String UUIDs of Characteristics we are filtering for.
                                  If left out, all available Characteristics are found. If specified, this overrides the scanCriteria.
     */
    internal func discoverCharacteristics(characteristics inCharacteristics: [String] = []) {
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
    internal func discoveredCharacteristics(_ inCharacteristics: [CBCharacteristic]) {
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
        stagedCharacteristics.forEach { $0.startOver() }
    }
    
    /* ################################################################## */
    /**
     Called to add a Characteristic to our "keeper" Array.
     
     - parameter inCharacteristic: The Characteristic to add.
     */
    internal func addCharacteristic(_ inCharacteristic: CGA_Bluetooth_Characteristic) {
        if let characteristic = inCharacteristic.cbElementInstance {
            if stagedCharacteristics.contains(characteristic) {
                #if DEBUG
                    print("Adding the \(characteristic.uuid.uuidString) Characteristic to the \(id) Service.")
                #endif
                stagedCharacteristics.removeThisCharacteristic(characteristic)
                sequence_contents.append(inCharacteristic)
                
                if stagedCharacteristics.isEmpty {
                    #if DEBUG
                        print("All Characteristics fulfilled. Adding this Service: \(id) to this Peripheral: \((parent as? CGA_Bluetooth_Peripheral)?.id ?? "ERROR")")
                    #endif
                    (parent as? CGA_Bluetooth_Peripheral)?.addService(self)
                }
            } else {
                #if DEBUG
                    print("The \(characteristic.uuid.uuidString) Characteristic will not be added to the \(id) Service, as it is not staged.")
                #endif
            }
            central?.updateThisCharacteristic(inCharacteristic)
        } else {
            #if DEBUG
                print("ERROR! \(String(describing: inCharacteristic)) does not have a CBCharacteristic instance.")
            #endif
            
            central?.reportError(.internalError(error: nil, id: inCharacteristic.id))
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Service: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This eliminates all of the stored and staged results.
     */
    public func clear() {
        #if DEBUG
            print("Clearing the decks for a Service: \(id).")
        #endif
        
        stagedCharacteristics = []
        sequence_contents = []
    }

    /* ################################################################## */
    /**
     This eliminates all of the stored results, and asks the Bluetooth subsystem to start over from scratch.
     */
    public func startOver() {
        guard let cbElementInstance = cbElementInstance else {
            #if DEBUG
                print("ERROR! No CBService!")
            #endif
            
            central?.reportError(.internalError(error: nil, id: id))

            return
        }
        #if DEBUG
            print("Starting The Characteristic Discovery Over From Scratch for \(id).")
        #endif
        
        clear()
        
        let filters: [CBUUID]! = _discoveryFilter.isEmpty ? nil : _discoveryFilter

        peripheral?.cbElementInstance?.discoverCharacteristics(filters, for: cbElementInstance)
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_ServiceFactory Conformance -
/* ###################################################################################################################################### */
/**
 This allows us to create Services.
 */
extension CGA_Bluetooth_Service: CGA_ServiceFactory {
    /* ################################################################## */
    /**
     This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Peripheral that "owns" this Service
     - parameter cbElementInstance: The CB element for this Service.
     - returns: A new instance of CGA_Bluetooth_Service, or a subclass, thereof. Nil, if it fails.
     */
    internal class func createInstance(parent inParent: CGA_Bluetooth_Peripheral, cbElementInstance inCBService: CBService) -> CGA_Bluetooth_Service? {
        let ret = Self.init(sequence_contents: [])
        ret.parent = inParent
        ret.cbElementInstance = inCBService
        
        return ret
    }
}
