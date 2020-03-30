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
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_CentralManager_Base_Class: NSObject, RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This holds the instance of CBCentralManager that is used by this instance.
     */
    fileprivate var _centralManagerInstance: CBCentralManager!
    
    /* ################################################################## */
    /**
     */
    typealias Element = CGA_Bluetooth_Peripheral
    
    /* ################################################################## */
    /**
     */
    var sequence_contents: Array<Element>
    
    /* ################################################################## */
    /**
     */
    required init(sequence_contents inSequenceContents: [Element]) {
        sequence_contents = inSequenceContents
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_CentralManager_Base_Class {
    /* ################################################################## */
    /**
     */
    convenience init(queue inQueue: DispatchQueue? = nil) {
        self.init(sequence_contents: [])
        _centralManagerInstance = CBCentralManager(delegate: self, queue: inQueue)
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_CentralManager_Base_Class: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ inCentralManager: CBCentralManager) {
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_CentralManager_BLE: CGA_Bluetooth_CentralManager_Base_Class {
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_CentralManager_Classic: CGA_Bluetooth_CentralManager_Base_Class {
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_Peripheral: RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     */
    typealias Element = CGA_Bluetooth_Service
    
    /* ################################################################## */
    /**
     */
    var sequence_contents: Array<Element>
    
    /* ################################################################## */
    /**
     */
    required init(sequence_contents inSequence_Contents: [Element] = []) {
        sequence_contents = inSequence_Contents
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_Service: RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     */
    typealias Element = CGA_Bluetooth_Characteristic
    
    /* ################################################################## */
    /**
     */
    var sequence_contents: Array<Element>
    
    /* ################################################################## */
    /**
     */
    required init(sequence_contents inSequence_Contents: [Element] = []) {
        sequence_contents = inSequence_Contents
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_Characteristic: RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     */
    typealias Element = CGA_Bluetooth_Descriptor
    
    /* ################################################################## */
    /**
     */
    var sequence_contents: Array<Element>
    
    /* ################################################################## */
    /**
     */
    required init(sequence_contents inSequence_Contents: [Element] = []) {
        sequence_contents = inSequence_Contents
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_Descriptor {
}
