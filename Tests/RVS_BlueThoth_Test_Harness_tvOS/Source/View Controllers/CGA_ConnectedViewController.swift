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
import RVS_BlueThoth_TVOS

/* ###################################################################################################################################### */
// MARK: - Connected Peripheral View Controller -
/* ###################################################################################################################################### */
/**
 */
class CGA_ConnectedViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     The reuse ID for each row of the table.
     */
    static let servceTableCellReuseID = "basic-service"
    
    /* ################################################################## */
    /**
     The segue ID of the "Show Discovery Details" screen.
     */
    static let characteristicsSegueID = "show-characteristics"
    
    /* ################################################################## */
    /**
     The discovery data for this device.
     */
    var discoveryData: RVS_BlueThoth.DiscoveryData!

    /* ################################################################## */
    /**
     The temporary label that is put up while connecting.
     */
    @IBOutlet weak var connectingLabel: UILabel!
    
    /* ################################################################## */
    /**
     The centering view for the busy indicator.
     */
    @IBOutlet weak var spinnerContainerView: UIView!
    
    /* ################################################################## */
    /**
     This label displays the device name.
     */
    @IBOutlet weak var nameLabel: UILabel!

    /* ################################################################## */
    /**
     The table that displays the services.
     */
    @IBOutlet weak var serviceTableView: UITableView!
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_ConnectedViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
        connectingLabel?.accessibilityLabel = "SLUG-ACC-CONNECTING-LABEL".localizedVariant
        spinnerContainerView?.accessibilityLabel = "SLUG-ACC-CONNECTING-LABEL".localizedVariant
        serviceTableView?.accessibilityLabel = "SLUG-ACC-SERVICES-TABLE".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension CGA_ConnectedViewController {
    /* ################################################################## */
    /**
     Called just after the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        connectingLabel?.text = (connectingLabel?.text ?? "ERROR").localizedVariant
        nameLabel?.text = (discoveryData?.preferredName.isEmpty ?? true) ? (discoveryData?.identifier ?? "ERROR") : discoveryData?.preferredName
        discoveryData?.connect()
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view will appear. We use this to ensure that we are disconnected.
     
     - parameter inAnimated: ignored, but passed to the superclas.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
    }
    
    /* ################################################################## */
    /**
     Called just before the characteristics display screen is pushed.
     
     - parameter for: The segue that is being executed.
     - parameter sender: The discovery information.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        if  let destination = inSegue.destination as? CGA_ServiceViewController,
            let serviceInstance = inSender as? CGA_Bluetooth_Service {
            destination.serviceInstance = serviceInstance
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_ConnectedViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the table is displayed if BT is available, or the "No BT" image is shown, if it is not.
     */
    func updateUI() {
        connectingLabel?.isHidden = discoveryData?.isConnected ?? true
        spinnerContainerView?.isHidden = discoveryData?.isConnected ?? true
        serviceTableView?.isHidden = !(discoveryData?.isConnected ?? false)
        serviceTableView?.reloadData()
        setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDataSource Conformance -
/* ###################################################################################################################################### */
extension CGA_ConnectedViewController: UITableViewDataSource {
    /* ################################################################## */
    /**
     Called to provide the data to display in the indicated table cell.
     
     - parameters:
        - inTableView: The Table View that is asking for this View.
        - cellForRowAt: The IndexPath of the cell.
     
     - returns: A new view, set up for the indicated cell.
     */
    func tableView(_ inTableView: UITableView, cellForRowAt inIndexPath: IndexPath) -> UITableViewCell {
        if  let ret = inTableView.dequeueReusableCell(withIdentifier: Self.servceTableCellReuseID),
            let peripheralInstance = discoveryData.peripheralInstance {
            let service = peripheralInstance[inIndexPath.row]
            ret.textLabel?.text = service.id.localizedVariant
            return ret
        }
        
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     - returns: The number of rows in the table.
     */
    func tableView(_: UITableView, numberOfRowsInSection: Int) -> Int { discoveryData.peripheralInstance?.count ?? 0 }
}

/* ###################################################################################################################################### */
// MARK: - UITableViewDelegate Conformance -
/* ###################################################################################################################################### */
extension CGA_ConnectedViewController: UITableViewDelegate {
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter: ignored
     - parameter didSelectRowAt: The IndexPath of the selected row.
     */
    func tableView(_: UITableView, didSelectRowAt inIndexPath: IndexPath) {
        performSegue(withIdentifier: Self.characteristicsSegueID, sender: discoveryData.peripheralInstance?[inIndexPath.row])
    }
}
