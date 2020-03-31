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
 */
class CGA_InitialViewController_TableRow: UITableViewCell {
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var rssiLabel: UILabel!
    @IBOutlet var advertisingDataLabel: UILabel!
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
     This implements a "pull to refresh."
     */
    private let _refreshControl = UIRefreshControl()
    
    /* ################################################################## */
    /**
     This is the table that will list the discovered devices.
     */
    @IBOutlet weak var deviceTableView: UITableView!
    
    /* ################################################################## */
    /**
     Called after the view data has been loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView?.refreshControl = _refreshControl
        _refreshControl.addTarget(self, action: #selector(startOver(_:)), for: .valueChanged)
        CGA_AppDelegate.centralManager = CGA_Bluetooth_CentralManager(delegate: self)
    }
    
    /* ################################################################## */
    /**
     */
    @objc func startOver(_ sender: Any) {
        CGA_AppDelegate.centralManager?.startOver()
        _refreshControl.endRefreshing()
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
    }
    
    /* ################################################################## */
    /**
     Called to tell this controller to recalculate its table.
     
     - parameter inCentralManager: The manager wrapper view that is calling this.
     */
    func updateFrom(_ inCentralManager: CGA_Bluetooth_CentralManager) {
        deviceTableView?.reloadData()
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
        if  let centralManager = CGA_AppDelegate.centralManager {
            if  _SectionIndexes.ble.rawValue == inSection,
                !centralManager.stagedBLEPeripherals.isEmpty {
                return centralManager.stagedBLEPeripherals.count
            }
        }
        
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
        if  let centralManager = CGA_AppDelegate.centralManager,
            (0..<centralManager.stagedBLEPeripherals.count).contains(inIndexPath.row) {
            let count = CGFloat(centralManager.stagedBLEPeripherals[inIndexPath.row].advertisementData.count)
            return (Self._labelRowHeightInDisplayUnits * 2.0) + (count * Self._labelRowHeightInDisplayUnits)
        }
        
        return 0.0
    }
    
    /* ################################################################## */
    /**
     This returns a view, with the data for the given row and section.
     
     - parameter inTableView: The table view that is asking for the cell.
     - parameter cellForRowAt: The index path (section, row) for the cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        let tableCell = inTableView.dequeueReusableCell(withIdentifier: Self._deviceRowReuseID, for: inIndexPath)
        
        if  let tableCell = tableCell as? CGA_InitialViewController_TableRow,
            let centralManager = CGA_AppDelegate.centralManager,
            (0..<centralManager.stagedBLEPeripherals.count).contains(inIndexPath.row) {
            tableCell.nameLabel?.text = centralManager.stagedBLEPeripherals[inIndexPath.row].name
            tableCell.rssiLabel?.text = String(format: "(%d dBm)", centralManager.stagedBLEPeripherals[inIndexPath.row].rssi)
            var advLabelCont: [String] = []
            centralManager.stagedBLEPeripherals[inIndexPath.row].advertisementData.forEach {
                let key = $0.key.localizedVariant
                let value = String(describing: $0.value)
                advLabelCont.append(String(format: "%@: %@", key, value))
            }
            tableCell.advertisingDataLabel.text = advLabelCont.joined(separator: "\n")
        }
        
        return tableCell
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Support -
/* ###################################################################################################################################### */
extension CGA_InitialViewController: UITableViewDelegate {
    
}
