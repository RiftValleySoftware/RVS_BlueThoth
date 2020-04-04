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
// MARK: - The CGA_InitialViewController_TableRow Class (Denotes One Row of the Table) -
/* ###################################################################################################################################### */
/**
 This is a simple class that will be used to display one row in the initial discovery table.
 */
class CGA_InitialViewController_TableRow: UITableViewCell {
    /* ################################################################## */
    /**
     This will display the advertised name.
     */
    @IBOutlet var nameLabel:UILabel!

    /* ################################################################## */
    /**
     This will display the RSSI level.
     */
    @IBOutlet var rssiLabel: UILabel!

    /* ################################################################## */
    /**
     This will wrap a dynamically-generated series of labels that will display the advertising data.
     */
    @IBOutlet var advertisingDataView: UIView!
}

/* ###################################################################################################################################### */
// MARK: - The initial view controller (table of devices) -
/* ###################################################################################################################################### */
/**
 This controls the initial view, which is a basic table of discovered devices.
 
 There are two sections: BLE, and BR/EDR (Classic). Each section has rows of devices that fit in that Bluetooth mode.
 */
class CGA_InitialViewController: UIViewController {
    /* ################################################################## */
    /**
     These are the indexes for our sections.
     */
    private enum _SectionIndexes: Int {
        /// The BLE section index.
        case ble
        /// Because we are Int, this will have the number of sections (1-based).
        case numSections
    }
    
    /* ################################################################## */
    /**
     This is how high each section header will be.
     */
    private static let _sectionHeaderHeightInDisplayUnits: CGFloat = 21.0
    
    /* ################################################################## */
    /**
     This is how high the labels that comprise one row will need per line of text.
     */
    private static let _labelRowHeightInDisplayUnits: CGFloat = 21.0

    /* ################################################################## */
    /**
     The reuse ID that we use for creating new table cells.
     */
    private static let _deviceRowReuseID = "device-row"
    
    /* ################################################################## */
    /**
     The ID of the segue that is executed to display device details.
     */
    private static let _deviceDetailSegueID = "show-device-detail"

    /* ################################################################## */
    /**
     This implements a "pull to refresh."
     */
    private let _refreshControl = UIRefreshControl()
    
    /* ################################################################## */
    /**
     Used as a semaphore (yuck) to indicate that the Central was (or was not) scanning before the view disappeared.
     It is not used anywhere else.
     */
    private var _wasScanning: Bool = false
    
    /* ################################################################## */
    /**
     Returns the pushed device details screen. Nil, if none.
     */
    private var _currentDeviceScreen: CGA_DetailViewController! { navigationController?.topViewController as? CGA_DetailViewController }

    /* ################################################################## */
    /**
     This is the table that will list the discovered devices.
     */
    @IBOutlet weak var deviceTableView: UITableView!
    
    /* ################################################################## */
    /**
     This image is displayed if there is no bluetooth available.
     */
    @IBOutlet weak var noBTImage: UIImageView!
    
    /* ################################################################## */
    /**
     This will animate when the central is scanning.
     */
    @IBOutlet weak var scanningButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     This is called by the table's "pull to refresh" handler.
     
     When this is called, the Bluetooth subsystem wipes out all of its cached Peripherals, and starts over from scratch.
     
     - parameter: ignored.
     */
    @objc func startOver(_: Any) {
        CGA_AppDelegate.centralManager?.startOver()
        _refreshControl.endRefreshing()
    }
    
    /* ################################################################## */
    /**
     This is called when the "Scanning/Not Scanning" button is hit.
     
     - parameter: ignored.
     */
    @IBAction func scanningButtonHit(_: Any) {
        if CGA_AppDelegate.centralManager?.isScanning ?? false {
            CGA_AppDelegate.centralManager?.stopScanning()
        } else {
            CGA_AppDelegate.centralManager?.startScanning()
        }
        scanningButton.isEnabled = false
    }
}

