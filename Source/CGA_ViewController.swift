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
// MARK: -
/* ###################################################################################################################################### */
/**
 */
class CGA_ViewController: UIViewController {
    /* ################################################################## */
    /**
     These are the indexes for our sections.
     */
    private enum _SectionIndexes: Int {
        /// The BLE section index.
        case ble
        /// The classic section index.
        case classic
        /// Because we are Int, this will have the number of sections (1-based).
        case numSections
    }
    
    /* ################################################################## */
    /**
     This is how high each section header will be.
     */
    private static let _sectionHeaderHeightInDisplayUnits: CGFloat = 20.0
    
    /* ################################################################## */
    /**
     The reuse ID that we use for creating new table cells.
     */
    private static let _deviceRowReuseID = "device-row"

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
    }
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_ViewController: UITableViewDelegate {
    
}

/* ###################################################################################################################################### */
// MARK: -
/* ###################################################################################################################################### */
/**
 */
extension CGA_ViewController: UITableViewDataSource {
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
        ret.textColor = .white
        
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
        0
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
