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

/* ###################################################################################################################################### */
// MARK: - The CGA_DetailViewController_TableRow Class (Denotes One Row of the Table) -
/* ###################################################################################################################################### */
/**
 */
class CGA_ServiceViewController_TableRow: UITableViewCell {
    @IBOutlet weak var characteristicIDLabel: UILabel!
    @IBOutlet weak var propertiesStackView: UIStackView!
}

/* ###################################################################################################################################### */
// MARK: - The initial view controller (table of services) -
/* ###################################################################################################################################### */
/**
 This controls the Service Information View.
 */
class CGA_ServiceViewController: UIViewController {
    /* ################################################################## */
    /**
     The reuse ID that we use for creating new table cells.
     */
    private static let _characteristicRowReuseID = "detail-row"
    
    /* ################################################################## */
    /**
     The ID of the segue that is executed to display Characteristic details.
     */
    private static let _characteristicDetailSegueID = "show-characteristic-detail"

    /* ################################################################## */
    /**
     The Service that is associated with this view controller.
     */
    var serviceInstance: CGA_Bluetooth_Service!
    
    /* ################################################################## */
    /**
     This is the table that will list the discovered Services.
     */
    @IBOutlet weak var characteristicsTableView: UITableView!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the Service.
     */
    func updateUI() {
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = serviceInstance?.id.localizedVariant
    }
    
    /* ################################################################## */
    /**
     This is called just before we bring in the Characteristic screen.
     
     - parameter for: The segue being executed.
     - parameter sender: The data we want passed into the destination.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        // We only go further if we are looking at Service details.
        guard   let destination = inSegue.destination as? CGA_CharacteristicViewController,
                let senderData = inSender as? CGA_Bluetooth_Characteristic else { return }
        
        destination.characteristicInstance = senderData
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter numberOfRowsInSection: The 0-based section index being queried.
     - returns: The number of rows in the given section.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int { serviceInstance?.count ?? 0 }
    
    /* ################################################################## */
    /**
     This returns a view, with the data for the given row and section.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter cellForRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        guard   let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self._characteristicRowReuseID, for: inIndexPath) as? CGA_ServiceViewController_TableRow,
                let characteristic = serviceInstance?[inIndexPath.row]
        else { return UITableViewCell() }
        
        tableCell.characteristicIDLabel?.textColor = UIColor(white: tableView(inTableView, shouldHighlightRowAt: inIndexPath) ? 1.0 : 0.75, alpha: 1.0)
        tableCell.characteristicIDLabel?.text = characteristic.id.localizedVariant
        
        for index in 0..<tableCell.propertiesStackView.subviews.count {
            if let label = tableCell.propertiesStackView.subviews[index] as? UILabel {
                switch index {
                case 0:
                    label.text = characteristic.canRead ? "SLUG-PROPERTIES-READ".localizedVariant : ""
                case 1:
                    label.text = characteristic.canWriteWithoutResponse ? "SLUG-PROPERTIES-WRITE".localizedVariant : characteristic.canWrite ? "SLUG-PROPERTIES-WRITE-RESPONSE".localizedVariant : ""
                case 2:
                    label.text = characteristic.canNotify ? "SLUG-PROPERTIES-NOTIFY".localizedVariant : ""
                case 3:
                    label.text = characteristic.canIndicate ? "SLUG-PROPERTIES-INDICATE".localizedVariant : ""
                case 4:
                    label.text = characteristic.canBroadcast ? "SLUG-PROPERTIES-BROADCAST".localizedVariant : ""
                case 5:
                    label.text = characteristic.requiresAuthenticatedSignedWrites ? "SLUG-PROPERTIES-AUTH-SIGNED-WRITE".localizedVariant : ""
                case 6:
                    label.text = characteristic.requiresNotifyEncryption ? "SLUG-PROPERTIES-NOTIFY-ENCRYPT".localizedVariant : ""
                case 7:
                    label.text = characteristic.requiresIndicateEncryption ? "SLUG-PROPERTIES-INDICATE-ENCRYPT".localizedVariant : ""
                case 8:
                    label.text = characteristic.hasExtendedProperties ? "SLUG-PROPERTIES-EXTENDED".localizedVariant : ""
                default:
                    #if DEBUG
                        print("ERROR! Too Many Labels!")
                    #else
                        break
                    #endif
                }
            }
        }
        
        return tableCell
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called to test whether or not to allow a row to be selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter willSelectRowAt: The index path (section, row) for the cell.
     - returns: The IndexPath of the cell, if approved, or nil, if not.
     */
    func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? { 0 < (serviceInstance?[inIndexPath.row].count ?? 0) ? inIndexPath : nil }
    
    /* ################################################################## */
    /**
     Called to test whether or not to allow a row to be higlighted.
     
     This prevents the unselectable row from "flashing" when someone touches it.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter shouldHighlightRowAt: The index path (section, row) for the cell.
     - returns: The IndexPath of the cell, if approved, or nil, if not.
     */
    func tableView(_ inTableView: UITableView, shouldHighlightRowAt inIndexPath: IndexPath) -> Bool { nil != tableView(inTableView, willSelectRowAt: inIndexPath) }

    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter didSelectRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        performSegue(withIdentifier: Self._characteristicDetailSegueID, sender: serviceInstance?[inIndexPath.row])
        inTableView.deselectRow(at: inIndexPath, animated: false)
    }
}
