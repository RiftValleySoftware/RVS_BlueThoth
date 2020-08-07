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
// MARK: - The Wrapper Class for the Client Characteristic Configuration Descriptor -
/* ###################################################################################################################################### */
/**
 This class "wraps" instances of The User Description CBDescriptor.
 */
public class CGA_Bluetooth_Descriptor_PresentationFormat: CGA_Bluetooth_Descriptor {
    /* ################################################################################################################################## */
    // MARK: - Descriptor Values -
    /* ################################################################################################################################## */
    enum FormatMasks: UInt8 {
       /* ################################################################## */
       /**
        */
       case reserved = 0x00

      /* ################################################################## */
      /**
       */
       case bool = 0x01

      /* ################################################################## */
      /**
       */
       case uInt2 = 0x02

      /* ################################################################## */
      /**
       */
       case uInt4 = 0x03

      /* ################################################################## */
      /**
       */
       case uInt8 = 0x04

      /* ################################################################## */
      /**
       */
       case uInt12 = 0x05

      /* ################################################################## */
      /**
       */
       case uInt16 = 0x06

      /* ################################################################## */
      /**
       */
       case uInt24 = 0x07

      /* ################################################################## */
      /**
       */
       case uInt32 = 0x08

      /* ################################################################## */
      /**
       */
       case uInt48 = 0x09

      /* ################################################################## */
      /**
       */
       case uInt64 = 0x0A

      /* ################################################################## */
      /**
       */
       case uInt128 = 0x0B

      /* ################################################################## */
      /**
       */
       case int2 = 0x0C

      /* ################################################################## */
      /**
       */
       case int12 = 0x0D

      /* ################################################################## */
      /**
       */
       case int16 = 0x0E

      /* ################################################################## */
      /**
       */
       case int24 = 0x0F

      /* ################################################################## */
      /**
       */
       case int32 = 0x10

      /* ################################################################## */
      /**
       */
       case int48 = 0x11

      /* ################################################################## */
      /**
       */
       case int64 = 0x12

      /* ################################################################## */
      /**
       */
       case int128 = 0x13

      /* ################################################################## */
      /**
       */
       case ieee754Float32 = 0x14

      /* ################################################################## */
      /**
       */
       case ieee754Float64 = 0x15

      /* ################################################################## */
      /**
       */
       case ieee11073Float16 = 0x16

      /* ################################################################## */
      /**
       */
       case ieee11073Float32 = 0x17

      /* ################################################################## */
      /**
       */
       case ieee20601DUInt16 = 0x18

      /* ################################################################## */
      /**
       */
       case utf8 = 0x19

      /* ################################################################## */
      /**
       */
       case utf16 = 0x1A

      /* ################################################################## */
      /**
       */
       case opaqueStruct = 0x1B
    }

    /* ################################################################## */
    /**
     - returns: The Characteristic Presentation Format, as a positive integer String. If not available, is nil.
     */
    public override var stringValue: String? {
        guard let intValue = uInt8Value else { return nil }
        return String(format: "%d", intValue)
    }
    
    /* ################################################################## */
    /**
     This is the UUID for the User Description Descriptor.
     */
    internal class override var uuid: String { CBUUIDCharacteristicFormatString }
}
