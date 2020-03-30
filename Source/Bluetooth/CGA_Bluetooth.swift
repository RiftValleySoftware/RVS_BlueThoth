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
// MARK: - The Main Protocol for Each Type -
/* ###################################################################################################################################### */
/**
 */
protocol CGA_Class_Protocol: class, RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Class_Protocol
     */
    var parent: Any? { get set }
    
    /* ################################################################## */
    /**
     REQUIRED: This is called to tell the instance to do whatever it needs to do to handle an error.
     
     - parameter error: The error to be handled.
     */
    func handleError(_ error: Error)
    
    /* ################################################################## */
    /**
     OPTIONAL: This is called to tell the instance to do whatever it needs to do to update its collection.
     */
    func updateCollection()
}

/* ###################################################################################################################################### */
// MARK: - Defaults
/* ###################################################################################################################################### */
/**
 This is here, only so we don't need to declare it in the base class, and do overrides.
 */
extension CGA_Class_Protocol {
    /* ################################################################## */
    /**
     The default implementation does nothing.
     */
    func updateCollection() { }
}

/* ###################################################################################################################################### */
// MARK: - The Base Class for the Two Types of Central Manager -
/* ###################################################################################################################################### */
/**
 This provides common functionality to be used by each of the subclasses.
 */
class CGA_Bluetooth_CentralManager_Base_Class: NSObject {
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Class_Protocol
     */
    var parent: Any?

    /* ################################################################## */
    /**
     This holds the instance of CBCentralManager that is used by this instance.
     */
    var centralManagerInstance: CBCentralManager!
    
    /* ################################################################## */
    /**
     We aggregate Peripherals.
     */
    typealias Element = CGA_Bluetooth_Peripheral
    
    /* ################################################################## */
    /**
     This holds our cached Array of Peripheral instances.
     */
    var sequence_contents: Array<Element>
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequenceContents: [Element]) {
        sequence_contents = inSequenceContents
        super.init()    // Since we derive from NSObject, we must call the super init()
        #if targetEnvironment(simulator)
            centralManagerDidUpdateState(CBCentralManager())
        #endif
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
    
    /* ################################################################## */
    /**
     */
    func handlePoweredOn() {
        updateCollection()
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
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_Bluetooth_CentralManager_Base_Class: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     */
    func centralManagerDidUpdateState(_ inCentralManager: CBCentralManager) {
        switch inCentralManager.state {
        case .poweredOn:
            handlePoweredOn()
            
        default:
            #if targetEnvironment(simulator)
                handlePoweredOn()
            #else
                break
            #endif
        }
    }
}
