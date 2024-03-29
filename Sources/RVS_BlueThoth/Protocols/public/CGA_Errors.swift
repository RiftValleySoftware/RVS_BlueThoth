/*
© Copyright 2020-2022, The Great Rift Valley Software Company

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
// MARK: - *Enumerations* -
/* ###################################################################################################################################### */
/**
 This enumeration defines a powerful error reporting system for the Bluetooth framework. It conforms to the standard <code>Error</code> protocol.
 */
public enum CGA_Errors: Error, Equatable {
    /* ################################################################## */
    /**
     Simple equatable. We just compare the names, and not the contents.
     */
    public static func == (lhs: CGA_Errors, rhs: CGA_Errors) -> Bool { lhs.localizedDescription == rhs.localizedDescription }
    
    /* ################################################################## */
    /**
     This indicates that the Bluetooth system is not available.
     */
    case btUnavailable
    
    /* ################################################################## */
    /**
     This indicates that the operation was not authenticated/authorized.
     */
    case unauthorized
    
    /* ################################################################## */
    /**
     This indicates that a connection attempt timed out.
     */
    case timeoutError(RVS_BlueThoth.DiscoveryData!)
    
    /* ################################################################## */
    /**
     This means that a Peripheral was unexpectedly disconnected.
     */
    case unexpectedDisconnection(String!)
    
    /* ################################################################## */
    /**
     A generic internal error.
     */
    case peripheralError(error: Error!, id: String!)
    
    /* ################################################################## */
    /**
     A generic internal error.
     */
    case serviceError(error: Error!, id: String!)
    
    /* ################################################################## */
    /**
     A generic internal error.
     */
    case characteristicError(error: Error!, id: String!)
    
    /* ################################################################## */
    /**
     A generic internal error.
     */
    case descriptorError(error: Error!, id: String!)

    /* ################################################################## */
    /**
     A generic internal error.
     */
    case internalError(error: Error!, id: String!)

