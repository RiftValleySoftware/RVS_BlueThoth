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
import RVS_BlueThoth_iOS

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
    
    /* ################################################################## */
    /**
     This is the view that we will be highlighting.
     */
    var backgroundView: UIView!
}

/* ###################################################################################################################################### */
// MARK: - A Special Button for Table Rows (NOTIFY) -
/* ###################################################################################################################################### */
/**
 This simply allows us to attach a row index to a button, so we know which Characteristic to use.
 */
class CG_TappableButton: UIButton {
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
class CGA_ServiceViewController: CGA_BaseViewController {
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
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_ServiceViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    private func _setUpAccessibility() {
        characteristicsTableView?.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-TABLE".localizedVariant
    }
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
     This is a button callback for a tap in the read button, and the Characteristic can read.
     It toggles the notify state of the Characteristic.
     
     - parameter inButton: The special button, with our row index.
     */
    @objc func readTapped(_ inButton: CG_TappableButton) {
        if let characteristicInstance = serviceInstance?[inButton.rowIndex] {
            characteristicInstance.readValue()
        }
    }
    
    /* ################################################################## */
    /**
     This is a button callback for a tap in the notify button, and the Characteristic can notify.
     It toggles the notify state of the Characteristic.
     
     - parameter inButton: The special button, with our row index.
     */
    @objc func notifyTapped(_ inButton: CG_TappableButton) {
        if  let characteristicInstance = serviceInstance?[inButton.rowIndex] {
            let title = "SLUG-PROPERTIES-NOTIFY-\(characteristicInstance.isNotifying ? "OFF" : "ON")"
            inButton.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-ROW-\(title)".localizedVariant
            if characteristicInstance.isNotifying {
                characteristicInstance.stopNotifying()
            } else {
                characteristicInstance.startNotifying()
            }
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
            inGestureRecognizer.backgroundView.backgroundColor = UIColor(cgColor: prefs.tableSelectionBackgroundColor)
            performSegue(withIdentifier: Self._characteristicDetailSegueID, sender: characteristic)
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
        _setUpAccessibility()
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
    }
    
    /* ################################################################## */
    /**
     Called just before the view will appear.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        characteristicsTableView?.reloadData()
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
        let labelTextColor: UIColor
        
        /* ############################################################## */
        /**
         The color of the label text.
         */
        private let _labelBackgroundColor = UIColor(white: 1.0, alpha: CGA_AppDelegate.appDelegateObject?.prefs.textColorForUnselectableCells ?? 0)

        /* ############################################################## */
        /**
         A simple "factory" for the Read button.
         */
        private func _makeReadButton() -> UIButton {
            let ret = CG_TappableButton()
            let title = "SLUG-PROPERTIES-READ"
            ret.setTitle(title.localizedVariant, for: .normal)
            ret.setTitleColor(labelTextColor, for: .normal)
            ret.backgroundColor = .white
            ret.addTarget(ownerViewController, action: #selector(readTapped(_:)), for: .touchUpInside)
            ret.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-ROW-\(title)".localizedVariant
            return ret
        }
        
        /* ############################################################## */
        /**
         A simple "factory" for the Notification button.
         */
        private func _makeNotifyButton() -> UIButton {
            let ret = CG_TappableButton()
            let title = "SLUG-PROPERTIES-NOTIFY-\(characteristic.isNotifying ? "ON" : "OFF")"
            ret.setTitle(title.localizedVariant, for: .normal)
            ret.setTitleColor(characteristic.isNotifying ? labelTextColor : .white, for: .normal)
            ret.backgroundColor = characteristic.isNotifying ? .green : .red
            ret.addTarget(ownerViewController, action: #selector(notifyTapped(_:)), for: .touchUpInside)
            ret.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-ROW-\(title)".localizedVariant
            return ret
        }

        /* ############################################################## */
        /**
         A simple "factory" for the label.
         */
        private func _makeLabel(_ inText: String) -> UILabel {
            let ret = UILabel()
            ret.textColor = labelTextColor
            ret.backgroundColor = _labelBackgroundColor
            ret.font = .boldSystemFont(ofSize: UIAccessibility.isDarkerSystemColorsEnabled ? _labelFontSize * 1.5 : _labelFontSize)
            ret.text = inText.localizedVariant
            ret.minimumScaleFactor = 0.75
            ret.adjustsFontSizeToFitWidth = true
            ret.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-ROW-\(inText)".localizedVariant

            return ret
        }
        
        /* ############################################################## */
        /**
         Returns a label, with The "WR" or "WN" filler, if supported. Otherwise, nil.
         */
        private var _writeLabel: UIView! {
            if characteristic.canWriteWithResponse {
                return _makeLabel("SLUG-PROPERTIES-WRITE-RESPONSE")
            } else if characteristic.canWriteWithoutResponse {
                return _makeLabel("SLUG-PROPERTIES-WRITE")
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
         This will be set to the containing View ViewController, so we can target it.
         */
        let ownerViewController: CGA_ServiceViewController!
        
        /* ############################################################## */
        /**
         Returns an Array of views (labels, but including maybe one button), or nil.
         */
        var labels: [UIView?] {
            [
                characteristic.canRead ? _makeReadButton() : nil,
                _writeLabel,
                characteristic.canIndicate ? _makeLabel("SLUG-PROPERTIES-INDICATE") : nil,
                characteristic.canBroadcast ? _makeLabel("SLUG-PROPERTIES-BROADCAST") : nil,
                characteristic.requiresAuthenticatedSignedWrites ? _makeLabel("SLUG-PROPERTIES-AUTH-SIGNED-WRITE") : nil,
                characteristic.requiresNotifyEncryption ? _makeLabel("SLUG-PROPERTIES-NOTIFY-ENCRYPT") : nil,
                characteristic.requiresNotifyEncryption ? _makeLabel("SLUG-PROPERTIES-INDICATE-ENCRYPT") : nil,
                characteristic.hasExtendedProperties ? _makeLabel("SLUG-PROPERTIES-EXTENDED") : nil,
                characteristic.canNotify ? _makeNotifyButton() : nil  // Notify goes on the end, because it's a big-ass button, and will move things around.
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
        
        // Remove any existing gesture recognizers.
        tableCell.gestureRecognizers?.forEach { $0.removeTarget(nil, action: nil) }
        // Remove any previous views in the properties stack.
        tableCell.propertiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        tableCell.backgroundColor = .clear
        
        // We set the ID label.
        tableCell.characteristicIDLabel?.textColor = UIColor(white: 1.0, alpha: 0 < characteristic.count ? 1.0 : prefs.textColorForUnselectableCells)
        tableCell.characteristicIDLabel?.text = characteristic.id.localizedVariant
        tableCell.characteristicIDLabel?.accessibilityLabel = String(format: "SLUG-ACC-CHARACTERISTIC-ROW-ID-NO-DESCRIPTORS-FORMAT".localizedVariant, characteristic.id.localizedVariant)
        tableCell.valueLabel?.accessibilityLabel = String(format: "SLUG-ACC-CHARACTERISTIC-ROW-VALUE-NO-DESCRIPTORS-FORMAT".localizedVariant, characteristic.stringValue ??
                                                            (nil != characteristic.value ? String(describing: characteristic.value) : ""))

        // Populate the Properties view.
        _PropertyLabelGenerator(labelTextColor: isDarkMode ? .black : .blue, characteristic: characteristic, ownerViewController: self).labels.forEach {
            if let view = $0 {
                tableCell.propertiesStackView?.addArrangedSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.heightAnchor.constraint(equalTo: tableCell.propertiesStackView!.heightAnchor).isActive = true
                // The notify button gets a row index attached.
                if let button = view as? CG_TappableButton {
                    button.rowIndex = inIndexPath.row
                }
                var accessibilityElements = tableCell.propertiesStackView?.accessibilityElements ?? []
                accessibilityElements.append(view)
                tableCell.propertiesStackView?.accessibilityElements = accessibilityElements
            }
        }

        // This is a single-tap gesture recognizer for bringing in the Descriptors. It is attached to the table cell, in general.
        if 0 < characteristic.count {   // Only if we have Descriptors.
            let tapGestureRecognizer = CG_TapGestureRecognizer(target: self, action: #selector(descriptorTapped(_:)))
            tapGestureRecognizer.rowIndex = inIndexPath.row
            tapGestureRecognizer.backgroundView = tableCell
            tableCell.characteristicIDLabel?.accessibilityLabel = String(format: "SLUG-ACC-CHARACTERISTIC-ROW-ID-FORMAT".localizedVariant, characteristic.id.localizedVariant)
            tableCell.valueLabel?.accessibilityLabel = String(format: "SLUG-ACC-CHARACTERISTIC-ROW-VALUE-FORMAT".localizedVariant, characteristic.stringValue ??
                                                                (nil != characteristic.value ? String(describing: characteristic.value) : ""))
            tapGestureRecognizer.accessibilityLabel = "SLUG-ACC-CHARACTERISTIC-ROW".localizedVariant
            tableCell.addGestureRecognizer(tapGestureRecognizer)
        }
        
        // If there is a String-convertible value, we display it. Otherwise, we either display a described Data item, or blank.
        tableCell.valueLabel?.text = characteristic.stringValue ?? (nil != characteristic.value ? String(describing: characteristic.value) : "")
        
        tableCell.accessibilityElements = [tableCell.characteristicIDLabel!, tableCell.propertiesStackView!, tableCell.valueLabel!]

        return tableCell
    }
}
