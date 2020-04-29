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
// MARK: - Special Comparator for the Peripherals Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Peripherals in our staged Arrays, looking for an exact instance.
 */
public extension Array where Element == RVS_BlueThoth.DiscoveryData {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Peripheral (as the opaque type).
     
     - parameter inItem: The Peripheral we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: Element) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return (nextItem === inItem) || nextItem.identifier == inItem.identifier ? nextItem : nil }

            return current
        }
    }
    
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Peripheral
     
     - parameter inItem: The Peripheral we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBPeripheral) -> Element! {
        reduce(nil) { (current, nextItem) in
            if  nil == current {
                if nextItem === inItem {
                    return nextItem
                } else if nextItem.cbPeripheral.identifier == inItem.identifier {
                    return nextItem
                }
               
                return nil
            }
            
            return current
        }
    }

    /* ################################################################## */
    /**
     Removes the element (as the opaque type).
     
     - parameter inItem: The CB element we're looking to remove, as the opaque type.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisDevice(_ inItem: Element) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            if test === inItem {
                success = true
                return true
            } else if test.identifier == inItem.identifier {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element (as the opaque type).
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: Element) -> Bool { nil != self[inItem] }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBPeripheral) -> Bool { nil != self[inItem] }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Peripherals Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Peripherals, looking for an exact instance.
 */
public extension Array where Element == CGA_Bluetooth_Peripheral {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its UUID
     
     - parameter inItem: The UUID of the item we want
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBUUID) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return nextItem.cbElementInstance.identifier.uuidString == inItem.uuidString ? nextItem : nil }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Peripheral
     
     - parameter inItem: The Peripheral we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBPeripheral) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return (nextItem === inItem) || nextItem.cbElementInstance.identifier == inItem.identifier ? nextItem : nil }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     Method that allows us to retrieve an Element by its contained Characteristic
     
     - parameter inItem: The Characteristic that belongs to the element that we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    func characteristic(_ inItem: CBCharacteristic) -> CGA_Bluetooth_Characteristic! { reduce(nil) { (current, next) in nil == current ? next.sequence_contents.characteristic(inItem) : current } }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBPeripheral) -> Bool { nil != self[inItem] }
    
    /* ################################################################## */
    /**
     Removes the element (as a CBPeripheral).
     
     - parameter inItem: The CB element we're looking to remove, as the opaque type.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisDevice(_ inItem: CBPeripheral) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            guard let testPeripheral = test.discoveryData?.cbPeripheral else { return false }
            if testPeripheral === inItem {
                success = true
                return true
            } else if testPeripheral.identifier.uuidString == inItem.identifier.uuidString {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }
    
    /* ################################################################## */
    /**
     Returns the first index of the submitted Peripheral warapper.
     
     - parameter inPeripheral: The Peripheral to find.
     */
    func indexOf(_ inPeripheral: CGA_Bluetooth_Peripheral) -> Int { firstIndex { return $0.cbElementInstance.identifier.uuidString == inPeripheral.id } ?? -1 }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Characteristics Array (as an Array of CBCharacteristic) -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Characteristics, looking for an exact instance.
 
 This is applied to the sequence_contentnts Array. It allows us to search by UUID, as well as by identity.
 */
public extension Array where Element == CBCharacteristic {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its UUID
     
     - parameter inItem: The UUID of the item we want
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBUUID) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return nextItem.uuid.uuidString == inItem.uuidString ? nextItem : nil }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Characteristic.
     
     - parameter inItem: The CBCharacteristic we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBCharacteristic) -> Element! { reduce(nil) { (current, nextItem) in nil != current ? current : ((nextItem === inItem || nextItem.uuid == inItem.uuid) ? nextItem : nil) } }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Characteristics Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Characteristics, looking for an exact instance.
 */
public extension Array where Element == CGA_Bluetooth_Characteristic {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its UUID
     
     - parameter inItem: The UUID of the item we want
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBUUID) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return nextItem.cbElementInstance.uuid.uuidString == inItem.uuidString ? nextItem : nil }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Characteristic.
     
     - parameter inItem: The CBCharacteristic we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBCharacteristic) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return (nextItem === inItem) || nextItem.cbElementInstance.uuid.uuidString == inItem.uuid.uuidString ? nextItem : nil }

            return current
        }
    }
    
    /* ################################################################## */
    /**
     Removes the element (as a CBCharacteristic).
     
     - parameter inItem: The CB element we're looking to remove.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisCharacteristic(_ inItem: CBCharacteristic) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            guard let testCharacteristic = test.cbElementInstance else { return false }
            if testCharacteristic === inItem {
                success = true
                return true
            } else if testCharacteristic.uuid.uuidString == inItem.uuid.uuidString {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }

    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBCharacteristic) -> Bool { nil != self[inItem] }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Descriptor Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Descriptors, looking for an exact instance.
 */
