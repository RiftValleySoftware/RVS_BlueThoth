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
// MARK: - The CGA_DetailViewController_TableRow Class (Denotes One Row of the Table) -
/* ###################################################################################################################################### */
/**
 This denotes one row of the table of Descriptors. Each row denotes one Descriptor.
 */
class CGA_CharacteristicViewController_TableRow: UITableViewCell {
    /* ################################################################## */
    /**
     This is the top label that displays the Descriptor ID
     */
    @IBOutlet weak var descriptorIDLabel: UILabel!

    /* ################################################################## */
    /**
     The bottom label displays the Descriptor value (interpreted)
     */
    @IBOutlet weak var descriptorValueLabel: UILabel!
    
    /* ################################################################## */
    /**
     This button allows interaction with the Descriptor.
     */
    @IBOutlet weak var interactionButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: - The Characteristic View Controller (table of Descriptors) -
/* ###################################################################################################################################### */
/**
 This controls the Characteristic Information View.
 */
class CGA_CharacteristicViewController: CGA_BaseViewController, CGA_WriteableElementContainer {
    /* ################################################################## */
    /**
     The reuse ID that we use for creating new table cells.
     */
    private static let _descriptorRowReuseID = "detail-row"
    
    /* ################################################################## */
       /**
        The ID of the segue that is executed to display the Descriptor Interaction Screen.
        */
    private static let _interactionDescriptorSegueID = "show-descriptor-write"

    /* ################################################################## */
    /**
     This implements a "pull to refresh."
     */
    private let _refreshControl = UIRefreshControl()

    /* ################################################################## */
    /**
     The Characteristic that is associated with this view controller.
     */
    var writeableElementInstance: CGA_Bluetooth_Writable?
    
    /* ################################################################## */
    /**
     The Characteristic that is associated with this view controller, cast from the writable entity.
     */
    var myCharacteristicInstance: CGA_Bluetooth_Characteristic? {
        writeableElementInstance as? CGA_Bluetooth_Characteristic
    }

    /* ################################################################## */
    /**
     This is the table that will list the descriptors.
     */
    @IBOutlet weak var descriptorsTableView: UITableView!
    
    /* ################################################################## */
    /**
     This button allows interaction with the Characteristic.
     */
    @IBOutlet weak var interactionButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController {
    /* ################################################################## */
    /**
     This is called by the table's "pull to refresh" handler.
     
     When this is called, the Characteristic wipes out its Descriptors, and starts over from scratch.
     
     - parameter: ignored.
     */
    @objc func startOver(_: Any) {
        updateAllDescriptors()
        _refreshControl.endRefreshing()
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
        descriptorsTableView?.accessibilityLabel = "SLUG-ACC-DESCRIPTOR-TABLE".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController {
    /* ################################################################## */
    /**
     This forces a re-read of all descriptors.
     */
    func updateAllDescriptors() {
        myCharacteristicInstance?.forEach { $0.readValue() }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the Characteristic.
     */
    func updateUI() {
        descriptorsTableView?.reloadData()
        setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = myCharacteristicInstance?.id.localizedVariant
        interactionButton?.setTitle(interactionButton?.title(for: .normal)?.localizedVariant ?? "ERROR", for: .normal)
        interactionButton?.isHidden = !(myCharacteristicInstance?.canWrite ?? false)
        interactionButton?.accessibilityLabel = "SLUG-ACC-DESCRIPTOR-INTERACT-BUTTON".localizedVariant
        _refreshControl.tintColor = .white
        _refreshControl.addTarget(self, action: #selector(startOver(_:)), for: .valueChanged)
        descriptorsTableView?.refreshControl = _refreshControl
        updateAllDescriptors()
    }
    
    /* ################################################################## */
    /**
     This is called just before we bring in the Interaction screen.
     
     - parameter for: The segue being executed.
     - parameter sender: The data we want passed into the destination (ignored).
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        if let destination = inSegue.destination as? CGA_CharacteristicInteractionViewController {
            destination.writeableElementInstance = writeableElementInstance
        } else if   let destination = inSegue.destination as? CGA_DescriptorInteractionViewController,
                    let descriptor = inSender as? CGA_Bluetooth_Descriptor {
            destination.writeableElementInstance = descriptor
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter numberOfRowsInSection: The 0-based section index being queried.
     - returns: The number of rows in the given section.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int { myCharacteristicInstance?.count ?? 0 }
    
    /* ################################################################## */
    /**
     This returns a view, with the data for the given row and section.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter cellForRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        guard let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self._descriptorRowReuseID, for: inIndexPath) as? CGA_CharacteristicViewController_TableRow
            else { return UITableViewCell() }
        tableCell.descriptorIDLabel?.text = myCharacteristicInstance?[inIndexPath.row].id.localizedVariant ?? "ERROR"
        
        var labelText = ""
        
        if let characteristic = myCharacteristicInstance?[inIndexPath.row] as? CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration {
            labelText = "SLUG-ACC-DESCRIPTOR-CLIENTCHAR-NOTIFY-\(characteristic.isNotifying ? "YES" : "NO")".localizedVariant
            labelText += "SLUG-ACC-DESCRIPTOR-CLIENTCHAR-INDICATE-\(characteristic.isIndicating ? "YES" : "NO")".localizedVariant
        }
        
        if let characteristic = myCharacteristicInstance?[inIndexPath.row] as? CGA_Bluetooth_Descriptor_Characteristic_Extended_Properties {
            labelText = "SLUG-ACC-DESCRIPTOR-EXTENDED-RELIABLE-WR-\(characteristic.isReliableWriteEnabled ? "YES" : "NO")".localizedVariant
            labelText += "SLUG-ACC-DESCRIPTOR-EXTENDED-AUX-WR-\(characteristic.isWritableAuxiliariesEnabled ? "YES" : "NO")".localizedVariant
        }
        
        if let characteristic = myCharacteristicInstance?[inIndexPath.row] as? CGA_Bluetooth_Descriptor_PresentationFormat {
            labelText = "SLUG-CHAR-PRESENTATION-\(characteristic.stringValue ?? "255")".localizedVariant
        }

        tableCell.descriptorValueLabel.text = labelText
        
        // This ensures that we maintain a consistent backround color upon selection.
        tableCell.selectedBackgroundView = UIView()
        tableCell.selectedBackgroundView?.backgroundColor = UIColor(cgColor: prefs.tableSelectionBackgroundColor)

        return tableCell
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter didSelectRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        // We always read the value.
        myCharacteristicInstance?[inIndexPath.row].readValue()
        // If we are not the client configuration descriptor, then we can also write.
        if  !(myCharacteristicInstance?[inIndexPath.row] is CGA_Bluetooth_Descriptor_ClientCharacteristicConfiguration) {
            performSegue(withIdentifier: Self._interactionDescriptorSegueID, sender: myCharacteristicInstance?[inIndexPath.row])
            inTableView.deselectRow(at: inIndexPath, animated: false)
        }
    }
}