/* ###################################################################################################################################### */
// MARK: - Overridden Superclass Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView?.refreshControl = _refreshControl
        _refreshControl.addTarget(self, action: #selector(startOver(_:)), for: .valueChanged)
        CGA_AppDelegate.centralManager = CGA_Bluetooth_CentralManager(delegate: self)
        navigationItem.backBarButtonItem?.title = navigationItem.backBarButtonItem?.title?.localizedVariant
        scanningButton.setTitle(scanningButton.title(for: .normal)?.localizedVariant, for: .normal)
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use this to hide the navBar.
     
     - parameter inAnimated: True, if the appearance is animated (we ignore this).
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        navigationController?.navigationBar.isHidden = true
        if _wasScanning {
            CGA_AppDelegate.centralManager?.restartScanning()
        }
        _updateUI()
        deviceTableView?.deselectAll(animated: true)
    }
    
    /* ################################################################## */
    /**
     Called just before the view disappears. We use this to show the navBar.
     
     - parameter inAnimated: True, if the appearance is animated (we ignore this).
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        _wasScanning = CGA_AppDelegate.centralManager?.isScanning ?? false
        CGA_AppDelegate.centralManager?.stopScanning()
        navigationController?.navigationBar.isHidden = false
    }
    
    /* ################################################################## */
    /**
     This is called just before we bring in the device screen (or the about screen).
     
     - parameter for: The segue being executed.
     - parameter sender: The data we want passed into the destination.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        // We only go further if we are looking at device details.
        guard   let destination = inSegue.destination as? CGA_DetailViewController,
                let senderData = inSender as? CGA_Bluetooth_CentralManager.DiscoveryData else { return }
        
        destination.deviceAdvInfo = senderData
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_InitialViewController {
    /* ################################################################## */
    /**
     This creates an Array of String, containing the advertisement data from the indexed device.
     
     - parameter inIndex: The 0-based index of the device to fetch.
     - returns: An Array of String, with the advertisement data in "key: value" form.
     */
    private func _createAdvertimentStringsFor(_ inIndex: Int) -> [String] {
        if  let centralManager = CGA_AppDelegate.centralManager,
            (0..<centralManager.stagedBLEPeripherals.count).contains(inIndex) {
            let id = centralManager.stagedBLEPeripherals[inIndex].identifier
            let adData = centralManager.stagedBLEPeripherals[inIndex].advertisementData
            
            // This gives us a predictable order of things.
            let sortedAdDataKeys = adData.keys.sorted()
            let sortedAdData: [(key: String, value: Any?)] = sortedAdDataKeys.compactMap { (key:$0, value: adData[$0]) }

            let retStr = sortedAdData.reduce("SLUG-ID".localizedVariant + ": \(id)") { (current, next) in
                let key = next.key.localizedVariant
                let value = next.value
                var ret = "\(current)\n"
                
                if let asStringArray = value as? [String] {
                    ret += current + asStringArray.reduce("\(key): ") { (current2, next2) in
                        return "\(current2)\n\(next2.localizedVariant)"
                    }
                } else if let value = value as? String {
                    ret += "\(key): \(value.localizedVariant)"
                } else if let value = value as? Bool {
                    ret += "\(key): \(value ? "true" : "false")"
                } else if let value = value as? Int {
                    ret += "\(key): \(value)"
                } else if let value = value as? Double {
                    if "kCBAdvDataTimestamp" == next.key {  // If it's the timestamp, we can translate that, here.
                        let date = Date(timeIntervalSinceReferenceDate: value)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "SLUG-MAIN-LIST-DATE-FORMAT".localizedVariant
                        let displayedDate = dateFormatter.string(from: date)
                        ret += "\(key): \(displayedDate)"
                    } else {
                        ret += "\(key): \(value)"
                    }
                } else {    // Anything else is just a described instance of something or other.
                    ret += "\(key): \(String(describing: value))"
                }
                
                return ret
            }.split(separator: "\n").map { String($0) }
            
            return retStr
        }
        return []
    }
    
    /* ################################################################## */
    /**
     This simply makes sure that the table is displayed if BT is available, or the "No BT" image is shown, if it is not.
     */
    private func _updateUI() {
        let isBTAvailable = CGA_AppDelegate.centralManager?.isBTAvailable ?? false
        if !isBTAvailable { // Make sure that we are at the initial view, if BT is not available.
            navigationController?.popToRootViewController(animated: false)
        }
        
        noBTImage.isHidden = isBTAvailable
        deviceTableView?.isHidden = !isBTAvailable

        if  isBTAvailable,
            CGA_AppDelegate.centralManager?.isScanning ?? false {
            scanningButton.backgroundColor = UIColor(red: 0, green: 0.75, blue: 0, alpha: 1.0)
            scanningButton.setTitle(" " + "SLUG-SCANNING".localizedVariant + " ", for: .normal)
        } else {
            scanningButton.backgroundColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1.0)
            scanningButton.setTitle(" " + "SLUG-NOT-SCANNING".localizedVariant + " ", for: .normal)
        }
        
        scanningButton.isEnabled = true
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_Bluetooth_CentralManagerDelegate Support -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: CGA_Bluetooth_CentralManagerDelegate {
    /* ################################################################## */
    /**
     Called to report an error.
     
     - parameter inError: The error being reported.
     - parameter from: The manager wrapper view that is calling this.
     */
    func handleError(_ inError: Error, from inCentralManager: CGA_Bluetooth_CentralManager) {
        CGA_AppDelegate.displayAlert("SLUG-ERROR".localizedVariant, message: inError.localizedDescription.localizedVariant)
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that the state of the Central manager just became "powered on."
     
     - parameter inCentralManager: The central manager that is calling this.
     */
    func centralManagerPoweredOn(_ inCentralManager: CGA_Bluetooth_CentralManager) {
        inCentralManager.startScanning()
    }

    /* ################################################################## */
    /**
     Called to tell this controller to recalculate its table.
     
     - parameter inCentralManager: The manager wrapper view that is calling this.
     */
    func updateFrom(_ inCentralManager: CGA_Bluetooth_CentralManager) {
        _updateUI()
        deviceTableView?.reloadData()
    }
    
    /* ################################################################## */
    /**
     Called to tell the instance that a new Peripheral device has been added and connected.
     
     - parameter inCentralManager: The central manager that is calling this.
     - parameter addedDevice: The device instance that was added (and connected).
     */
    func centralManager(_ inCentralManager: CGA_Bluetooth_CentralManager, addedDevice inDevice: CGA_Bluetooth_Peripheral) {
        _currentDeviceScreen?.deviceInstance = inDevice
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Support -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     This returns the number of available sections.
     
     There will be 2 sections: Classic, and BLE.
     
     - parameter in: The table view that is asking for the section count.
     */
    func numberOfSections(in inTableView: UITableView) -> Int { _SectionIndexes.numSections.rawValue }
    
    /* ################################################################## */
    /**
     This returns the height of the requested section header.
     
     - parameter inTableView: The table view that is asking for the header (ignored).
     - parameter heightForHeaderInSection: The 0-based section index being queried (ignored).
     - returns: The height, in display units, of the header for the section.
     */
    func tableView(_ inTableView: UITableView, heightForHeaderInSection inSection: Int) -> CGFloat { Self._sectionHeaderHeightInDisplayUnits }
    
    /* ################################################################## */
    /**
     Returns a section header.
     
     - parameter inTableView: The table view that is asking for the header.
     - parameter viewForHeaderInSection: The 0-based section index being queried.
     - returns: The header for the section, as a view (a label).
     */
    func tableView(_ inTableView: UITableView, viewForHeaderInSection inSection: Int) -> UIView? {
        guard 1 < _SectionIndexes.numSections.rawValue else { return nil }
        
        let ret = UILabel()
        
        ret.text = ("SLUG-SECTION-HEADER-" + (_SectionIndexes.ble.rawValue == inSection ? "BLE" : "CLASSIC")).localizedVariant
        ret.textColor = .blue
        ret.textAlignment = .center
        ret.backgroundColor = .white
        ret.font = .boldSystemFont(ofSize: Self._sectionHeaderHeightInDisplayUnits)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter numberOfRowsInSection: The 0-based section index being queried.
     - returns: The number of rows in the given section.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        guard  let centralManager = CGA_AppDelegate.centralManager,
                _SectionIndexes.ble.rawValue == inSection,
                !centralManager.stagedBLEPeripherals.isEmpty
        else { return 0 }
       
        return centralManager.stagedBLEPeripherals.count
    }
    
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter heightForRowAt: The index of the row.
     - returns: The height of the row, in display units.
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        guard  let centralManager = CGA_AppDelegate.centralManager,
            (0..<centralManager.stagedBLEPeripherals.count).contains(inIndexPath.row)
        else { return 0.0 }
        
        return (Self._labelRowHeightInDisplayUnits) + (CGFloat(_createAdvertimentStringsFor(inIndexPath.row).count) * Self._labelRowHeightInDisplayUnits)
    }
    
    /* ################################################################## */
    /**
     This returns a view, with the data for the given row and section.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter cellForRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        /* ################################################################## */
        /**
         This allows us to easily add a new subview to a view, and keep it tied to the one above.
         
         - parameter inSubView: The view we are adding.
         - parameter to: The view we are embedding it in.
         - parameter under: The bottom constraint of the view just above this one.
         - returns: The bottom anchor of the embedded view (to be used as "under" in the next iteration).
         */
        func _addContainedSubView(_ inSubView: UIView, to inToView: UIView, under inUnderAnchor: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor {
            inToView.addSubview(inSubView)
            
            inSubView.translatesAutoresizingMaskIntoConstraints = false
            
            inSubView.topAnchor.constraint(equalTo: inUnderAnchor, constant: 0).isActive = true
            inSubView.leadingAnchor.constraint(equalTo: inToView.leadingAnchor, constant: 0).isActive = true
            inSubView.trailingAnchor.constraint(equalTo: inToView.trailingAnchor, constant: 0).isActive = true
            
            return inSubView.bottomAnchor
        }

        let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self._deviceRowReuseID, for: inIndexPath)
        
        // We populate the cell dynamically, creating new labels for each of the advertising data rows.
        if  let tableCell = tableCell as? CGA_InitialViewController_TableRow,
            let centralManager = CGA_AppDelegate.centralManager,
            (0..<centralManager.stagedBLEPeripherals.count).contains(inIndexPath.row) {
            let fontColor = UIColor(white: centralManager.stagedBLEPeripherals[inIndexPath.row].canConnect ? 1.0 : 0.75, alpha: 1.0)
            tableCell.nameLabel?.textColor = fontColor
            tableCell.rssiLabel?.textColor = fontColor
            tableCell.nameLabel?.text = centralManager.stagedBLEPeripherals[inIndexPath.row].name
            tableCell.rssiLabel?.text = String(format: "(%d dBm)", centralManager.stagedBLEPeripherals[inIndexPath.row].rssi)
            let advertisingData = _createAdvertimentStringsFor(inIndexPath.row)
            if  let containerView = tableCell.advertisingDataView {
                containerView.subviews.forEach { $0.removeFromSuperview() }
                var topAnchor: NSLayoutYAxisAnchor = containerView.topAnchor

                // Each row of advertising data is turned into a new label, which is added to the container view; just under the previous label.
                advertisingData.forEach {
                    if !$0.isEmpty {
                        let bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: containerView.bounds.size.width, height: Self._labelRowHeightInDisplayUnits))
                        let newLabel = UILabel(frame: bounds)
                        newLabel.text = $0
                        newLabel.adjustsFontSizeToFitWidth = true
                        newLabel.minimumScaleFactor = 0.75
                        newLabel.font = .systemFont(ofSize: Self._labelRowHeightInDisplayUnits * 0.75)
                        newLabel.textColor = fontColor
                        topAnchor = _addContainedSubView(newLabel, to: containerView, under: topAnchor)
                    }
                }
            
                // Tie the last one off to the bottom of the view.
                topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
            }
        }
        
        return tableCell
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Support -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called to test whether or not to allow a row to be selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter willSelectRowAt: The index path (section, row) for the cell.
     - returns: The IndexPath of the cell, if approved, or nil, if not.
     */
    func tableView(_ inTableView: UITableView, willSelectRowAt inIndexPath: IndexPath) -> IndexPath? {
        if  let centralManager = CGA_AppDelegate.centralManager,
            centralManager.stagedBLEPeripherals[inIndexPath.row].canConnect {
            return inIndexPath
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     Called to test whether or not to allow a row to be higlighted.
     
     This prevents the unselectable row from "flashing" when someone touches it.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter shouldHighlightRowAt: The index path (section, row) for the cell.
     - returns: The IndexPath of the cell, if approved, or nil, if not.
     */
    func tableView(_ inTableView: UITableView, shouldHighlightRowAt inIndexPath: IndexPath) -> Bool {
        return nil != tableView(inTableView, willSelectRowAt: inIndexPath)
    }
    
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter didSelectRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        if let centralManager = CGA_AppDelegate.centralManager {
            performSegue(withIdentifier: Self._deviceDetailSegueID, sender: centralManager.stagedBLEPeripherals[inIndexPath.row])
        }
    }
    
    /* ################################################################## */
    /**
     Indicate that a row can be edited (for left-swipe delete).
     
     - parameter: Ignored
     - parameter canEditRowAt: Ignored
     
     - returns: true, always.
     */
    func tableView(_: UITableView, canEditRowAt: IndexPath) -> Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     Called to do a delete action.
     
     - parameter inTableView: The table view being checked
     - parameter commit: The action to perform.
     - parameter forRowAt: The indexpath of the row to be deleted.
     */
    func tableView(_ inTableView: UITableView, commit inEditingStyle: UITableViewCell.EditingStyle, forRowAt inIndexPath: IndexPath) {
        if  inEditingStyle == UITableViewCell.EditingStyle.delete,
            let centralManager = CGA_AppDelegate.centralManager {
            centralManager.stagedBLEPeripherals[inIndexPath.row].ignore()
            inTableView.reloadData()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableView Extension -
/* ###################################################################################################################################### */
extension UITableView {
    /* ################################################################## */
    /**
     This will deselect all selected rows.
     
     - parameter animated: This can be ignored (defaults to false). If true, the deselection is animated.
     - returns: an Array of IndexPath, denoting the rows that were deselected. Can be ignored.
     */
    @discardableResult
    func deselectAll(animated inAnimated: Bool = false) -> [IndexPath] {
        if  let indexPaths = indexPathsForSelectedRows,
            !indexPaths.isEmpty {
            indexPaths.forEach {
                deselectRow(at: $0, animated: inAnimated)
            }
            
            return indexPaths
        }
        return []
    }
}
