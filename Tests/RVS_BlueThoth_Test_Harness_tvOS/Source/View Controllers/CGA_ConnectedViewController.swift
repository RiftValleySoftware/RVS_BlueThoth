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
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension CGA_ConnectedViewController {
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
        setUpAccessibility()
    }
}
