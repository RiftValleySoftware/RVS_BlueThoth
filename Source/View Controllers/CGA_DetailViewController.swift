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
class CGA_DetailViewController_TableRow: UITableViewCell {
}

/* ###################################################################################################################################### */
// MARK: - The initial view controller (table of services) -
/* ###################################################################################################################################### */
/**
 This controls the initial view, which is a basic table of discovered Services.
 */
class CGA_DetailViewController: UIViewController {
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
    private static let _deviceRowReuseID = "detail-row"

    /* ################################################################## */
    /**
     This implements a "pull to refresh."
     */
    private let _refreshControl = UIRefreshControl()

    /* ################################################################## */
    /**
     This contains the device discovery data.
     */
    var deviceAdvInfo: CGA_Bluetooth_CentralManager.DiscoveryData!
    
    /* ################################################################## */
    /**
     This contains the device instance, once the connection is successful. It is a weak reference.
     */
    weak var deviceInstance: CGA_Bluetooth_Peripheral? {
        didSet {
            updateUI()
        }
    }
    
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
extension CGA_DetailViewController {
    /* ################################################################## */
    /**
     This is called by the table's "pull to refresh" handler.
     
     When this is called, the Bluetooth subsystem wipes out all of its cached Peripherals, and starts over from scratch.
     
     - parameter: ignored.
     */
    @objc func refresh(_: Any) {
        _refreshControl.endRefreshing()
    }
    
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
extension CGA_DetailViewController {
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView?.refreshControl = _refreshControl
        _refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        navigationItem.title = deviceAdvInfo?.preferredName
    }
    
    /* ################################################################## */
    /**
     Called just before the view is to appear.
     We use this to initiate a connection.
     
     - parameter inAnimated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        guard let device = deviceAdvInfo else { return }
        device.connect()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view is to disappear.
     We use this to close a connection.

     - parameter inAnimated: True, if the appearance is animated.
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
        guard let device = deviceAdvInfo else { return }
        device.disconnect()
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_DetailViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     This returns the number of available sections.
     
     There will be 2 sections: Classic, and BLE.
     
     - parameter in: The table view that is asking for the section count.
     */
    func numberOfSections(in inTableView: UITableView) -> Int { 1 }
    
    /* ################################################################## */
    /**
     This returns the height of the requested section header.
     
     - parameter inTableView: The table view that is asking for the header (ignored).
     - parameter heightForHeaderInSection: The 0-based section index being queried (ignored).
     - returns: The height, in display units, of the header for the section.
     */
    func tableView(_ inTableView: UITableView, heightForHeaderInSection inSection: Int) -> CGFloat {
        Self._sectionHeaderHeightInDisplayUnits
    }
    
    /* ################################################################## */
    /**
     Returns a section header.
     
     - parameter inTableView: The table view that is asking for the header.
     - parameter viewForHeaderInSection: The 0-based section index being queried.
     - returns: The header for the section, as a view (a label).
     */
    func tableView(_ inTableView: UITableView, viewForHeaderInSection inSection: Int) -> UIView? {
        if 1 < numberOfSections(in: inTableView) {
            let ret = UILabel()
            
            ret.text = "ERROR"
            ret.textColor = .blue
            ret.textAlignment = .center
            ret.backgroundColor = .white
            ret.font = .boldSystemFont(ofSize: Self._sectionHeaderHeightInDisplayUnits)
            
            return ret
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter numberOfRowsInSection: The 0-based section index being queried.
     - returns: The number of rows in the given section.
     */
    func tableView(_ inTableView: UITableView, numberOfRowsInSection inSection: Int) -> Int {
        return 0
    }
    
    /* ################################################################## */
    /**
     This returns the number of available rows, in the given section.
     
     - parameter inTableView: The table view that is asking for the row count.
     - parameter heightForRowAt: The index of the row.
     - returns: The height of the row, in display units.
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        return Self._labelRowHeightInDisplayUnits
    }
    
    /* ################################################################## */
    /**
     This returns a view, with the data for the given row and section.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter cellForRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self._deviceRowReuseID, for: inIndexPath)
        
        return tableCell
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_DetailViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter didSelectRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        inTableView.deselectRow(at: inIndexPath, animated: false)
    }
}
