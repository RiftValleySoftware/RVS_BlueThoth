/*
© Copyright 2020-2022, The Great Rift Valley Software Company

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

import UIKit
import RVS_BlueThoth

/* ###################################################################################################################################### */
// MARK: - Connected Peripheral View Controller -
/* ###################################################################################################################################### */
/**
 */
class CGA_CharacteristicViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     Each element of the table data is a struct, with a label, atarget, and an action function
     */
    struct TableRowStruct {
        /* ############################################################## */
        /**
         This is the string that the table row will display.
         */
        var title: String = ""
        
        /* ############################################################## */
        /**
         This is the argument to be sent into the action closure.
         */
        var target: Any?

        /* ############################################################## */
        /**
         This is the action function that will be called if the row is selected.
         
         - parameter: The Characteristic or Descriptor being referenced.
         */
        var action: ((_: Any) -> Void)?
        
        /* ############################################################## */
        /**
         The initializer allows a coupler of the arguments to be omitted.
         
         - parameters:
            - title: REQUIRED. The string to display for the table row.
            - target: OPTIONAL: The Characteristic or Descriptor wrapper instance to be sent to the action. Meaningless if action is not also provided. Default is nil.
            - action: OPTIONAL: The function to call, passing the target as the argument. Default is nil.
         */
        init(title inTitle: String, target inTarget: Any? = nil, action inAction: ((_: Any) -> Void)? = nil) {
            title = inTitle
            target = inTarget
            action = inAction
        }
    }
    
    /* ################################################################## */
    /**
     The reuse ID for rows with just a label.
     */
    static let labelTableCellReuseID = "basic-label"
    
    /* ################################################################## */
    /**
     The Service wrapper instance for this Service.
     */
    var characteristicInstance: CGA_Bluetooth_Characteristic!
    
    /* ################################################################## */
    /**
     This defines the data that we'll use to populate the table.
     */
    var tableRowData: [TableRowStruct] = []
    
    /* ################################################################## */
    /**
     This label displays the device name.
     */
    @IBOutlet weak var nameLabel: UILabel!

    /* ################################################################## */
    /**
     The table that displays the Characteristics.
     */
    @IBOutlet weak var descriptorsTableView: UITableView!
}

