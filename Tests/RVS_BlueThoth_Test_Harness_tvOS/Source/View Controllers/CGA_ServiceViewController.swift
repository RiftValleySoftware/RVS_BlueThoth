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
class CGA_ServiceViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     The reuse ID for each row of the table.
     */
    static let characteristicTableCellReuseID = "basic-characteristic"
    
    /* ################################################################## */
    /**
     The ID of the segue to show Characteristic detail.
     */
    static let characteristicDetailSegueID = "show-characteristic-detail"
    
    /* ################################################################## */
    /**
     The Service wrapper instance for this Service.
     */
    var serviceInstance: CGA_Bluetooth_Service!
    
    /* ################################################################## */
    /**
     This label displays the device name.
     */
    @IBOutlet weak var nameLabel: UILabel!

    /* ################################################################## */
    /**
     The table that displays the Characteristics.
     */
    @IBOutlet weak var characteristicsTableView: UITableView!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController {
    /* ################################################################## */
    /**
     Called just after the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel?.text = serviceInstance?.id.localizedVariant
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view will appear. We use this to ensure that we are disconnected.
     
     - parameter inAnimated: ignored, but passed to the superclas.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
    }
    
    /* ################################################################## */
    /**
     Called just before the characteristics display screen is pushed.
     
     - parameter for: The segue that is being executed.
     - parameter sender: The discovery information.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        if  let destination = inSegue.destination as? CGA_CharacteristicViewController,
            let characteristicInstance = inSender as? CGA_Bluetooth_Characteristic {
            destination.characteristicInstance = characteristicInstance
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the table is displayed if BT is available, or the "No BT" image is shown, if it is not.
     */
    func updateUI() {
        setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     Called to provide the data to display in the indicated table cell.
     
     - parameters:
        - inTableView: The Table View that is asking for this View.
        - cellForRowAt: The IndexPath of the cell.
     
     - returns: A new view, set up for the indicated cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if  let ret = inTableView.dequeueReusableCell(withIdentifier: Self.characteristicTableCellReuseID),
            let serviceInstance = serviceInstance {
            let characteristic = serviceInstance[inIndexPath.row]
            ret.textLabel?.text = characteristic.id.localizedVariant
            return ret
        }
        
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     - returns: The number of rows in the table.
     */
    func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int { serviceInstance?.count ?? 0 }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter: ignored
     - parameter didSelectRowAt: The IndexPath of the selected row.
     */
    func tableView(_: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        performSegue(withIdentifier: Self.characteristicDetailSegueID, sender: serviceInstance?[inIndexPath.row])
    }
}
