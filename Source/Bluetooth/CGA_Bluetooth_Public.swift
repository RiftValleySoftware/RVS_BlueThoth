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
/**
 These are all classes, as opposed to structs, because we want them to be referenced, not copied.
 Remember that Bluetooth is a very dynamic, realtime environment. Caches can be extremely problematic. We want caches, but safe ones.
 Also, the Central and Peripheral classes need to derive from NSObject, so they can be delegates.
 */

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
protocol CGA_Class_Protocol: class {
    /* ################################################################## */
    /**
     */
    func handleError(_ error: Error)
    
    /* ################################################################## */
    /**
     */
    func updateCollection()
}

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
    var centralManagerInstance: CBCentralManager!
    
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
        centralManagerInstance = CBCentralManager(delegate: self, queue: inQueue)
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_CentralManager_Base_Class: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     */
    func handleError(_ inError: Error) {
        
    }
    
    /* ################################################################## */
    /**
     */
    func updateCollection() {
        
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
class CGA_Bluetooth_Peripheral: NSObject, RVS_SequenceProtocol {
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
extension CGA_Bluetooth_Peripheral: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     */
    func handleError(_ inError: Error) {
        
    }
    
    /* ################################################################## */
    /**
     */
    func updateCollection() {
        
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_Peripheral: CBPeripheralDelegate {
    
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
extension CGA_Bluetooth_Service: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     */
    func handleError(_ inError: Error) {
        
    }
    
    /* ################################################################## */
    /**
     */
    func updateCollection() {
        
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
extension CGA_Bluetooth_Characteristic: CGA_Class_Protocol {
    /* ################################################################## */
    /**
     */
    func handleError(_ inError: Error) {
        
    }
    
    /* ################################################################## */
    /**
     */
    func updateCollection() {
        
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_Bluetooth_Descriptor {
}
