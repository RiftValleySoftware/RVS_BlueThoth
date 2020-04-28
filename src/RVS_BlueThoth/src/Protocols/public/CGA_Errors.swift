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
// MARK: - *Enumerations* -
/* ###################################################################################################################################### */
public enum CGA_Errors: Error {
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
    case internalError(error: Error!, id: String!)

    /* ################################################################## */
    /**
     Returns a localizable slug for the error. This does not include associated data.
     */
    public var localizedDescription: String {
        var ret: String = ""
        
        switch self {
        case .timeoutError:
            ret = "CGA-ERROR-TIMEOUT"

        case .unexpectedDisconnection:
            ret = "CGA-ERROR-DISCONNECT"

        case .internalError:
            ret = "CGA-ERROR-INTERNAL"
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Returns an Array, with Strings for any nested errors.
     */
    public var layeredDescription: [String] {
        var ret: [String] = []
        
        switch self {
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
        case .internalError(let error, let id):
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
        case .timeoutError(let value):
            ret = value
            
        case .unexpectedDisconnection(let value):
            ret = value
            
        case let .internalError(error, id):
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
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, peripheral inPeripheral: CBPeripheral) -> CGA_Errors { self.internalError(error: inError, id: inPeripheral.identifier.uuidString) }
    
    /* ################################################################## */
    /**
     This returns an internal error, with a nesting of the Bluetooth hierarchy that got us in this mess, and the Service's ID.
     
     - parameters:
        - inError: The error (which may actually be a nested CGA_Errors.internalError).
        - service: The CBService object that is reporting the error.
     - returns: A CGA_Errors.internalError instance, with any nesting added.
     */
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, service inService: CBService) -> CGA_Errors { self.internalError(error: self.returnNestedInternalErrorBasedOnThis(inError, peripheral: inService.peripheral), id: inService.uuid.uuidString) }
    
    /* ################################################################## */
    /**
     This returns an internal error, with a nesting of the Bluetooth hierarchy that got us in this mess, and the Characteristic's ID.
     
     - parameters:
        - inError: The error (which may actually be a nested CGA_Errors.internalError).
        - characteristic: The CBCharacteristic object that is reporting the error.
     - returns: A CGA_Errors.internalError instance, with any nesting added.
     */
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, characteristic inCharacteristic: CBCharacteristic) -> CGA_Errors { self.internalError(error: self.returnNestedInternalErrorBasedOnThis(inError, service: inCharacteristic.service), id: inCharacteristic.uuid.uuidString) }
    
    /* ################################################################## */
    /**
     This returns an internal error, with a nesting of the Bluetooth hierarchy that got us in this mess, and the Descriptor's ID.
     
     - parameters:
        - inError: The error (which may actually be a nested CGA_Errors.internalError).
        - descriptor: The CBDescriptor object that is reporting the error.
     - returns: A CGA_Errors.internalError instance, with any nesting added.
     */
    public static func returnNestedInternalErrorBasedOnThis(_ inError: Error?, descriptor inDescriptor: CBDescriptor) -> CGA_Errors { self.internalError(error: self.returnNestedInternalErrorBasedOnThis(inError, characteristic: inDescriptor.characteristic), id: inDescriptor.uuid.uuidString) }
}
