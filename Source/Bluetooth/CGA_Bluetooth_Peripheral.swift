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
     This holds a list of UUIDs, holding the IDs of Services we are looking for. It is initialized when the class is instantiated.
     */
    private var _discoveryFilter: [CBUUID] = []

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
     This returns the parent Central Manager
     */
    var central: CGA_Bluetooth_CentralManager? { parent?.central }

    /* ############################################################## */
    /**
     The Peripheral is capable of sending writes back (without response).
     */
    var canSendWriteWithoutResponse: Bool { discoveryData.canSendWriteWithoutResponse }
    
    /* ############################################################## */
    /**
     This is the signal strength, at the time of discovery, in dBm.
     This is also updated, as we receive RSSI change notifications.
     */
    var rssi: Int { discoveryData.rssi }
    
    /* ############################################################## */
    /**
     Returns true, if the peripheral is authorized to receive data over the ANCS protocol.
     */
    var isANCSAuthorized: Bool { discoveryData.isANCSAuthorized }

    /* ################################################################## */
    /**
     This will contain any required scan criteria. It simply passes on the Central criteria.
     */
    var scanCriteria: CGA_Bluetooth_CentralManager.ScanCriteria! { central?.scanCriteria }
    
    /* ################################################################## */
    /**
     This returns a unique UUID String for the instance.
     */
    var id: String { cbElementInstance?.identifier.uuidString ?? "ERROR" }

    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequence_Contents: [Element]) {
        sequence_contents = inSequence_Contents
        super.init()    // Since we derive from NSObject, we must call the super init()
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
     - parameter services: An optional parameter that is an Array, holding the String UUIDs of Services we are filtering for.
                           If left out, all available Services are found. If specified, this overrides the scanCriteria.
     */
    convenience init(discoveryData inCBPeriperalDiscoveryData: CGA_Bluetooth_CentralManager.DiscoveryData, services inServices: [String] = []) {
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
    func addService(_ inService: CGA_Bluetooth_Service) {
        if let service = inService.cbElementInstance {
            if stagedServices.contains(service) {
                #if DEBUG
                    print("Adding the \(inService.id) Service to the \(self.id) Peripheral.")
                #endif
                stagedServices.removeThisService(service)
                sequence_contents.append(inService)
                
                if stagedServices.isEmpty {
                    #if DEBUG
                        print("All Services fulfilled. Adding Peripheral (\(self.id)) to Central.")
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
            
            central?.reportError(.internalError(nil))
        }
    }
    
    /* ################################################################## */
    /**
     This eliminates all of the stored results, and asks the Bluetooth subsystem to start over from scratch.
     */
    func startOver() {
        #if DEBUG
            print("Starting The Service Discovery Over From Scratch for \(self.discoveryData.preferredName).")
        #endif
        clear()
        let services: [CBUUID]! = _discoveryFilter.isEmpty ? nil : _discoveryFilter
        cbElementInstance?.discoverServices(services)
    }
    
    /* ################################################################## */
    /**
     Request that the RSSI be updated.
     */
    func updateRSSI() {
        cbElementInstance?.readRSSI()
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
        central?.addPeripheral(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Class_UpdateDescriptor Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral: CGA_Class_Protocol_UpdateDescriptor {
    /* ################################################################## */
    /**
     This eliminates all of the stored and staged results.
     */
    func clear() {
        #if DEBUG
            print("Clearing the decks for a Peripheral.")
        #endif
        
        stagedServices = []
        sequence_contents = []
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_Bluetooth_Peripheral: CBPeripheralDelegate {
    /* ################################################################## */
    /**
     Called when the RSSI changes.
     
     - parameter inPeripheral: The CBPeripheral that has discovered Services.
     - parameter didReadRSSI: The new RSSI value, in dBm.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didReadRSSI inRSSI: NSNumber, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(.internalError(error))
        } else {
            #if DEBUG
                print("RSSI: \(inRSSI) updated for the Peripheral: \(id)")
            #endif
            discoveryData.rssi = inRSSI.intValue
            central?.updateThisDevice(self)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the Peripheral has discovered its Services.
     We treat discovery as "atomic." We ask for all the Services at once, so this callback is complete for this Peripheral.
     
     - parameter inPeripheral: The CBPeripheral that has discovered Services.
     - parameter didDiscoverServices: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didDiscoverServices inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(.internalError(error))
        } else {
            #if DEBUG
                if let services = inPeripheral.services {
                    print("Services Discovered: \(services.map({ $0.uuid.uuidString }).joined(separator: ", "))")
                } else {
                    print("ERROR!")
                    central?.reportError(.internalError(nil))
                }
            #endif
                
            stagedServices = inPeripheral.services?.map { CGA_Bluetooth_Service(parent: self, cbElementInstance: $0) } ?? []
            
            stagedServices.forEach { $0.discoverCharacteristics() }
        }
    }
    
    /* ################################################################## */
    /**
     Called when a Service discovers Characteristics.
     We treat discovery as "atomic." We ask for all the Characteristics at once, so this callback is complete for this Service.
     
     - parameter inPeripheral: The CBPeripheral that has discovered Characteristics.
     - parameter didDiscoverCharacteristicsFor: The Service instance to which the Characteristics apply.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didDiscoverCharacteristicsFor inService: CBService, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(.internalError(error))
        } else {
            guard let characteristics = inService.characteristics else {
                #if DEBUG
                    print("ERROR! The characteristics Array is nil!")
                #endif
                central?.reportError(.internalError(nil))
                return
            }
            
            #if DEBUG
                print("Service: \(inService.uuid.uuidString) discovered these Characteristics: \(characteristics.map { $0.uuid.uuidString }.joined(separator: ", "))")
            #endif
            
            if let service = (stagedServices[inService] ?? sequence_contents[inService]) {
                service.discoveredCharacteristics(characteristics)
            } else {
                #if DEBUG
                    print("ERROR! Service not found!")
                #endif
                central?.reportError(.internalError(nil))
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when a Characteristic discovers all of its Descriptors.
     We treat discovery as "atomic." We ask for all the Descriptors at once, so this callback is complete for this Characteristic.

     - parameter inPeripheral: The CBPeripheral that has discovered Descriptors.
     - parameter didDiscoverDescriptorsFor: The Characteristic instance to which the Descriptors apply.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didDiscoverDescriptorsFor inCharacteristic: CBCharacteristic, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(.internalError(error))
        } else {
            guard let descriptors = inCharacteristic.descriptors else {
                #if DEBUG
                    print("ERROR! The descriptors Array is nil!")
                #endif
                central?.reportError(.internalError(nil))
                return
            }
            
            #if DEBUG
                if 1 > descriptors.count {
                    print("Characteristic: \(inCharacteristic.uuid.uuidString) has no descriptors.")
                } else {
                    print("Characteristic: \(inCharacteristic.uuid.uuidString) discovered these Descriptors: \(descriptors.map { $0.uuid.uuidString }.joined(separator: ", "))")
                }
            #endif
            
            if  let service = (stagedServices[inCharacteristic] ?? sequence_contents[inCharacteristic]) {
                let characteristic = CGA_Bluetooth_Characteristic(parent: service, cbElementInstance: inCharacteristic)
                inCharacteristic.descriptors?.forEach {
                    let descriptor = CGA_Bluetooth_Descriptor()
                    descriptor.parent = characteristic
                    descriptor.cbElementInstance = $0
                    characteristic.addDescriptor(descriptor)
                }
                #if DEBUG
                    print("All Descriptors fulfilled. Adding this Characteristic: \(characteristic.id) to this Service: \(service.id)")
                #endif
                service.addCharacteristic(characteristic)
            } else {
                #if DEBUG
                    print("ERROR! There is no Service for this Characteristic: \(inCharacteristic.uuid.uuidString)")
                #endif
                central?.reportError(.internalError(nil))
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when any Services have been modified.
     
     - parameter inPeripheral: The CBPeripheral that has modified Services.
     - parameter didModifyServices: An Array of CBService instances that were modified.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didModifyServices inInvalidatedServices: [CBService]) {
        #if DEBUG
            if 0 < inInvalidatedServices.count {
                print("Services Modified: \(inInvalidatedServices.map({ $0.uuid.uuidString }).joined(separator: ", "))")
            } else {
                print("No Services Modified.")
            }
        #endif
        
        inInvalidatedServices.forEach {
            guard let service = stagedServices[$0] ?? sequence_contents[$0]else { return }
            
            service.startOver()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the notification state for a Characteristic changes.
     
     - parameter inPeripheral: The CBPeripheral that has the modified Characteristic.
     - parameter didUpdateNotificationStateFor: The Characteristic that had its notification state changed.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didUpdateNotificationStateFor inCharacteristic: CBCharacteristic, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(.internalError(error))
        } else if let characteristic = sequence_contents.characteristic(inCharacteristic) {
            central?.updateThisCharacteristic(characteristic)
        }
    }

    /* ################################################################## */
    /**
     Called to update a Characteristic value (either in response to a read request, or a notify).
     
     - parameter inPeripheral: The CBPeripheral that has the updated Characteristic.
     - parameter didUpdateValueFor: The Characteristic instance to which the Update applies.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didUpdateValueFor inCharacteristic: CBCharacteristic, error inError: Error?) {
        #if DEBUG
            print("Received a Characteristic Update delegate callback.")
        #endif
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(String(describing: error))")
            #endif
            central?.reportError(.internalError(error))
        } else if let characteristic = sequence_contents.characteristic(inCharacteristic) {
            central?.updateThisCharacteristic(characteristic)
        }
    }

    /* ################################################################## */
    /**
     Called to update a descriptor.
     
     - parameter inPeripheral: The CBPeripheral that has the updated Descriptor.
     - parameter didUpdateValueFor: The Descriptor instance to which the Update applies.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didUpdateValueFor inDescriptor: CBDescriptor, error inError: Error?) {
        #if DEBUG
            print("Received a Descriptor Update delegate callback.")
        #endif
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(.internalError(error))
        } else if   let characteristic = sequence_contents.characteristic(inDescriptor.characteristic),
                    let descriptor = characteristic.sequence_contents[inDescriptor] {
            central?.updateThisDescriptor(descriptor)
        } else {
            #if DEBUG
                print("ERROR! Can't find Descriptor!")
            #endif
            central?.reportError(.internalError(nil))
        }
    }
    
    /* ################################################################## */
    /**
     Called to indicate that a write to the a Characteristic was successful.
     **MAJOR CAVEAT**: The <code>value</code> property of the Characteristic will not necessarily have the newly-written value.
     This method is only called to act as a semaphore to let us know that the last write attempt succeeded.
     
     - parameter inPeripheral: The CBPeripheral that has the updated Characteristic.
     - parameter didWriteValueFor: The Characteristic instance to which the write applies.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didWriteValueFor inCharacteristic: CBCharacteristic, error inError: Error?) {
// TODO: Implement this when we can test it.
//        #if DEBUG
//            print("Received a Characteristic Write delegate callback.")
//        #endif
//        if let error = inError {
//            #if DEBUG
//                print("ERROR!: \(String(describing: error))")
//            #endif
//            central?.reportError(.internalError(error))
//        } else {
//        }
    }

    /* ################################################################## */
    /**
     Called to indicate that a write to the a Descriptor was successful.
     **MAJOR CAVEAT**: The <code>value</code> property of the Descriptor will not necessarily have the newly-written value.
     This method is only called to act as a semaphore to let us know that the last write attempt succeeded.
     
     - parameter inPeripheral: The CBPeripheral that has the updated Descriptor.
     - parameter didWriteValueFor: The Descriptor instance to which the write applies.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    func peripheral(_ inPeripheral: CBPeripheral, didWriteValueFor inDescriptor: CBDescriptor, error inError: Error?) {
// TODO: Implement this when we can test it.
//        #if DEBUG
//            print("Received a Descriptor Write delegate callback.")
//        #endif
//        if let error = inError {
//            #if DEBUG
//                print("ERROR!: \(String(describing: error))")
//            #endif
//            central?.reportError(.internalError(error))
//        } else if   let characteristic = sequence_contents.characteristic(inDescriptor.characteristic),
//                    let descriptor = characteristic.sequence_contents[inDescriptor] {
//            central?.updateThisDescriptor(descriptor)
//        } else {
//            #if DEBUG
//                print("ERROR! Can't find Descriptor!")
//            #endif
//            central?.reportError(.internalError(nil))
//        }
    }
    
    /* ################################################################## */
    /**
     Called when the Peripheral is ready to listen to our advice.
     This can come some time after a failed write attempt.
     
     - parameter toSendWriteWithoutResponse: The CBPeripheral that is now ready.
     */
    func peripheralIsReady(toSendWriteWithoutResponse inPeripheral: CBPeripheral) {
// TODO: Implement this when we can test it.
//        #if DEBUG
//            print("Received a Ready to Write Message From the Peripheral \(inPeripheral.identifier.uuidString).")
//        #endif
    }
}
