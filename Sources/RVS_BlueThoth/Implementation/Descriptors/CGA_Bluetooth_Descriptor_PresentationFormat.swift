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
    /**
     These are the various formats that the data can take.
     */
    enum FormatMasks: UInt8 {
       /* ################################################################## */
       /**
         Reserved -not used.
        */
       case reserved = 0x00

      /* ################################################################## */
      /**
         Simple Boolean (1 == true, 0 == false).
       */
       case bool = 0x01

      /* ################################################################## */
      /**
         Two-bit Unsigned Int (0..<4)
       */
       case uInt2 = 0x02

      /* ################################################################## */
      /**
         Four-bit Unsigned Int (0..<16)
       */
       case uInt4 = 0x03

      /* ################################################################## */
      /**
       Eight-bit Unsigned Int (0..<256)
       */
       case uInt8 = 0x04

      /* ################################################################## */
      /**
       Twelve-bit Unsigned Int (0..<4096)
       */
       case uInt12 = 0x05

      /* ################################################################## */
      /**
       Sixteen-bit Unsigned Int (0..<32768)
       */
       case uInt16 = 0x06

      /* ################################################################## */
      /**
       Twenty-Four-bit Unsigned Int (0..<16777216)
       */
       case uInt24 = 0x07

      /* ################################################################## */
      /**
       Thirty-Two-bit Unsigned Int (0..<4294967296)
       */
       case uInt32 = 0x08

      /* ################################################################## */
      /**
       Forty-Eight-bit Unsigned Int (0..<281474976710656)
       */
       case uInt48 = 0x09

      /* ################################################################## */
      /**
       Sixty-Four-bit Unsigned Int (0..<A BIG NUMBER)
       */
       case uInt64 = 0x0A

      /* ################################################################## */
      /**
       Sixty-Four-bit Unsigned Int (0..<AN EVEN BIGGER NUMBER)
       */
       case uInt128 = 0x0B

      /* ################################################################## */
      /**
       Two-Bit Signed Integer (-1...1)
       */
       case int2 = 0x0C

      /* ################################################################## */
      /**
       Twelve-Bit Signed Integer (-2048...2047)
       */
       case int12 = 0x0D

      /* ################################################################## */
      /**
       Sixteen-Bit Signed Integer (-32768...32767)
       */
       case int16 = 0x0E

      /* ################################################################## */
      /**
       Twenty-Four-Bit Signed Integer (-8388608...8388607)
       */
       case int24 = 0x0F

      /* ################################################################## */
      /**
       Thirty-Two-Bit Signed Integer (-2147483648...2147483647)
       */
       case int32 = 0x10

      /* ################################################################## */
      /**
       Forty-Eight-Bit Signed Integer (-140737488355328...140737488355327)
       */
       case int48 = 0x11

      /* ################################################################## */
      /**
       Sixty-Four-Bit Signed Integer (A SMALL NUMBER...A BIG NUMBER)
       */
       case int64 = 0x12

      /* ################################################################## */
      /**
       One-Hunderd-Twenty-Eight-Bit Signed Integer (A SMALLER NUMBER...A BIGGER NUMBER)
       */
       case int128 = 0x13

      /* ################################################################## */
      /**
       Thirty-Two-Bit Float (IEEE 754)
       */
       case ieee754Float32 = 0x14

      /* ################################################################## */
      /**
       Sixty-Four-Bit Float
       */
       case ieee754Float64 = 0x15

      /* ################################################################## */
      /**
       Sixteen-Bit Float (IEEE 11073)
       */
       case ieee11073Float16 = 0x16

      /* ################################################################## */
      /**
       Thirty-Two-Bit Float (IEEE 11073)
       */
       case ieee11073Float32 = 0x17

      /* ################################################################## */
      /**
       Sixteen-Bit Float (IEEE 20601)
       */
       case ieee20601DUInt16 = 0x18

      /* ################################################################## */
      /**
       UTF-8 Unicode Character
       */
       case utf8 = 0x19

      /* ################################################################## */
      /**
       UTF-16 Unicode Character
       */
       case utf16 = 0x1A

      /* ################################################################## */
      /**
       Application-Defined Opaque Structure.
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