public extension Array where Element == CGA_Bluetooth_Descriptor_Protocol {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its UUID
     
     - parameter inItem: The UUID of the item we want
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBUUID) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return nextItem.cbElementInstance.uuid.uuidString == inItem.uuidString ? nextItem : nil }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Descriptor.
     
     - parameter inItem: The CBDescriptor we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBDescriptor) -> Element! {
        reduce(nil) { (current, nextItem) in
            guard let current = current else { return (nextItem === inItem) || nextItem.cbElementInstance.uuid.uuidString == inItem.uuid.uuidString ? nextItem : nil }

            return current
        }
    }
    
    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBDescriptor) -> Bool { nil != self[inItem] }
}

/* ###################################################################################################################################### */
// MARK: - Data Extension -
/* ###################################################################################################################################### */
/**
 This extension adds the ability to extract data from a Data instance, cast into various types.
 */
public extension Data {
    /* ################################################################## */
    /**
     This method allows a Data instance to be cast into various standard types.
     
     **NOTE** This is not a "safe" method! It circumvents Swift's safety bumpers, and could get you in trouble if you don't use trivial types!
     
     - parameter inValue: This is an inout parameter, and the type will be used to determine the cast.
     - parameter offsetInBytes: The number of bytes "into" the data we will go to perform the interpretation. This is an unsigned, 0-based integer. Default is 0 (can be ignored).
     - returns: The number of bytes read. Can be ignored.
     */
    @discardableResult
    mutating func castInto<T>(_ inValue: inout T, offsetInBytes inOffsetInBytes: UInt = 0) -> Int {
        // Makes sure that we don't try to read past the end of the data.
        let endPoint = Swift.max(0, Swift.min(MemoryLayout<T>.size, count - Int(inOffsetInBytes))) + Int(inOffsetInBytes)
        let len = endPoint - Int(inOffsetInBytes)
        guard 0 < len else { return 0 }   // We cannot go past the end.
        _ = Swift.withUnsafeMutableBytes(of: &inValue) {
            self.copyBytes(to: $0, from: Int(inOffsetInBytes)..<endPoint)
        }
        
        return len
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Services Array -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Services, looking for an exact instance.
 */
public extension Array where Element == CGA_Bluetooth_Service {
    /* ################################################################## */
    /**
     Special subscript that allows us to retrieve an Element by its contained Service
     
     - parameter inItem: The CBService we're looking to match.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBService) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                if nextItem === inItem {
                    return nextItem
                } else if nextItem.cbElementInstance.uuid == inItem.uuid {
                    return nextItem
                }
                    
                return nil
            }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     This subscript goes through our Services, looking for the one that "owns" the proferred Characteristic.
     
     - parameter inItem: The CBCharacteristic that the Service will aggregate.
     - returns: The found Element, or nil, if not found.
     */
    subscript(_ inItem: CBCharacteristic) -> Element! {
        return reduce(nil) { (current, nextItem) in
            if  nil == current {
                return (nil != nextItem.cbElementInstance?.characteristics?[inItem]) ? nextItem : nil
            }
            
            return current
        }
    }
    
    /* ################################################################## */
    /**
     This method goes through the Services, looking for the one that "owns" the proferred Characteristic, and then returning the "wrapper" for the Characteristic.
     
     - parameter inItem: The CBCharacteristic that the Service will aggregate.
     - returns: The found Element, or nil, if not found.
     */
    func characteristic(_ inItem: CBCharacteristic) -> CGA_Bluetooth_Characteristic! {
        guard let service: CGA_Bluetooth_Service = self[inItem] else { return nil }
        
        return service.sequence_contents[inItem]
    }

    /* ################################################################## */
    /**
     Removes the element (as a CBService).
     
     - parameter inItem: The CB element we're looking to remove.
     - returns: True, if the item was found and removed. Can be ignored.
     */
    @discardableResult
    mutating func removeThisService(_ inItem: CBService) -> Bool {
        var success = false
        removeAll { (test) -> Bool in
            guard let testService = test.cbElementInstance else { return false }
            if testService === inItem {
                success = true
                return true
            } else if testService.uuid.uuidString == inItem.uuid.uuidString {
                success = true
                return true
            }
            
            return false
        }
        
        return success
    }
    
    /* ################################################################## */
    /**
     Checks to see if the Array contains an instance that wraps the given CB element.
     
     - parameter inItem: The CB element we're looking to match.
     - returns: True, if the Array contains a wrapper for the given element.
     */
    func contains(_ inItem: CBService) -> Bool { nil != self[inItem] }
}
