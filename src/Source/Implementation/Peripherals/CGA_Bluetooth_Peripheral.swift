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
// MARK: - CBPeripheral Wrapper Class -
/* ###################################################################################################################################### */
/**
 This class is instantiated when a Peripheral is connected, and will handle discovery of Services, Characteristics and Descriptors.
 */
public class CGA_Bluetooth_Peripheral: NSObject, RVS_SequenceProtocol {
    // MARK: - Public types, properties and methods.
    
    /* ################################################################## */
    /**
     This is the type we're aggregating.
     */
    public typealias Element = CGA_Bluetooth_Service
    
    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    public var sequence_contents: Array<Element> = []
    
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Bluetooth_Parent instance.
     */
    public weak var parent: CGA_Class_Protocol?
    
    /* ################################################################## */
    /**
     This holds the discovery data that applies to this instance.
     */
    public var discoveryData: RVS_BlueThoth.DiscoveryData!

    /* ################################################################## */
    /**
     This returns the parent Central Manager
     */
    public var central: RVS_BlueThoth? { parent?.central }

    /* ################################################################## */
    /**
     Returns true, if we are currently connected.
     */
    public var isConnected: Bool { discoveryData.isConnected }
    
    /* ############################################################## */
    /**
     The Peripheral is capable of sending writes back (without response).
     */
    public var canSendWriteWithoutResponse: Bool { discoveryData.canSendWriteWithoutResponse }

    /* ############################################################## */
    /**
     This is the signal strength, at the time of discovery, in dBm.
     This is also updated, as we receive RSSI change notifications.
     */
    public var rssi: Int { discoveryData.rssi }
    
    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    public var scanCriteria: RVS_BlueThoth.ScanCriteria! { central?.scanCriteria }
    
    /* ################################################################## */
    /**
     This returns a unique UUID String for the instance.
     */
    public var id: String { cbElementInstance?.identifier.uuidString ?? "ERROR" }

    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    public required init(sequence_contents inSequence_Contents: [Element]) {
        sequence_contents = inSequence_Contents
        super.init()    // Since we derive from NSObject, we must call the super init()
    }
    
    /* ################################################################## */
    /**
     Forces a connect. If already connected, nothing happens.
     */
    public func connect() { discoveryData?.connect() }
    
    /* ################################################################## */
    /**
     Forces a disconnect. If not connected, nothing happens.
     */
    public func disconnect() { discoveryData?.disconnect() }

    // MARK: - Internal types, properties and methods.

    /* ################################################################## */
    /**
     This holds our Service wrapper instances until we have received all the Characteristics for them.
     */
    internal var stagedServices: Array<Element> = []
    
    /* ################################################################## */
    /**
     This returns the instance of CBPeripheral that is used by this instance.
     */
    internal var cbElementInstance: CBPeripheral! { discoveryData?.cbPeripheral }
    
    /* ################################################################## */
    /**
     This is set to true, if the Central is requesting a disconnection (so we know it's expected).
     */
    internal var disconnectionRequested: Bool = false

    // MARK: - Private types, properties and methods.
    
    /* ################################################################## */
    /**
     This holds a list of UUIDs, holding the IDs of Services we are looking for. It is initialized when the class is instantiated.
     */
    private var _discoveryFilter: [CBUUID] = []
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral {
    /* ################################################################## */
    /**
     This eliminates all of the stored results, and asks the Bluetooth subsystem to start over from scratch.
     */
    public func startOver() {
        #if DEBUG
            print("Starting The Service Discovery Over From Scratch for \(discoveryData.preferredName).")
        #endif
        clear()
        let services: [CBUUID]! = _discoveryFilter.isEmpty ? nil : _discoveryFilter
        cbElementInstance?.discoverServices(services)
    }
    
    /* ################################################################## */
    /**
     This is the init that should always be used.
     
     - parameter discoveryData: The discovery data of the Peripheral.
     - parameter services: An optional parameter that is an Array, holding the String UUIDs of Services we are filtering for.
                           If left out, all available Services are found. If specified, this overrides the scanCriteria.
     */
    internal convenience init(discoveryData inCBPeriperalDiscoveryData: RVS_BlueThoth.DiscoveryData, services inServices: [String] = []) {
        self.init(sequence_contents: [])
        discoveryData = inCBPeriperalDiscoveryData
        parent = discoveryData?.central
        cbElementInstance?.delegate = self
        
        _discoveryFilter = inServices.compactMap { CBUUID(string: $0) }
        
        if _discoveryFilter.isEmpty {
            _discoveryFilter = scanCriteria?.services?.compactMap { CBUUID(string: $0) } ?? []
        }
        
        startOver()
    }
    
    /* ################################################################## */
    /**
     Called to add a Service to our "keeper" Array.
     
     - parameter inService: The Service to add.
     */
    internal func addService(_ inService: CGA_Bluetooth_Service) {
        if let service = inService.cbElementInstance {
            if stagedServices.contains(service) {
                #if DEBUG
                    print("Adding the \(inService.id) Service to the \(id) Peripheral.")
                #endif
                stagedServices.removeThisService(service)
                sequence_contents.append(inService)
                
                if stagedServices.isEmpty {
                    #if DEBUG
                        print("All Services fulfilled. Adding Peripheral (\(id)) to Central.")
                    #endif
                    _registerWithCentral()
                }
            } else {
                #if DEBUG
                    print("The \(inService.id) will not be added to the Peripheral, as it was not staged.")
                #endif
            }
            central?.updateThisService(inService)
        } else {
            #if DEBUG
                print("ERROR! \(String(describing: inService)) does not have a CBService instance.")
            #endif
            
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(nil, service: inService.cbElementInstance))
        }
    }
    
    /* ################################################################## */
    /**
     Request that the RSSI be updated.
     */
    internal func updateRSSI() { cbElementInstance?.readRSSI() }
}

/* ###################################################################################################################################### */
// MARK: - Private Instance Methods
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral {
    /* ################################################################## */
    /**
     This registers us with the Central wrapper.
     */
    private func _registerWithCentral() { central?.addPeripheral(self) }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This eliminates all of the stored and staged results.
     */
    public func clear() {
        #if DEBUG
            print("Clearing the decks for a Peripheral.")
        #endif
        
        stagedServices = []
        sequence_contents = []
    }
}
