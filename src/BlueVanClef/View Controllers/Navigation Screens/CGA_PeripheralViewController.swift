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
// MARK: - The CGA_PeripheralViewController_TableRow Class (Denotes One Row of the Table) -
/* ###################################################################################################################################### */
/**
 This is the class that defines one row of the table that displays the Services.
 */
class CGA_PeripheralViewController_TableRow: UITableViewCell {
    /* ################################################################## */
    /**
     The label that we use to display the Service ID.
     */
    @IBOutlet weak var serviceIDLabel: UILabel!
}

/* ###################################################################################################################################### */
// MARK: - The initial view controller (table of services) -
/* ###################################################################################################################################### */
/**
 This controls the Peripheral Information View.
 */
class CGA_PeripheralViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     The reuse ID that we use for creating new table cells.
     */
    private static let _deviceRowReuseID = "detail-row"
    
    /* ################################################################## */
    /**
     The ID of the segue that is executed to display Service details.
     */
    private static let _serviceDetailSegueID = "show-service-detail"
    
    /* ################################################################## */
    /**
     This implements a "pull to refresh."
     */
    private let _refreshControl = UIRefreshControl()

    /* ################################################################## */
    /**
     This contains the device discovery data.
     */
    var deviceAdvInfo: RVS_BlueThoth.DiscoveryData!
    
    /* ################################################################## */
    /**
     This contains the device instance, once the connection is successful. It is a weak reference.
     */
    weak var deviceInstance: CGA_Bluetooth_Peripheral? { deviceAdvInfo?.peripheralInstance }
    
    /* ################################################################## */
    /**
     This is the table that will list the discovered devices.
     */
    @IBOutlet weak var serviceTableView: UITableView!
    
    /* ################################################################## */
    /**
     This is the "Busy" animation that is displayed while the device connects.
     */
    @IBOutlet weak var busyAnimationActivityIndicatorView: UIActivityIndicatorView!
    
    /* ################################################################## */
    /**
     The label that displays the "CONNECTING..." message.
     */
    @IBOutlet weak var connectingLabel: UILabel!
    
    /* ################################################################## */
    /**
     The stack view that contains all the device information.
     */
    @IBOutlet weak var deviceInfoTextView: UITextView!
    
    /* ################################################################## */
    /**
     The label for the Services table.
     */
    @IBOutlet weak var servicesLabel: UILabel!
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_PeripheralViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    private func _setUpAccessibility() {
        navigationItem.accessibilityLabel = String(format: "SLUG-ACC-DEVICE-NAME-FORMAT".localizedVariant, deviceAdvInfo?.preferredName ?? "ERROR")
        connectingLabel?.accessibilityLabel = "SLUG-ACC-CONNECTING-LABEL".localizedVariant
        busyAnimationActivityIndicatorView?.accessibilityLabel = "SLUG-ACC-CONNECTING-LABEL".localizedVariant
        deviceInfoTextView?.accessibilityLabel = "SLUG-ACC-DEVICE-INFO-TEXT-DISPLAY".localizedVariant
        serviceTableView?.accessibilityLabel = "SLUG-ACC-SERVICES-TABLE".localizedVariant
        // This sets the order of the elements in voiceover.
        view.accessibilityElements = (nil == deviceInstance) ? [navigationItem, connectingLabel!] : [navigationItem, deviceInfoTextView!, serviceTableView!]
    }
}

