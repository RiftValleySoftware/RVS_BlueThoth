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

/* ###################################################################################################################################### */
// MARK: - *Enumerations* -
/* ###################################################################################################################################### */
public enum CGA_Errors: Error {
    /* ################################################################## */
    /**
     This indicates that a connection attempt timed out.
     */
    case timeoutError(CGA_Bluetooth_CentralManager.DiscoveryData!)
    
    /* ################################################################## */
    /**
     A generic internal error.
     */
    case internalError(Error!)

    /* ################################################################## */
    /**
     Returns a localizable slug for the error. This does not include associated data.
     */
    var localizedDescription: String {
        var ret: String = ""
        
        switch self {
        case .timeoutError:
            ret = "CGA-ERROR-TIMEOUT"

        case .internalError:
            ret = "CGA-ERROR-INTERNAL"
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Returns an Array, with Strings for any nested errors.
     */
    var layeredDescription: [String] {
        var ret: [String] = []
        
        switch self {
        case .timeoutError:
            ret = [localizedDescription]
            
        case .internalError:
            ret = [localizedDescription]
        }
        
        return ret
    }

    /* ################################################################## */
    /**
     This returns any associated data with the current status.
     */
    var associatedData: Any? {
        var ret: Any! = nil
        
        switch self {
        case .timeoutError(let value):
            ret = value
            
        case .internalError(let value):
            ret = value
        }
        
        return ret
    }
}
