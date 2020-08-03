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

import Cocoa
import RVS_BlueThoth_MacOS

/* ###################################################################################################################################### */
// MARK: - Preferences Extension -
/* ###################################################################################################################################### */
extension CGA_PersistentPrefs {
    /* ################################################################## */
    /**
     This is the scan criteria object to be used for filtering scans.
     It is provided in the struct required by the Bluetooth subsystem.
     */
    var scanCriteria: RVS_BlueThoth.ScanCriteria! { RVS_BlueThoth.ScanCriteria(peripherals: peripheralFilterIDArray, services: serviceFilterIDArray, characteristics: characteristicFilterIDArray) }
}

/* ###################################################################################################################################### */
// MARK: - Array Extension for Registered Screens -
/* ###################################################################################################################################### */
extension Array where Element == RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol {
    /* ################################################################## */
    /**
     Adds a screen to our Array. If it is already there, nothing happens.
     
     - parameter inScreen: The screen we want added.
     */
    mutating func addScreen(_ inScreen: RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol) {
        if nil == self[inScreen.key] {
            self.append(inScreen)
        }
        
        return
    }
    
    /* ################################################################## */
    /**
     Removes the given screen from our Array.
     
     - parameter inScreen: The screen we want removed.
     */
    mutating func removeScreen(_ inScreen: RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol) {
        self.removeAll(where: { $0.key == inScreen.key })
    }
    