/* ###################################################################################################################################### */
// MARK: - Special Table Response Methods -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController {
    /* ################################################################## */
    /**
     Tells the Characteristic to switch its notify state.
     */
    func toggleCharacteristicNotify(_ inCharacteristic: Any) {
        if (inCharacteristic as? CGA_Bluetooth_Characteristic)?.isNotifying ?? false {
            (inCharacteristic as? CGA_Bluetooth_Characteristic)?.stopNotifying()
        } else {
            (inCharacteristic as? CGA_Bluetooth_Characteristic)?.startNotifying()
        }
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Tells the Characteristic to read.
     */
    func readCharacteristicData(_ inCharacteristic: Any) {
        (inCharacteristic as? CGA_Bluetooth_Characteristic)?.readValue()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Tells the Descriptor to read.
     */
    func readDescriptorData(_ inDescriptor: Any) {
        (inDescriptor as? CGA_Bluetooth_Descriptor)?.readValue()
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
        descriptorsTableView?.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-ELEMENTS-TABLE-WATCH".localizedVariant
    }
    
    /* ################################################################## */
    /**
     This establishes the data that we'll use for our table.
     */
    func populateTableData() {
        tableRowData = []
        
        if  let stringValue = characteristicInstance?.stringValue,
            !stringValue.isEmpty {
            tableRowData.append(TableRowStruct(title: stringValue))
        }
        
        if characteristicInstance?.canRead ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-PROPERTIES-READ".localizedVariant, target: characteristicInstance, action: readCharacteristicData))
        }
        
        if characteristicInstance?.canNotify ?? false {
            let label = ("SLUG-PROPERTIES-NOTIFY-O" + ((characteristicInstance?.isNotifying ?? false) ? "N" : "FF")).localizedVariant
            tableRowData.append(TableRowStruct(title: label, target: characteristicInstance, action: toggleCharacteristicNotify))
        }
        
        if characteristicInstance?.canIndicate ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-INDICATE".localizedVariant))
        }
        
        if characteristicInstance?.canWriteWithoutResponse ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-WRITE".localizedVariant))
        }
        
        if characteristicInstance?.canWriteWithResponse ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-WRITE-RESP".localizedVariant))
        }
        
        if characteristicInstance?.requiresAuthenticatedSignedWrites ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-AUTH-SW".localizedVariant))
        }
        
        if characteristicInstance?.canBroadcast ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-BROADCAST".localizedVariant))
        }

        if characteristicInstance?.requiresNotifyEncryption ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-NOTIFY-ENC".localizedVariant))
        }
        
        if characteristicInstance?.requiresIndicateEncryption ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-INDICATE-ENC".localizedVariant))
        }
        
        if characteristicInstance?.hasExtendedProperties ?? false {
            tableRowData.append(TableRowStruct(title: "SLUG-WATCH-PROPERTY-EXTENDED".localizedVariant))
        }
        
        for descriptor in characteristicInstance {
            if  let descriptor = descriptor as? CGA_Bluetooth_Descriptor {
                var descString = descriptor.stringValue ?? ""
                if !descString.isEmpty {
                    descString += "\n"
                }
                
                descString += descriptor.id.localizedVariant
                
                if let characteristic = descriptor as? CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration {
                    descString += "\n" + "SLUG-ACC-DESCRIPTOR-CLIENTCHAR-NOTIFY-\(characteristic.isNotifying ? "YES" : "NO")".localizedVariant
                    descString += "SLUG-ACC-DESCRIPTOR-CLIENTCHAR-INDICATE-\(characteristic.isIndicating ? "YES" : "NO")".localizedVariant
                }
                
                if let characteristic = descriptor as? CGA_Bluetooth_Descriptor_Characteristic_Extended_Properties {
                    descString += "\n" + "SLUG-ACC-DESCRIPTOR-EXTENDED-RELIABLE-WR-\(characteristic.isReliableWriteEnabled ? "YES" : "NO")".localizedVariant
                    descString += "SLUG-ACC-DESCRIPTOR-EXTENDED-AUX-WR-\(characteristic.isWritableAuxiliariesEnabled ? "YES" : "NO")".localizedVariant
                }
                
                if let characteristic = descriptor as? CGA_Bluetooth_Descriptor_PresentationFormat {
                    descString += "\n" + "SLUG-CHAR-PRESENTATION-\(characteristic.stringValue ?? "255")".localizedVariant
                }
                
                tableRowData.append(TableRowStruct(title: descString, target: descriptor, action: readDescriptorData))
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController {
    /* ################################################################## */
    /**
     Called just after the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel?.text = characteristicInstance?.id.localizedVariant
    }
    
    /* ################################################################## */
    /**
     Called just before the view will appear. We use this to ensure that we are disconnected.
     
     - parameter inAnimated: ignored, but passed to the superclas.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the table is displayed if BT is available, or the "No BT" image is shown, if it is not.
     */
    func updateUI() {
        populateTableData()
        descriptorsTableView?.reloadData()
        setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     Called to provide the data to display in the indicated table cell.
     
     - parameters:
        - inTableView: The Table View that is asking for this View.
        - cellForRowAt: The IndexPath of the cell.
     
     - returns: A new view, set up for the indicated cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if let ret = inTableView.dequeueReusableCell(withIdentifier: Self.labelTableCellReuseID) {
            ret.textLabel?.text = tableRowData[inIndexPath.row].title
            ret.textLabel?.isEnabled = nil != tableRowData[inIndexPath.row].action
            ret.selectionStyle = (nil == tableRowData[inIndexPath.row].action) ? .default : .none
            ret.isUserInteractionEnabled = nil != tableRowData[inIndexPath.row].action
            return ret
        }
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     - returns: The number of rows in the table.
     */
    func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int { tableRowData.count }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called when a row is about to be highlighted.
     
     - parameter: ignored
     - parameter shouldHighlightRowAt: The IndexPath of the selected row.
     
     - returns: True (allow row to highlight), or false (don't allow)..
     */
    func tableView(_: UITableView, shouldHighlightRowAt inIndexPath: IndexPath) -> Bool { nil != tableRowData[inIndexPath.row].action }

    /* ################################################################## */
    /**
     Called when a row is about to be selected.
     
     - parameter: ignored
     - parameter willSelectRowAt: The IndexPath of the selected row.
     
     - returns: Either nil (don't select), or the given index path.
     */
    func tableView(_: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? { nil != tableRowData[inIndexPath.row].action ? inIndexPath : nil }

    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter: ignored
     - parameter didSelectRowAt: The IndexPath of the selected row.
     */
    func tableView(_: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        let handler = tableRowData[inIndexPath.row]
        
        if  let action = handler.action,
            let target = handler.target {
            action(target)
        }
    }
}
