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

public extension StringProtocol {
    /* ################################################################## */
    /**
     - returns: the localized string (main bundle) for this string.
     */
    var localizedVariant: String {
        let ret = NSLocalizedString(String(self), comment: "")
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: - Preferences Extension -
/* ###################################################################################################################################### */
/**
 This extension adds a bit of extra "sauce" to the shared prefs class, in that it adds stuff specific to our platform.
 */
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
/**
 This is the main app extension delegate class.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate: NSObject {
    /* ################################################################## */
    /**
     This is the Central Manager instance. It is created by the intial screen, but stored here.
     */
    var centralManager: RVS_BlueThoth?
    
    /* ################################################################## */
    /**
     This contains all of our screens. The key is the ID of the device or attribute associated with that screen.
     */
    var screenList: [String: RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol] = [:]
    
    /* ################################################################## */
    /**
     Quick accessor for the main discovery screen.
     */
    var mainScreen: RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController? { screenList[RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController.id] as? RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryInterfaceController }
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
     
     - parameter inTitle: REQUIRED: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter message: OPTIONAL: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter from: REQUIRED: The controller presenting the error.
     */
    class func displayAlert(header inTitle: String, message inMessage: String = "", from inController: WKInterfaceController) {
        #if DEBUG
            print("ALERT:\t\(inTitle)\n\t\t\(inMessage)")
        #endif
        DispatchQueue.main.async {  // In case we're called off-thread...
            let okAction = WKAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: WKAlertActionStyle.default) {
                #if DEBUG
                    print("Alert Dismissed")
                #endif
            }
            
            inController.presentAlert(withTitle: inTitle.localizedVariant, message: inMessage.localizedVariant, preferredStyle: WKAlertControllerStyle.alert, actions: [okAction])
        }
    }
    
    /* ################################################################## */
    /**
     This creates an Array of String, containing the advertisement data from the indexed device.
     
     - parameter inAdData: The advertisement data.
     - parameter id: The ID string.
     - parameter power: The RSSI level.
     - returns: An Array of String, with the advertisement data in "key: value" form.
     */
    class func createAdvertimentStringsFor(_ inAdData: RVS_BlueThoth.AdvertisementData?, id inID: String, power inPower: Int) -> [String] {
        // This gives us a predictable order of things.
        guard let sortedAdDataKeys = inAdData?.advertisementData.keys.sorted() else { return [] }
        let sortedAdData: [(key: String, value: Any?)] = sortedAdDataKeys.compactMap { (key:$0, value: inAdData?.advertisementData[$0]) }

        let retStr = sortedAdData.reduce("SLUG-ID".localizedVariant + ": \(inID)\n\t" + String(format: "SLUG-RSSI-LEVEL-FORMAT".localizedVariant, inPower)) { (current, next) in
            let key = next.key.localizedVariant
            let value = next.value
            var ret = "\(current)\n"
            
            if let asStringArray = value as? [String] {
                ret += current + asStringArray.reduce("\t\(key): ") { (current2, next2) in "\(current2)\n\(next2.localizedVariant)" }
            } else if let value = value as? String {
                ret += "\t\(key): \(value.localizedVariant)"
            } else if let value = value as? Bool {
                ret += "\t\(key): \(value ? "true" : "false")"
            } else if let value = value as? Int {
                ret += "\t\(key): \(value)"
            } else if let value = value as? Double {
                if "kCBAdvDataTimestamp" == next.key {  // If it's the timestamp, we can translate that, here.
                    let date = Date(timeIntervalSinceReferenceDate: value)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "SLUG-MAIN-LIST-DATE-FORMAT".localizedVariant
                    let displayedDate = dateFormatter.string(from: date)
                    ret += "\t\(key): \(displayedDate)"
                } else {
                    ret += "\t\(key): \(value)"
                }
            } else {    // Anything else is just a described instance of something or other.
                ret += "\t\(key): \(String(describing: value))"
            }
            
            return ret
        }.split(separator: "\n").map { String($0) }
        
        return retStr
    }
}

/* ###################################################################################################################################### */
// MARK: - WKExtensionDelegate Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_ExtensionDelegate: WKExtensionDelegate {
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
        
        mainScreen?.displayAlert(header: "SLUG-ERROR".localizedVariant, message: String(describing: inError))
    }
    
    /* ################################################################## */
    /**
     Called to tell this controller to recalculate the discovery table.
     
     - parameter inCentralManager: The manager wrapper view that is calling this.
     */
    func updateFrom(_ inCentralManager: RVS_BlueThoth) {
        #if DEBUG
            print("General Update")
        #endif
        mainScreen?.updateUI()
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
        
        mainScreen?.updateUI()
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
        screenList[inDevice.id]?.updateUI()
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
    }
}
