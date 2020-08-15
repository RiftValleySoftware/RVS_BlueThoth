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
 This View Controller is for the individual Characteristic screen.
 */
class RVS_BlueThoth_Test_Harness_WatchOS_DescriptorInterfaceController: RVS_BlueThoth_Test_Harness_WatchOS_BaseInterfaceController {
    /* ################################################################## */
    /**
     This is the Descriptor instance.
     */
    weak var descriptorInstance: CGA_Bluetooth_Descriptor?

    /* ################################################################## */
    /**
     Displays the Descriptor value as text (if possible).
     */
    @IBOutlet weak var valueLabel: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DescriptorInterfaceController {
    /* ################################################################## */
    /**
     Establishes accessibility labels.
     */
    func setAccessibility() {
        valueLabel?.setAccessibilityLabel("SLUG-ACC-DESCRIPTOR-VALUE".localizedVariant)
    }
}

/* ###################################################################################################################################### */
// MARK: - Overridden Base Class Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DescriptorInterfaceController {
    /* ################################################################## */
    /**
     This is called as the view is established.
     
     - parameter withContext: The context, passed in from the main view. It will be the device discovery struct.
     */
    override func awake(withContext inContext: Any?) {
        if let context = inContext as? CGA_Bluetooth_Descriptor {
            id = context.id
            super.awake(withContext: inContext)
            descriptorInstance = context
            setTitle(id.localizedVariant)
            updateUI()
            setAccessibility()
        } else {
            super.awake(withContext: inContext)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_WatchOS_Base_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_WatchOS_DescriptorInterfaceController {
    /* ################################################################## */
    /**
     This sets everything up to reflect the current state of the Descriptor.
     */
    override func updateUI() {
        var labelText = ""
        
        if let descriptor = descriptorInstance as? CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration {
            let isNotifying = descriptor.isNotifying
            let isIndicating = descriptor.isIndicating
            labelText = "SLUG-ACC-DESCRIPTOR-CLIENTCHAR-NOTIFY-\(isNotifying ? "YES" : "NO")".localizedVariant
            labelText += "\n" + "SLUG-ACC-DESCRIPTOR-CLIENTCHAR-INDICATE-\(isIndicating ? "YES" : "NO")".localizedVariant
        }
        
        if let descriptor = descriptorInstance as? CGA_Bluetooth_Descriptor_Characteristic_Extended_Properties {
            labelText = "SLUG-ACC-DESCRIPTOR-EXTENDED-RELIABLE-WR-\(descriptor.isReliableWriteEnabled ? "YES" : "NO")".localizedVariant
            labelText += "\n" + "SLUG-ACC-DESCRIPTOR-EXTENDED-AUX-WR-\(descriptor.isWritableAuxiliariesEnabled ? "YES" : "NO")".localizedVariant
        }
        
        if let descriptor = descriptorInstance as? CGA_Bluetooth_Descriptor_PresentationFormat {
            labelText = "SLUG-CHAR-PRESENTATION-\(descriptor.stringValue ?? "255")".localizedVariant
        }
        
        valueLabel?.setText(labelText)
    }
}