    /* ################################################################## */
    /**
     Returns a localizable slug for the error. This does not include associated data.
     */
    public var localizedDescription: String {
        var ret: String = ""
        
        switch self {
        case .btUnavailable:
            ret = "CGA-ERROR-BTUNAVAILABLE"

        case .unauthorized:
            ret = "CGA-ERROR-UNAUTH"

        case .timeoutError:
            ret = "CGA-ERROR-TIMEOUT"

        case .unexpectedDisconnection:
            ret = "CGA-ERROR-DISCONNECT"

        case .peripheralError:
            ret = "CGA-ERROR-PERIPHERAL"

        case .serviceError:
            ret = "CGA-ERROR-SERVICE"

        case .characteristicError:
            ret = "CGA-ERROR-CHARACTERISTIC"

        case .descriptorError:
            ret = "CGA-ERROR-DESCRIPTOR"

        case .internalError:
            ret = "CGA-ERROR-INTERNAL"
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Returns an Array, with Strings for any nested errors.
     The last String (position count-1) is the actual Error String, and it applies to the first element (position 1).
     */
    public var layeredDescription: [String] {
        var ret: [String] = []
        
        switch self {
        case .btUnavailable,
             .unauthorized:
            ret = [localizedDescription]

        case .timeoutError(let value):
            ret = [localizedDescription]
            if let value = value?.preferredName {
                ret.append(value)
            }

        case .unexpectedDisconnection(let value):
            ret = [localizedDescription]
            if let value = value {
                ret.append(value)
            }
        
        // This allows us to have nested errors.
        case .peripheralError(let error, let id),
             .serviceError(let error, let id),
             .characteristicError(let error, let id),
             .descriptorError(let error, let id),
             .internalError(let error, let id):
            ret = [localizedDescription]
            if let id = id {
                ret.append(id)
            }
            if let error = error as? CGA_Errors {
                ret += error.layeredDescription
            } else if let error = error?.localizedDescription {
                ret.append(error)
            }
        }

        return ret
    }

    /* ################################################################## */
    /**
     This returns any associated data with the current status.
     */
    public var associatedData: Any? {
        var ret: Any! = nil
        
        switch self {
        case .btUnavailable,
             .unauthorized:
            ret = nil

        case .timeoutError(let value):
            ret = value
            
        case .unexpectedDisconnection(let value):
            ret = value
            
        case .peripheralError(let error, let id),
             .serviceError(let error, let id),
             .characteristicError(let error, let id),
             .descriptorError(let error, let id),
             .internalError(let error, let id):
            ret = (error: error, id: id)
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns an internal error, with the Peripheral that reported the error's ID.
     
     - parameters:
        - inError: The error (which may actually be a nested CGA_Errors.internalError).
        - peripheral: The CBPeripheral object that is reporting the error.
     - returns: A CGA_Errors.internalError instance, with any nesting added.
     */
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, peripheral inPeripheral: CBPeripheral) -> CGA_Errors {
        self.peripheralError(error: inError, id: inPeripheral.identifier.uuidString)
    }
    
    /* ################################################################## */
    /**
     This returns an internal error, with a nesting of the Bluetooth hierarchy that got us in this mess, and the Service's ID.
     
     - parameters:
        - inError: The error (which may actually be a nested CGA_Errors.internalError).
        - service: The CBService object that is reporting the error.
     - returns: A CGA_Errors.internalError instance, with any nesting added.
     */
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, service inService: CBService) -> CGA_Errors {
        // Let me explain what this weird-ass thing is about:
        // Apparently, in the iOS15/Monterey? world, these are now optional, but they are not, for older operating systems.
        // So we assign to an optional, then we always have an optional to unwind.
        let pripheralOptional: CBPeripheral? = inService.peripheral
        guard let peripheral = pripheralOptional else { return self.returnNestedInternalErrorBasedOnThis(inError, service: inService) }
        return self.serviceError(error: self.returnNestedInternalErrorBasedOnThis(inError, peripheral: peripheral), id: inService.uuid.uuidString)
    }
    
    /* ################################################################## */
    /**
     This returns an internal error, with a nesting of the Bluetooth hierarchy that got us in this mess, and the Characteristic's ID.
     
     - parameters:
        - inError: The error (which may actually be a nested CGA_Errors.internalError).
        - characteristic: The CBCharacteristic object that is reporting the error.
     - returns: A CGA_Errors.internalError instance, with any nesting added.
     */
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, characteristic inCharacteristic: CBCharacteristic) -> CGA_Errors {
        // Let me explain what this weird-ass thing is about:
        // Apparently, in the iOS15/Monterey? world, these are now optional, but they are not, for older operating systems.
        // So we assign to an optional, then we always have an optional to unwind.
        let serviceOptional: CBService? = inCharacteristic.service
        guard let service = serviceOptional else { return self.returnNestedInternalErrorBasedOnThis(inError, characteristic: inCharacteristic) }
        return self.characteristicError(error: self.returnNestedInternalErrorBasedOnThis(inError, service: service), id: inCharacteristic.uuid.uuidString)
    }
    
    /* ################################################################## */
    /**
     This returns an internal error, with a nesting of the Bluetooth hierarchy that got us in this mess, and the Descriptor's ID.
     
     - parameters:
        - inError: The error (which may actually be a nested CGA_Errors.internalError).
        - descriptor: The CBDescriptor object that is reporting the error.
     - returns: A CGA_Errors.internalError instance, with any nesting added.
     */
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, descriptor inDescriptor: CBDescriptor) -> CGA_Errors {
        // Let me explain what this weird-ass thing is about:
        // Apparently, in the iOS15/Monterey? world, these are now optional, but they are not, for older operating systems.
        // So we assign to an optional, then we always have an optional to unwind.
        let characteristicOptional: CBCharacteristic? = inDescriptor.characteristic
        guard let characteristic = characteristicOptional else { return self.returnNestedInternalErrorBasedOnThis(inError, descriptor: inDescriptor) }
        return self.descriptorError(error: self.returnNestedInternalErrorBasedOnThis(inError, characteristic: characteristic), id: inDescriptor.uuid.uuidString)
    }
}
