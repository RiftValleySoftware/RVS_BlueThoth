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
// MARK: - Special "Factory" Collections -
/* ###################################################################################################################################### */
/**
 These Arrays contain _class type_ instances of the classes we will use to implement the Service and Characteristic wrappers.
 
 The way this works, is that each instance conforms to the <code>CGA_ServiceFactory</code> or <code>CGA_CharacteristicFactory</code> protocol.
 
 We then cycle through the Arrays, and look for a match with the <code>uuid</code> class variable.
 If that matches, we then exercise the <code>createInstance(parent:, cbElementInstance:)</code> class function to instantiate the class.
 Since this is a polymorphic thingamuhjig, we exercise the specific subclass factory function.
 If we are writing specialization subclasses of the "generic" Service or Characteristic classes, we should add our subclasses to these Arrays.
 Yes, we could be clever, and use the uuid as a hash into a Dictionary, but we don't need to, and this allows us to put the "default" factory into the first position.
 So we have one or two extra lines, and a few milliseconds upon initial connection, when we use this. Big deal. It's all internal to this file. If it really bothers you, look away.
 */

/* ###################################################################################################################################### */
// MARK: - Factory Protocol for Service Instances -
/* ###################################################################################################################################### */
/**
 This allows a generic factory method for Service Wrappers.
 */
internal protocol CGA_ServiceFactory {
    /* ################################################################## */
    /**
     - returns: A String, with the UUID for this class' element type.
     */
    static var uuid: String { get }

    /* ################################################################## */
    /**
     REQUIRED: This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Peripheral that "owns" this Service
     - parameter cbElementInstance: The CB element for this Service.
     - returns: A new instance of CGA_Bluetooth_Service, or a subclass, thereof. Nil, if it fails.
     */
    static func createInstance(parent: CGA_Bluetooth_Peripheral, cbElementInstance: CBService) -> CGA_Bluetooth_Service?
}

/* ###################################################################################################################################### */
// MARK: - Factory Protocol for Characteristic Instances -
/* ###################################################################################################################################### */
/**
 This allows a generic factory method for Characteristic Wrappers.
 */
internal protocol CGA_CharacteristicFactory {
    /* ################################################################## */
    /**
     - returns: A String, with the UUID for this class' element type.
     */
    static var uuid: String { get }

    /* ################################################################## */
    /**
     REQUIRED: This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Service that "owns" this Characteristic
     - parameter cbElementInstance: The CB element for this Characteristic.
     - returns: A new instance of CGA_Bluetooth_Characteristic, or a subclass, thereof. Nil, if it fails.
     */
    static func createInstance(parent: CGA_Bluetooth_Service, cbElementInstance: CBCharacteristic) -> CGA_Bluetooth_Characteristic?
}

/* ###################################################################################################################################### */
// MARK: - Factory Protocol for Descriptor Instances -
/* ###################################################################################################################################### */
/**
 This allows a generic factory method for Descriptor Wrappers.
 */
internal protocol CGA_DescriptorFactory {
    /* ################################################################## */
    /**
     - returns: A String, with the UUID for this class' element type.
     */
    static var uuid: String { get }

    /* ################################################################## */
    /**
     REQUIRED: This creates an instance of the class, using the subclass-defined factory method.
     
     - parameter parent: The Characteristic that "owns" this Descriptor
     - parameter cbElementInstance: The CB element for this Descriptor.
     - returns: A new instance of CGA_Bluetooth_Descriptor, or a subclass, thereof. Nil, if it fails.
     */
    static func createInstance(parent: CGA_Bluetooth_Characteristic, cbElementInstance: CBDescriptor) -> CGA_Bluetooth_Descriptor?
}

/* ###################################################################### */
/**
 This holds references to the various subclasses for Services.
 */
private var _serviceFactory: [CGA_ServiceFactory.Type] = [
    /// Default Service
    CGA_Bluetooth_Service.self,
    
    /// Battery Level Service
    CGA_Bluetooth_Service_Battery.self,
    
    /// Current Time Service
    CGA_Bluetooth_Service_CurrentTime.self,
    
    /// Device Information Service
    CGA_Bluetooth_Service_DeviceInfo.self
]

/* ###################################################################### */
/**
 This holds references to the various subclasses for Characteristics.
 */