/* ###################################################################################################################################### */
// MARK: - Callback/Observer Methods -
/* ###################################################################################################################################### */
extension CGA_PeripheralViewController {
    /* ################################################################## */
    /**
     This is called by the table's "pull to refresh" handler.
     
     When this is called, the Peripheral wipes out its Services, and starts over from scratch.
     
     - parameter: ignored.
     */
    @objc func startOver(_: Any) {
        deviceAdvInfo?.peripheralInstance?.startOver()
        _refreshControl.endRefreshing()
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_PeripheralViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the device.
     */
    func updateUI() {
        if let deviceInstance = deviceInstance {
            // Make sure the main sections are displayed.
            busyAnimationActivityIndicatorView?.stopAnimating()
            deviceInfoTextView?.isHidden = false
            connectingLabel?.isHidden = true
            serviceTableView?.isHidden = false
            servicesLabel?.isHidden = false
            
            // Fill in the discovery data section.
            let id = deviceInstance.discoveryData.identifier
            let adData = deviceInstance.discoveryData.advertisementData
        
            let advertisementStrings = CGA_AppDelegate.createAdvertimentStringsFor(adData, id: id)
            deviceInfoTextView.text = advertisementStrings.joined(separator: "\n")
            
            serviceTableView?.reloadData()
        } else {    // Hide everything except the "loading" stuff.
            busyAnimationActivityIndicatorView?.startAnimating()
            deviceInfoTextView?.isHidden = true
            connectingLabel?.isHidden = false
            serviceTableView?.isHidden = true
            servicesLabel?.isHidden = true
        }
        
        _setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension CGA_PeripheralViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = deviceAdvInfo?.preferredName
        serviceTableView?.refreshControl = _refreshControl
        connectingLabel?.text = connectingLabel?.text?.localizedVariant ?? "ERROR"
        servicesLabel?.text = servicesLabel?.text?.localizedVariant ?? "ERROR"
        _refreshControl.addTarget(self, action: #selector(startOver(_:)), for: .valueChanged)
        guard let device = deviceAdvInfo else { return }
        updateUI()
        device.connect()
    }
    
    /* ################################################################## */
    /**
     Called just before the view is to disappear (slide out, usually, or get covered).
     We use this to make sure that any connection timeouts are canceled.
     
     - parameter inAnimated: This is true, if the disappearance is to be animated.
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        deviceAdvInfo?.clear()
    }
    
    /* ################################################################## */
    /**
     Called just before the view is to appear.
     
     - parameter inAnimated: This is true, if the disappearance is to be animated.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        updateUI()
    }
    
    /* ################################################################## */
    /**
     This is called just before we bring in the Service screen.
     
     - parameter for: The segue being executed.
     - parameter sender: The data we want passed into the destination.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        // We only go further if we are looking at device details.
        guard   let destination = inSegue.destination as? CGA_ServiceViewController,
                let senderData = inSender as? CGA_Bluetooth_Service else { return }
        
        navigationItem.accessibilityLabel = "SLUG-ACC-BACK-BUTTON".localizedVariant
        destination.serviceInstance = senderData
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_PeripheralViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter numberOfRowsInSection: The 0-based section index being queried.
     - returns: The number of rows in the given section.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int { deviceInstance?.count ?? 0 }
    
    /* ################################################################## */
    /**
     This returns a view, with the data for the given row and section.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter cellForRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        guard let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self._deviceRowReuseID, for: inIndexPath) as? CGA_PeripheralViewController_TableRow else { return UITableViewCell() }
        
        tableCell.serviceIDLabel?.text = deviceInstance?[inIndexPath.row].id.localizedVariant ?? "ERROR"
        
        // This ensures that we maintain a consistent backround color upon selection.
        tableCell.selectedBackgroundView = UIView()
        tableCell.selectedBackgroundView?.backgroundColor = UIColor(cgColor: prefs.tableSelectionBackgroundColor)

        tableCell.accessibilityLabel = String(format: "SLUG-ACC-SERVICES-TABLE-ROW".localizedVariant, deviceInstance?[inIndexPath.row].id.localizedVariant ?? "ERROR")
        return tableCell
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_PeripheralViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter didSelectRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        performSegue(withIdentifier: Self._serviceDetailSegueID, sender: deviceInstance?[inIndexPath.row])
        inTableView.deselectRow(at: inIndexPath, animated: false)
    }
}
