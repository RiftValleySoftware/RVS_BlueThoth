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

import WatchKit
import RVS_BlueThoth_WatchOS

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
// MARK: - Main Watch App Extension Delegate -
/* ###################################################################################################################################### */
class RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate: NSObject {
    /* ################################################################## */
    /**
     This is the Central Manager instance.
     */
    var centralManager: RVS_BlueThoth?
    
    /* ################################################################## */
    /**
     This contains all of our screens. The key is the ID of the device or attribute associated with that screen.
     */
    var screenList: [String: RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol] = [:]
}

/* ###################################################################################################################################### */
// MARK: - Main Watch App Extension Delegate -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate: WKExtensionDelegate {
    /* ################################################################## */
    /**
     */
    func applicationDidBecomeActive() {
        centralManager = RVS_BlueThoth(delegate: self)
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillResignActive() {
        centralManager = nil
    }
    
    /* ################################################################## */
    /**
     This is called while the app is in the background, with various tasks that need to be handled.
     
     - parameter inBackgroundTasks: A set of background tasks that need to be taken care of.
     */
    func handle(_ inBackgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in inBackgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}

/* ###################################################################################################################################### */
// MARK: - Class Functions -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate {
    /* ################################################################## */
    /**
     Quick access to the extension delegate object.
     */
    class var extensionDelegateObject: RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate! { WKExtension.shared().delegate as? RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate }

    /* ################################################################## */
    /**
     Displays the given message and title in an alert with an "OK" button.
     
     - parameter header: a string to be displayed as the title of the alert. It is localized by this method.
     */
    class func displayAlert(header inHeader: String) {
        // This ensures that we are on the main thread.
        DispatchQueue.main.async {
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_BlueThoth_Delegate Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate: CGA_BlueThoth_Delegate {
    /* ################################################################## */
    /**
     Called to report an error.
     
     - parameter inError: The error being reported.
     - parameter from: The manager wrapper view that is calling this.
     */
    func handleError(_ inError: CGA_Errors, from inCentralManager: RVS_BlueThoth) {
        #if DEBUG
            print("ERROR!\n\t\(String(describing: inError))")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that the state of the Central manager just became "powered on."
     
     - parameter inCentralManager: The central manager that is calling this.
     */
    func centralManagerPoweredOn(_ inCentralManager: RVS_BlueThoth) {
        #if DEBUG
            print("Powered On.")
        #endif
        
        screenList[RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController.id]?.updateUI()
    }

    /* ################################################################## */
    /**
     Called to tell this controller to recalculate its table.
     
     - parameter inCentralManager: The manager wrapper view that is calling this.
     */
    func updateFrom(_ inCentralManager: RVS_BlueThoth) {
        #if DEBUG
            print("General Update")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a Peripheral device has been connected.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter didConnectThisDevice: The device instance that was connected.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, didConnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Connected Device")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a peripheral device is about to be disconnected.
     We use this to reset the view stack to the initial (Peripheral List) screen.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter willDisconnectThisDevice: The device instance that will be removed after this call.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, willDisconnectThisDevice inDevice: CGA_Bluetooth_Peripheral) {
        #if DEBUG
            print("Disconnecting Device")
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
    }

    /* ################################################################## */
    /**
     Called to tell the instance that a Service changed.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter changedService: The Service instance that contained the changed Characteristic.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, changedService inService: CGA_Bluetooth_Service) {
        #if DEBUG
            print("Service Update Received")
        #endif
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a Characteristic changed its value.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter changedCharacteristic: The Characteristic that was changed.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, changedCharacteristic inCharacteristic: CGA_Bluetooth_Characteristic) {
        #if DEBUG
            print("Characteristic Update Received")
            if  let stringValue = inCharacteristic.stringValue {
                print("\tString Value: \"\(stringValue)\"")
            }
        #endif
    }

    /* ################################################################## */
    /**
     Called to tell the instance that a Descriptor changed.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter device: The device instance that contained the changed Service.
     - parameter service: The Service instance that contained the changed Characteristic.
     - parameter characteristic: The Characteristic that contains the Descriptor that was changed.
     - parameter changedDescriptor: The Descriptor that was changed.
     */
    func centralManager(_ inCentralManager: RVS_BlueThoth, device inDevice: CGA_Bluetooth_Peripheral, service inService: CGA_Bluetooth_Service, characteristic inCharacteristic: CGA_Bluetooth_Characteristic, changedDescriptor inDescriptor: CGA_Bluetooth_Descriptor) {
        #if DEBUG
            print("Descriptor Update")
            if  let stringValue = inCharacteristic.stringValue {
                print("\tCharacteristic String Value: \"\(stringValue)\"")
            }
            if  let stringValue = inDescriptor.stringValue {
                print("\tDescriptor String Value: \"\(stringValue)\"")
            }
        #endif
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

/* ###################################################################################################################################### */
// MARK: - Base Class for Interface Controllers -
/* ###################################################################################################################################### */
/**
 This is a protocol that allows us to have predictable methods for screen instances.
 */
protocol RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol {
    /* ################################################################## */
    /**
     REQUIRED: This will contain whatever instance is to be associated with a screen.
     */
    var attachedBlueThothInstance: CGA_Class_Protocol? { get }
    
    /* ################################################################## */
    /**
     REQUIRED: This is called to update the UI of the controller to reflect the current state of the driver.
     */
    func updateUI()
}

/* ###################################################################################################################################### */
// MARK: - Base Class for Interface Controllers -
/* ###################################################################################################################################### */
/**
 This is a base class for screen instance View Controllers.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_Base: WKInterfaceController, RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol {
    /* ################################################################## */
    /**
     This is a stored property that each screen sets to its ID.
     */
    var id = ""
    
    /* ################################################################## */
    /**
     This will contain whatever instance is to be associated with a screen.
     */
    var attachedBlueThothInstance: CGA_Class_Protocol?
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_Base {
    /* ################################################################## */
    /**
     Default does nothing.
     It has to be objc dynamic, to allow override.
     */
    @objc dynamic func updateUI() { }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_Base {
    /* ################################################################## */
    /**
     Called just before the view activates.
     */
    override func willActivate() {
        super.willActivate()
        if  let extensionDelegateObject = RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.extensionDelegateObject {
            extensionDelegateObject.screenList[id] = self
        }
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just after the view deactivates.
     */
    override func didDeactivate() {
        super.didDeactivate()
        if  let extensionDelegateObject = RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate.extensionDelegateObject {
            extensionDelegateObject.screenList.removeValue(forKey: id)
        }
    }
}
