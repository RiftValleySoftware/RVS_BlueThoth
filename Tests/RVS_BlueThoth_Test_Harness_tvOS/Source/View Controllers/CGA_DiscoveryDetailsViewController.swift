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
// MARK: - Discovery Details View Controller -
/* ###################################################################################################################################### */
/**
 */
class CGA_DiscoveryDetailsViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     The segue ID of the "Show Discovery Details" screen.
     */
    static let connectSegueID = "connect-peripheral"
    
    /* ################################################################## */
    /**
     */
    var discoveryData: RVS_BlueThoth.DiscoveryData!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var detailsDisplayTextView: UITextView!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var connectButton: UIButton!
    
    /* ################################################################## */
    /**
     This label displays the device name.
     */
    @IBOutlet weak var nameLabel: UILabel!
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension CGA_DiscoveryDetailsViewController {
    /* ################################################################## */
    /**
     Called when the CONNECT button is selected and hit.
     
     - parameter: ignored.
     */
    @IBAction func connectButtonHit(_: Any) {
        performSegue(withIdentifier: Self.connectSegueID, sender: discoveryData)
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension CGA_DiscoveryDetailsViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
        connectButton?.accessibilityLabel = "SLUG-ACC-CONNECT-BUTTON".localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension CGA_DiscoveryDetailsViewController {
    /* ################################################################## */
    /**
     Called just after the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsDisplayTextView?.text = CGA_AppDelegate.createAdvertimentStringsFor(discoveryData.advertisementData, id: discoveryData.identifier).joined(separator: "\n")
        nameLabel?.text = (discoveryData?.preferredName.isEmpty ?? true) ? (discoveryData?.identifier ?? "ERROR") : discoveryData?.preferredName
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the view will appear. We use this to ensure that we are disconnected.
     
     - parameter inAnimated: ignored, but passed to the superclas.
     */
    override func viewWillAppear(_ inAnimated: Bool) {
        super.viewWillAppear(inAnimated)
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the connection screen is pushed.
     
     - parameter for: The segue that is being executed.
     - parameter sender: The discovery information.
     */
    override func prepare(for inSegue: UIStoryboardSegue, sender inSender: Any?) {
        if  let destination = inSegue.destination as? CGA_ConnectedViewController,
            let discoveryData = inSender as? RVS_BlueThoth.DiscoveryData {
            destination.discoveryData = discoveryData
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_DiscoveryDetailsViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the table is displayed if BT is available, or the "No BT" image is shown, if it is not.
     */
    func updateUI() {
        connectButton?.isHidden = !(discoveryData?.canConnect ?? false)
        connectButton?.setTitle(discoveryData.isConnected ? "SLUG-SERVICES".localizedVariant : "SLUG-CONNECT".localizedVariant, for: .normal)
        setUpAccessibility()
    }
}