    /* ################################################################## */
    /**
     This subscript allows us to fetch an instance by its String key.
     
     - parameter inKey: The String, with the unique key for the screen.
     */
    subscript(_ inKey: String) -> Element? {
        for element in self where element.key == inKey {
            return element
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main Application Delegate -
/* ###################################################################################################################################### */
/**
 */
@NSApplicationMain
class RVS_BlueThoth_Test_Harness_MacOS_AppDelegate: NSObject, NSApplicationDelegate {
    /* ################################################################## */
    /**
     This is the unique key for the device discovery panel.
     */
    static let deviceScreenID = "DeviceDiscovery"

    /* ################################################################## */
    /**
     This is the Bluetooth Central Manager instance. Everything goes through this.
     */
    var centralManager: RVS_BlueThoth?
    
    /* ################################################################## */
    /**
     This will contain our persistent prefs
     */
    var prefs = CGA_PersistentPrefs()
    
    /* ################################################################## */
    /**
     This has our open windows.
     */
    var screenList: [RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol] = []
}

/* ###################################################################################################################################### */
// MARK: - Application Delegate Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_AppDelegate {
    /* ################################################################## */
    /**
     Called when the app has completed launching.
     
     - parameter: ignored.
     */
    func applicationDidFinishLaunching(_: Notification) {
        centralManager = RVS_BlueThoth(delegate: self)
    }

    /* ################################################################## */
    /**
     Called just before the app terminates.
     
     - parameter: ignored.
     */
    func applicationWillTerminate(_: Notification) {
    }
}

/* ###################################################################################################################################### */
// MARK: - Class Computed Properties -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_AppDelegate {
    /* ################################################################## */
    /**
     This is a quick way to get this object instance (it's a SINGLETON), cast as the correct class.
     
     - returns: the app delegate object, in its natural environment.
     */
    @objc dynamic class var appDelegateObject: RVS_BlueThoth_Test_Harness_MacOS_AppDelegate {
        return (NSApplication.shared.delegate as? RVS_BlueThoth_Test_Harness_MacOS_AppDelegate)!
    }
}

/* ###################################################################################################################################### */
// MARK: - Class Functions -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_AppDelegate {
    /* ################################################################## */
    /**
     This displays a simple alert, with an OK button.
     
     - parameter header: The header to display at the top.
     - parameter message: A String, containing whatever messge is to be displayed below the header.
     */
    class func displayAlert(header inHeader: String, message inMessage: String = "") {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = inHeader.localizedVariant
            alert.informativeText = inMessage.localizedVariant
            alert.addButton(withTitle: "SLUG-OK-BUTTON-TEXT".localizedVariant)
            alert.runModal()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_AppDelegate {
    /* ################################################################## */
    /**
     Updates a single screen UI.
     
     - parameter inScreenID: A String, with the unique ID of the screen.
     */
    func updateScreen(_ inScreenID: String) {
        for screen in self.screenList where inScreenID == screen.key {
            screen.updateUI()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_BlueThoth_Delegate Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_AppDelegate: CGA_BlueThoth_Delegate {
    /* ################################################################## */
    /**
     Handles an error from the SDK.
     
     - parameter inError: The error that occurred.
     - parameter from: The Central instance that experienced the error.
     */
    func handleError(_ inError: CGA_Errors, from inCentralInstance: RVS_BlueThoth) {
        Self.displayAlert(header: "SLUG-ERROR".localizedVariant, message: String(describing: inError.layeredDescription))
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance to do whatever it needs to do to update its data.
     NOTE: There may be no changes, or many changes. What has changed is not specified.
     
     - parameter inCentralInstance: The central manager that is calling this.
     */
    func updateFrom(_ inCentralInstance: RVS_BlueThoth) {
        #if DEBUG
            print("Central instance: \(String(describing: inCentralInstance)) reporting an update.")
        #endif
        if !screenList.isEmpty,
            let discoveryViewController = screenList[0] as? RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController {
            discoveryViewController.buildTableMap()
        }
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance that a Peripheral device has been connected.
     
     - parameter inCentralInstance: The central manager that is calling this.
     - parameter didConnectThisDevice: The device instance that was connected.
     */
    func centralManager(_ inCentralInstance: RVS_BlueThoth, didConnectThisDevice inPeripheral: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Peripheral Connected")
        #endif
        updateScreen(inPeripheral.id)
    }

    /* ################################################################## */
    /**
     Called prior to a device being disconnected.
     
     - parameter inCentralInstance: The central manager that is calling this.
     - parameter willDisconnectThisDevice: The device instance that will be disconnected.
     */
    func centralManager(_ inCentralInstance: RVS_BlueThoth, willDisconnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Peripheral Disonnected")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance that a Peripheral device has had some change.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter deviceInfoChanged: The device instance that was connected.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, deviceInfoChanged inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Peripheral Update")
        #endif
        
        if !screenList.isEmpty,
            let discoveryViewController = screenList[0] as? RVS_BlueThoth_Test_Harness_MacOS_DiscoveryViewController {
            discoveryViewController.mainSplitView?.collapseSplit()
            discoveryViewController.buildTableMap()
            updateScreen(Self.deviceScreenID)
        }
    }

    /* ################################################################## */
    /**
     This is called to tell the instance that the state of the Central manager just became "powered on."
     
     - parameter inCentralInstance: The central manager that is calling this.
     */
    func centralManagerPoweredOn(_ inCentralInstance: RVS_BlueThoth) {
        #if DEBUG
            print("Central instance: \(String(describing: inCentralInstance)) powered on.")
        #endif
    }
    
    /* ################################################################## */
    /**
     This is called when a Peripheral announces a change to one of its Characteristics.
     
     - parameters:
        - inCentralInstance: The central manager that is calling this.
        - device: The Peripheral that contains the changed Characteristic.
        - service: The Service that contains the changed Characteristic.
        - changedCharacteristic: The Characteristic that has experienced the change.
     */
    func centralManager(_ inCentral: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, changedCharacteristic inCharacteristic: CGA_Bluetooth_Characteristic) {
        let origValue = RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController.characteristicValueCache[inCharacteristic.id] ?? ""
        if let newValue = inCharacteristic.stringValue {
            RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController.characteristicValueCache[inCharacteristic.id] = origValue + newValue
        }
        
        updateScreen(inCharacteristic.id)
    }
    
    /* ################################################################## */
    /**
     This is called to tell the instance that a Characteristic write with response received its response.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter characteristicWriteComplete: The Characteristic that had its write completed.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inPeripheral: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, characteristicWriteComplete inCharacteristic: CGA_Bluetooth_Characteristic) {
        #if DEBUG
            print("Characteristic: \(inCharacteristic.id) Wrote Its Value")
            if  let stringValue = inCharacteristic.stringValue {
                print("\tCharacteristic String Value: \"\(stringValue)\"")
            }
        #endif
        
        Self.displayAlert(header: "WRITE-RESPONSE".localizedVariant)
    }
}
