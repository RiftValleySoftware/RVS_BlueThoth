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
import Foundation
import RVS_BlueThoth_WatchOS

/* ###################################################################################################################################### */
// MARK: - Device Screen Controller -
/* ###################################################################################################################################### */
/**
 This View Controller is for the individual device screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController: RVS_BlueThoth_Test_Harness_WatchOS_Base {
    /* ################################################################## */
    /**
     This is the device discovery struct that describes this device.
     */
    var deviceDiscoveryData: RVS_BlueThoth.DiscoveryData!
    
    /* ################################################################## */
    /**
     This label displays the advertising strings.
     */
    @IBOutlet weak var advertisingInformationLabel: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - Internal Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     This creates an Array of String, containing the advertisement data from the indexed device.
     
     - parameter inAdData: The advertisement data.
     - parameter id: The ID string.
     - parameter power: The RSSI level.
     - returns: An Array of String, with the advertisement data in "key: value" form.
     */
    func createAdvertimentStringsFor(_ inAdData: RVS_BlueThoth.AdvertisementData?, id inID: String, power inPower: Int) -> [String] {
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
// MARK: - Overridden Base Class Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     This is called as the view is established.
     
     - parameter withContext: The context, passed in from the main view. It will be the device discovery struct.
     */
    override func awake(withContext inContext: Any?) {
        if let context = inContext as? RVS_BlueThoth.DiscoveryData {
            deviceDiscoveryData = context
            id = context.identifier
            setTitle(deviceDiscoveryData.preferredName)
        }
    }
    
    /* ################################################################## */
    /**
     This is called as the view is about to become active.
     */
    override func willActivate() {
        super.willActivate()
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     This sets everything up to reflect the current state of the Central Manager.
     */
    override func updateUI() {
        let advertisingStrings = createAdvertimentStringsFor(deviceDiscoveryData.advertisementData, id: deviceDiscoveryData.identifier, power: deviceDiscoveryData.rssi)
        advertisingInformationLabel.setText(advertisingStrings.joined(separator: "\n"))
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DiscoveryViewController {
    /* ################################################################## */
    /**
     */
    @IBAction func connectToDevice(_: Any) {
        #if DEBUG
            print("Connecting to: \(deviceDiscoveryData?.preferredName ?? "ERROR")")
        #endif
        pushController(withName: RVS_BlueThoth_Test_Harness_WatchOS_DeviceViewController.screenID, context: deviceDiscoveryData)
    }
}
