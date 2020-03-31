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
class CGA_Bluetooth_Service: RVS_SequenceProtocol {
    /* ################################################################## */
    /**
     This is the type we're aggregating.
     */
    typealias Element = CGA_Bluetooth_Characteristic
    
    /* ################################################################## */
    /**
     This is our main cache Array. It contains wrapped instances of our aggregate CB type.
     */
    var sequence_contents: Array<Element> = []
    
    /* ################################################################## */
    /**
     This is used to reference an "owning instance" of this instance, and it should be a CGA_Class_Protocol
     */
    var parent: CGA_Class_Protocol?

    /* ################################################################## */
    /**
     This holds the instance of CBService that is used by this instance.
     */
    var cbElementInstance: CBService!
    
    /* ################################################################## */
    /**
     The required init, with a "primed" sequence.
     
     - parameter sequence_contents: The initial value of the Array cache.
     */
    required init(sequence_contents inSequence_Contents: [Element]) {
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
    func updateCollection() {
        #if targetEnvironment(simulator)
            #if DEBUG
                print("Generating Mocks for the Service")
            #endif
        #else
        #endif
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Services Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Services, looking for an exact instance.
 */
extension Array where Element == CGA_Bluetooth_Service {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its conatined Service
     
     - parameter inItem: The CBService we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBService) -> Element! {
        return reduce(nil) { (current, nextItem) in
            return nil == current ? (nextItem.cbElementInstance.uuid == inItem.uuid ? nextItem : nil) : current
        }
    }
    
    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBService) -> Bool {
        return nil != self[inItem]
    }
}
