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
import RVS_Generic_Swift_Toolbox

/* ###################################################################################################################################### */
// MARK: - The Public Face of Characteristics -
/* ###################################################################################################################################### */
/**
 This protocol publishes a public interface for our Characteristic wrapper classes.
 */
public protocol CGA_Bluetooth_Characteristic_Protocol: AnyObject, RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This returns a unique UUID String for the instance.
     */
    var id: String { get }
    
    /* ################################################################## */
    /**
     If the Characteristic has a value, it is returned here. It is a standard Data type.
     */
    var value: Data? { get }
    
    /* ################################################################## */
    /**
     This holds the instance of CBDescriptor that is used by this instance.
     */
    var cbElementInstance: CBCharacteristic! { get }
    
    /* ################################################################## */
    /**
     This casts the parent as a Service Wrapper.
     */
    var service: CGA_Bluetooth_Service! { get }

    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write (eithe with or without response).
     */
    var canWrite: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write, and returns a receipt response.
     */
    var canWriteWithResponse: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can write, and does not return a response.
     */
    var canWriteWithoutResponse: Bool { get }

    /* ################################################################## */
    /**
     Returns true, if the Characteristic can be read.
     */
    var canRead: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can notify.
     */
    var canNotify: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can broadcast.
     */
    var canBroadcast: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic can indicate.
     */
    var canIndicate: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic is currently notifying.
     */
    var isNotifying: Bool { get }

    /* ################################################################## */
    /**
     Returns the maximum number of bytes that can be written for this Peripheral.
     */
    var maximumWriteLength: Int { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires authenticated writes.
     */
    var requiresAuthenticatedSignedWrites: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires encrypted notification.
     */
    var requiresNotifyEncryption: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic requires encrypted indicates.
     */
    var requiresIndicateEncryption: Bool { get }
    
    /* ################################################################## */
    /**
     Returns true, if the Characteristic has extension properties.
     */
    var hasExtendedProperties: Bool { get }
    
    /* ################################################################## */
    /**
     This will return any extension properties, as a simple tuple, or nil, if there are none.
     */
    var extendedProperties: (isReliableWriteEnabled: Bool, isWritableAuxiliariesEnabled: Bool)? { get }

    /* ################################################################## */
    /**
     The Peripheral is asked to read the value.
     */
    func readValue()
}
