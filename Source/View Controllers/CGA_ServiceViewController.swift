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
 Our table cells have three rows.
 */
class CGA_ServiceViewController_TableRow: UITableViewCell {
    /* ################################################################## */
    /**
     The label at the top, containing the Characteristic ID
     */
    @IBOutlet weak var characteristicIDLabel: UILabel!
    /* ################################################################## */
    /**
     The horizontal stack view in the middle, showing our various flags (and maybe the NOTIFY button).
     */
    @IBOutlet weak var propertiesStackView: UIStackView!
    /* ################################################################## */
    /**
     The label at the bottom, containing the Characteristic value, if it can be expressed as a String.
     */
    @IBOutlet weak var valueLabel: UILabel!
}

/* ###################################################################################################################################### */
// MARK: - A Special Tap Gesture Recognizer for Table Rows -
/* ###################################################################################################################################### */
/**
 This simply allows us to attach a row index to a gesture, so we know which Characteristic to use.
 */
class CG_TapGestureRecognizer: UITapGestureRecognizer {
    /* ################################################################## */
    /**
     the 0-based row index of the Characteristic table row that corresponds to our Characteristic.
     */
    var rowIndex: Int = 0
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
     The margin we use for our labels.
     */
    private static let _marginToFlagLabel: CGFloat = 4.0

