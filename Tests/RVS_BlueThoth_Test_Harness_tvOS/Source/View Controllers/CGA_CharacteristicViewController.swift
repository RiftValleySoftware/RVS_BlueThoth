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

import UIKit
import RVS_BlueThoth_TVOS

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
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if let ret = inTableView.dequeueReusableCell(withIdentifier: Self.labelTableCellReuseID) {
            ret.textLabel?.text = tableRowData[inIndexPath.row].title
            
            return ret
        }
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int { tableRowData.count }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     */
    func tableView(_: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        let handler = tableRowData[inIndexPath.row]
        
        if  let action = handler.action,
            let target = handler.target {
            action(target)
        }
    }
}