private var _characteristicFactory: [CGA_CharacteristicFactory.Type] = [
    /// Default Characteristic
    CGA_Bluetooth_Characteristic.self,
    
    /// Battery Level Characteristics
    CGA_Bluetooth_Characteristic_BatteryLevel.self,
    
    /// Current Time Characteristics
    CGA_Bluetooth_Characteristic_CurrentTime.self,
    CGA_Bluetooth_Characteristic_LocalTimeInformation.self,
    
    /// Device Information Characteristics
    CGA_Bluetooth_Characteristic_ManufacturerName.self,
    CGA_Bluetooth_Characteristic_ModelNumber.self,
    CGA_Bluetooth_Characteristic_SerialNumber.self,
    CGA_Bluetooth_Characteristic_HardwareRevision.self,
    CGA_Bluetooth_Characteristic_FirmwareRevision.self,
    CGA_Bluetooth_Characteristic_SoftwareRevision.self,
    CGA_Bluetooth_Characteristic_SystemID.self
]

/* ###################################################################### */
/**
 This holds references to the various subclasses for Descriptors.
 */
private var _descriptorFactory: [CGA_DescriptorFactory.Type] = [
    /// Default Descriptor
    CGA_Bluetooth_Descriptor.self,
    
    /// The Client Characteristic Configuration Descriptor
    CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration.self,
    
    /// The Characteristic Extended Properties Descriptor
    CGA_Bluetooth_Descriptor_Characteristic_Extended_Properties.self,
    
    /// The Characteristic Presentation Format Descriptor
    CGA_Bluetooth_Descriptor_PresentationFormat.self,
    
    /// The Aggregate Format Descriptor
    CGA_Bluetooth_Descriptor_AggregateFormat.self,
    
    /// The Server Characteristic Configuration Descriptor
    CGA_Bluetooth_Descriptor_ServerCharacteristicConfiguration.self,
    
    /// The L2CAP Channel PSM Descriptor.
    CGA_Bluetooth_Descriptor_CBUUIDL2CAPPSMCharacteristic.self
]

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
    public func peripheral(_ inPeripheral: CBPeripheral, didReadRSSI inRSSI: NSNumber, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, peripheral: inPeripheral))
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
    public func peripheral(_ inPeripheral: CBPeripheral, didDiscoverServices inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, peripheral: inPeripheral))
        } else {
            #if DEBUG
                if let services = inPeripheral.services {
                    print("Services Discovered: \(services.map({ $0.uuid.uuidString }).joined(separator: ", "))")
                } else {
                    print("ERROR!")
                    central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(nil, peripheral: inPeripheral))
                }
            #endif
            
            stagedServices = inPeripheral.services?.compactMap { (service) in
                var serviceToAdd: CGA_Bluetooth_Service!
                for serviceInstance in _serviceFactory where nil == serviceToAdd && service.uuid.uuidString == serviceInstance.uuid {
                    serviceToAdd = serviceInstance.createInstance(parent: self, cbElementInstance: service)
                }
                
                // If none of the specialized ones worked out, we use the first one (which is always the generic one).
                if nil == serviceToAdd {
                    serviceToAdd = _serviceFactory[0].createInstance(parent: self, cbElementInstance: service)
                }
                
                #if DEBUG
                    print("Staging the \(serviceToAdd.id) Service for the \(id) Peripheral.")
                #endif

                return serviceToAdd
            } ?? []
            
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
    public func peripheral(_ inPeripheral: CBPeripheral, didDiscoverCharacteristicsFor inService: CBService, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, service: inService))
        } else {
            guard let characteristics = inService.characteristics else {
                #if DEBUG
                    print("ERROR! The characteristics Array is nil!")
                #endif
                central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(nil, service: inService))
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
                central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(nil, service: inService))
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
    public func peripheral(_ inPeripheral: CBPeripheral, didDiscoverDescriptorsFor inCharacteristic: CBCharacteristic, error inError: Error?) {
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription)")
            #endif
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, characteristic: inCharacteristic))
        } else {
            guard let descriptors = inCharacteristic.descriptors else {
                #if DEBUG
                    print("ERROR! The descriptors Array is nil!")
                #endif
                central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(nil, characteristic: inCharacteristic))
                return
            }
            
            #if DEBUG
                print("Characteristic: \(inCharacteristic.uuid.uuidString) discovered these Descriptors: \(descriptors.map { $0.uuid.uuidString }.joined(separator: ", "))")
            #endif
            
            if  let service = (stagedServices[inCharacteristic] ?? sequence_contents[inCharacteristic]) {
                var characteristicToAdd: CGA_Bluetooth_Characteristic!
                for characteristicInstance in _characteristicFactory where nil == characteristicToAdd && inCharacteristic.uuid.uuidString == characteristicInstance.uuid {
                    characteristicToAdd = characteristicInstance.createInstance(parent: service, cbElementInstance: inCharacteristic)
                }
                
                // If none of the specialized ones worked out, we use the first one (which is always the generic one).
                if nil == characteristicToAdd {
                    characteristicToAdd = _characteristicFactory[0].createInstance(parent: service, cbElementInstance: inCharacteristic)
                }

                // We now add any Descriptors that are associated with this Characteristic.
                if nil != characteristicToAdd {
                    descriptors.forEach {
                        var descriptorToAdd: CGA_Bluetooth_Descriptor!
                        for descriptorInstance in _descriptorFactory where nil == descriptorToAdd && $0.uuid.uuidString == descriptorInstance.uuid {
                            descriptorToAdd = descriptorInstance.createInstance(parent: characteristicToAdd, cbElementInstance: $0)
                        }
                        
                        if nil == descriptorToAdd {
                            descriptorToAdd = _descriptorFactory[0].createInstance(parent: characteristicToAdd, cbElementInstance: $0)
                        }
                        
                        if nil != descriptorToAdd {
                            characteristicToAdd.addDescriptor(descriptorToAdd)
                        }
                    }
                }
                
                #if DEBUG
                    print("All Descriptors fulfilled. Adding this Characteristic: \(characteristicToAdd.id) to this Service: \(service.id)")
                #endif
                service.addCharacteristic(characteristicToAdd)
            } else {
                #if DEBUG
                    print("ERROR! There is no Service for this Characteristic: \(inCharacteristic.uuid.uuidString)")
                #endif
                central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(nil, characteristic: inCharacteristic))
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when any Services have been modified.
     
     - parameter inPeripheral: The CBPeripheral that has modified Services.
     - parameter didModifyServices: An Array of CBService instances that were modified.
     */
    public func peripheral(_ inPeripheral: CBPeripheral, didModifyServices inInvalidatedServices: [CBService]) {
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
    public func peripheral(_ inPeripheral: CBPeripheral, didUpdateNotificationStateFor inCharacteristic: CBCharacteristic, error inError: Error?) {
        #if DEBUG
            print("Received a Characteristic Notification State Update delegate callback for the \(inCharacteristic.uuid.uuidString) Characteristic.")
        #endif
        guard let error = inError else {
            if let characteristic = sequence_contents.characteristic(inCharacteristic) {
                central?.updateThisCharacteristicNotificationState(characteristic)
            }
            return
        }
        
        #if DEBUG
            print("ERROR!: \(error.localizedDescription) for Characteristic \(inCharacteristic.uuid.uuidString)")
        #endif
        central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, characteristic: inCharacteristic))
    }

    /* ################################################################## */
    /**
     Called to update a Characteristic value (either in response to a read request, or a notify).
     
     - parameter inPeripheral: The CBPeripheral that has the updated Characteristic.
     - parameter didUpdateValueFor: The Characteristic instance to which the Update applies.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    public func peripheral(_ inPeripheral: CBPeripheral, didUpdateValueFor inCharacteristic: CBCharacteristic, error inError: Error?) {
        #if DEBUG
            print("Received a Characteristic Update delegate callback for the \(inCharacteristic.uuid.uuidString) Characteristic.")
        #endif
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(String(describing: error)) for Characteristic \(inCharacteristic.uuid.uuidString)")
            #endif
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, characteristic: inCharacteristic))
        } else if let characteristic = sequence_contents.characteristic(inCharacteristic) {
            #if DEBUG
                if  let stringVal = characteristic.stringValue {
                    print("Updating the \(characteristic.id) Characteristic, which currently has the value: \"\(stringVal)\"")
                } else {
                    print("Updating the \(characteristic.id) Characteristic, which currently has the value: \(String(describing: characteristic.value))")
                }
            #endif
            // If we are concatenating data, we simply slap this onto the end of what we already have.
            if  nil != characteristic._value,
                characteristic.concatenateValue,
                let data = inCharacteristic.value {
                #if DEBUG
                    if let stringValue = String(data: data, encoding: .utf8) {
                        print("Appending String Data: \"\(stringValue)\" to Characteristic \(inCharacteristic.uuid.uuidString)")
                    } else {
                        print("Appending Data: \(String(describing: characteristic.value)) to Characteristic \(inCharacteristic.uuid.uuidString)")
                    }
                #endif
                characteristic._value?.append(data)
            } else {
                #if DEBUG
                    print("Starting new data for Characteristic \(inCharacteristic.uuid.uuidString)")
                    if  let data = inCharacteristic.value,
                        let stringValue = String(data: data, encoding: .utf8) {
                        print("Starting new String Data: \"\(stringValue)\" for Characteristic \(inCharacteristic.uuid.uuidString)")
                    } else {
                        print("Starting new Data: \(String(describing: inCharacteristic.value)) for Characteristic \(inCharacteristic.uuid.uuidString)")
                    }
                #endif
                characteristic._value = inCharacteristic.value
            }
        }
    }

    /* ################################################################## */
    /**
     Called to update a descriptor.
     
     - parameter inPeripheral: The CBPeripheral that has the updated Descriptor.
     - parameter didUpdateValueFor: The Descriptor instance to which the Update applies.
     - parameter error: Any error that may have occured. Hopefully, it is nil.
     */
    public func peripheral(_ inPeripheral: CBPeripheral, didUpdateValueFor inDescriptor: CBDescriptor, error inError: Error?) {
        #if DEBUG
            print("Received a Characteristic Update delegate callback for the \(inDescriptor.uuid.uuidString) Descriptor.")
        #endif
        // Let me explain what this weird-ass thing is about:
        // Apparently, in the iOS15/Monterey? world, these are now optional, but they are not, for older operating systems.
        // So we assign to an optional, then we always have an optional to unwind.
        let charOptional: CBCharacteristic? = inDescriptor.characteristic
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(error.localizedDescription) for Descriptor \(inDescriptor.uuid.uuidString)")
            #endif
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(error, descriptor: inDescriptor))
        } else if   let charTemp: CBCharacteristic = charOptional,
                    let characteristic = sequence_contents.characteristic(charTemp),
                    let descriptor = characteristic.sequence_contents[inDescriptor] as? CGA_Bluetooth_Descriptor {
            #if DEBUG
                print("Updated the \(descriptor.id) Descriptor value: \(String(describing: descriptor.value))")
                if  let stringVal = descriptor.stringValue,
                    !stringVal.isEmpty {
                    print("\tAs String: \(stringVal)")
                }
            #endif
            central?.updateThisDescriptor(descriptor)
        } else {
            #if DEBUG
                print("ERROR! Can't find Descriptor!")
            #endif
            central?.reportError(CGA_Errors.returnNestedInternalErrorBasedOnThis(nil, descriptor: inDescriptor))
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
    public func peripheral(_ inPeripheral: CBPeripheral, didWriteValueFor inCharacteristic: CBCharacteristic, error inError: Error?) {
        #if DEBUG
            print("Received a Characteristic Write delegate callback.")
        #endif
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(String(describing: error))")
            #endif
            central?.reportError(.internalError(error: error, id: id))
        } else if let characteristic = sequence_contents.characteristic(inCharacteristic) {
            central?.reportWriteCompleteForThisCharacteristic(characteristic)
        }
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
    public func peripheral(_ inPeripheral: CBPeripheral, didWriteValueFor inDescriptor: CBDescriptor, error inError: Error?) {
        #if DEBUG
            print("Received a Descriptor Write delegate callback.")
        #endif
        // Let me explain what this weird-ass thing is about:
        // Apparently, in the iOS15/Monterey? world, these are now optional, but they are not, for older operating systems.
        // So we assign to an optional, then we always have an optional to unwind.
        let charTempOptional: CBCharacteristic? = inDescriptor.characteristic
        if let error = inError {
            #if DEBUG
                print("ERROR!: \(String(describing: error))")
            #endif
            central?.reportError(.internalError(error: error, id: id))
        } else if   let charTemp = charTempOptional,
                    let characteristic = sequence_contents.characteristic(charTemp),
                    let descriptor = characteristic.sequence_contents[inDescriptor] as? CGA_Bluetooth_Descriptor {
            central?.updateThisDescriptor(descriptor)
        } else {
            #if DEBUG
                print("ERROR! Can't find Descriptor!")
            #endif
            central?.reportError(.internalError(error: nil, id: id))
        }
    }
    
    /* ################################################################## */
    /**
     Called when the Peripheral is ready to listen to our advice.
     This can come some time after a failed write attempt.
     
     - parameter toSendWriteWithoutResponse: The CBPeripheral that is now ready.
     */
    public func peripheralIsReady(toSendWriteWithoutResponse inPeripheral: CBPeripheral) {
        #if DEBUG
            print("Received a Ready to Write Message From the Peripheral \(inPeripheral.identifier.uuidString).")
        #endif
        guard let peripheral = central?.sequence_contents[inPeripheral],
                peripheral.cbElementInstance == inPeripheral else { return }
        
        central?.sendDeviceReadyForWrite(peripheral)
    }
}