    /* ################################################################## */
    /**
     This implements a "pull to refresh."
     */
    private let _refreshControl = UIRefreshControl()

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
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController {
    /* ################################################################## */
    /**
     This is called by the table's "pull to refresh" handler.
     
     When this is called, the Service wipes out its Characteristics, and starts over from scratch.
     
     - parameter: ignored.
     */
    @objc func startOver(_: Any) {
        serviceInstance?.startOver()
        _refreshControl.endRefreshing()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     This is a gesture callback for a single-tap in a row, and the Characteristic can notify.
     It toggles the notify state of the Characteristic.
     
     - parameter inGestureRecognizer: The special gesture recognizer, with our row index.
     */
    @objc func notifyTapped(_ inGestureRecognizer: CG_TapGestureRecognizer) {
        if  let characteristicInstance = serviceInstance?[inGestureRecognizer.rowIndex],
            characteristicInstance.canNotify {
            if characteristicInstance.isNotifying {
                characteristicInstance.stopNotifying()
            } else {
                characteristicInstance.startNotifying()
            }
            characteristicsTableView?.reloadData()
        }
    }
    
    /* ################################################################## */
    /**
     This is a gesture callback for a double-tap in a row, and the Characteristic has descriptors.
     It causes the Descriptor List screen to appear.
     
     - parameter inGestureRecognizer: The special gesture recognizer, with our row index.
     */
    @objc func descriptorTapped(_ inGestureRecognizer: CG_TapGestureRecognizer) {
        if  let characteristic = serviceInstance?[inGestureRecognizer.rowIndex],
            0 < characteristic.count {
            performSegue(withIdentifier: Self._characteristicDetailSegueID, sender: characteristic)
            characteristicsTableView.deselectRow(at: IndexPath(row: inGestureRecognizer.rowIndex, section: 0), animated: false)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the Service.
     */
    func updateUI() {
        characteristicsTableView?.reloadData()
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
        characteristicsTableView?.refreshControl = _refreshControl
        _refreshControl.addTarget(self, action: #selector(startOver(_:)), for: .valueChanged)
        serviceInstance?.forEach { $0.readValue() }
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
     This struct is used to create a dynamic set of labels, indicating the Characteristic Properties.
     */
    struct _PropertyLabelGenerator {
        /* ############################################################## */
        /**
         The size (in display points) of the label text.
         */
        private let _labelFontSize: CGFloat = 20
        
        /* ############################################################## */
        /**
         The color of the label text.
         */
        private let _labelTextColor = UIColor.blue
        
        /* ############################################################## */
        /**
         The color of the label text.
         */
        private let _labelBackgroundColor = UIColor.white
        
        /* ############################################################## */
        /**
         A simple "factory" for the label.
         */
        private func _makeLabel(_ inText: String) -> UILabel {
            let ret = UILabel()
            ret.textColor = _labelTextColor
            ret.textColor = ("SLUG-PROPERTIES-NOTIFY".localizedVariant == inText) ? (characteristic.isNotifying ? _labelTextColor : .white) : _labelTextColor
            ret.backgroundColor = ("SLUG-PROPERTIES-NOTIFY".localizedVariant == inText) ? (characteristic.isNotifying ? .green : .red) : _labelBackgroundColor
            ret.font = .boldSystemFont(ofSize: _labelFontSize)
            ret.text = inText
            ret.minimumScaleFactor = 0.75
            ret.adjustsFontSizeToFitWidth = true
            
            return ret
        }
        
        /* ############################################################## */
        /**
         Returns a label, with The "WR" or "WN" filler, if supported. Otherwise, nil.
         */
        private var _writeLabel: UILabel! {
            if characteristic.canWriteWithResponse {
                return _makeLabel("SLUG-PROPERTIES-WRITE-RESPONSE".localizedVariant)
            } else if characteristic.canWriteWithoutResponse {
                return _makeLabel("SLUG-PROPERTIES-WRITE".localizedVariant)
            }
            return nil
        }

        /* ############################################################## */
        /**
         The Characteristic that is providing the Properties to inspect.
         */
        let characteristic: CGA_Bluetooth_Characteristic!
        
        /* ############################################################## */
        /**
         Returns an Array of labels, or nil.
         */
        var labels: [UILabel?] {
            [
                characteristic.canRead ? _makeLabel("SLUG-PROPERTIES-READ".localizedVariant) : nil,
                _writeLabel,
                characteristic.canIndicate ? _makeLabel("SLUG-PROPERTIES-INDICATE".localizedVariant) : nil,
                characteristic.canBroadcast ? _makeLabel("SLUG-PROPERTIES-BROADCAST".localizedVariant) : nil,
                characteristic.requiresAuthenticatedSignedWrites ? _makeLabel("SLUG-PROPERTIES-AUTH-SIGNED-WRITE".localizedVariant) : nil,
                characteristic.requiresNotifyEncryption ? _makeLabel("SLUG-PROPERTIES-NOTIFY-ENCRYPT".localizedVariant) : nil,
                characteristic.requiresNotifyEncryption ? _makeLabel("SLUG-PROPERTIES-INDICATE-ENCRYPT".localizedVariant) : nil,
                characteristic.hasExtendedProperties ? _makeLabel("SLUG-PROPERTIES-EXTENDED".localizedVariant) : nil,
                characteristic.canNotify ? _makeLabel("SLUG-PROPERTIES-NOTIFY".localizedVariant): nil
            ]
        }
    }
    
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
        
        tableCell.characteristicIDLabel?.textColor = UIColor(white: 0 < characteristic.count ? 1.0 : 0.75, alpha: 1.0)
        tableCell.characteristicIDLabel?.text = characteristic.id.localizedVariant
        
        // Populate the Properties view.
        tableCell.propertiesStackView.subviews.forEach { $0.removeFromSuperview() }
        tableCell.gestureRecognizers?.forEach { $0.removeTarget(nil, action: nil) }
        _PropertyLabelGenerator(characteristic: characteristic).labels.forEach {
            if let view = $0 {
                tableCell.propertiesStackView.addArrangedSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalTo: tableCell.propertiesStackView.heightAnchor).isActive = true
            }
        }
        
        // This is the double-tap gesture recognizer for bringing in the Descriptors.
        let gestureRecognizer = CG_TapGestureRecognizer(target: self, action: #selector(descriptorTapped(_:)))
        gestureRecognizer.cancelsTouchesInView = true
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.numberOfTapsRequired = 2
        
        if 0 < characteristic.count {   // Only if we have Descriptors.
            tableCell.addGestureRecognizer(gestureRecognizer)
        }

        // If we can notify, we add a throbber to the end. It will animate when we are notifying.
        if characteristic.canNotify {
            let view = UIActivityIndicatorView(style: .large)
            view.color = characteristic.isNotifying ? .green : .red
            view.hidesWhenStopped = true
            if characteristic.isNotifying {
                view.startAnimating()
            } else {
                view.stopAnimating()
            }
            
            tableCell.propertiesStackView.addArrangedSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalTo: tableCell.propertiesStackView.heightAnchor).isActive = true
            view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true

            // We add a single-touch gesture recognizer.
            let notifyGestureRecognizer = CG_TapGestureRecognizer(target: self, action: #selector(notifyTapped(_:)))
            notifyGestureRecognizer.cancelsTouchesInView = true
            notifyGestureRecognizer.numberOfTouchesRequired = 1
            notifyGestureRecognizer.numberOfTapsRequired = 1
            if 0 < characteristic.count {   // Only if we have Descriptors.
                notifyGestureRecognizer.require(toFail: gestureRecognizer)
            }
            
            tableCell.addGestureRecognizer(notifyGestureRecognizer)
        }
        
        tableCell.valueLabel.text = characteristic.stringValue ?? ""
        
        return tableCell
    }
}
