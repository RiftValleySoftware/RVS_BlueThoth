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
class CGA_PeripheralViewController: UIViewController {
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
     This contains the device discovery data.
     */
    var deviceAdvInfo: CGA_Bluetooth_CentralManager.DiscoveryData!
    
    /* ################################################################## */
    /**
     This contains the device instance, once the connection is successful. It is a weak reference.
     */
    weak var deviceInstance: CGA_Bluetooth_Peripheral? { deviceAdvInfo?.peripheralInstance }
    
    /* ################################################################## */
    /**
     This is the table that will list the discovered devices.
     */
    @IBOutlet weak var deviceTableView: UITableView!
    
    /* ################################################################## */
    /**
     This is the "Busy" animation that is displayed while the device connects.
     */
    @IBOutlet weak var busyAnimationActivityIndicatorView: UIActivityIndicatorView!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_PeripheralViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the device.
     */
    func updateUI() {
        if nil != deviceInstance {
            busyAnimationActivityIndicatorView?.stopAnimating()
            deviceTableView?.isHidden = false
            deviceTableView?.reloadData()
        } else {
            busyAnimationActivityIndicatorView?.startAnimating()
            deviceTableView?.isHidden = true
        }
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
        guard let device = deviceAdvInfo else { return }
        updateUI()
        device.connect()
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
