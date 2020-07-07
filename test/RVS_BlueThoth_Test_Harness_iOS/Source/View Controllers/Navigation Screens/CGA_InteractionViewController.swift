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
// MARK: - The Interaction View Controller -
/* ###################################################################################################################################### */
/**
 This controls the Interaction View.
 */
class CGA_InteractionViewController: CGA_BaseViewController {
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeStackView: UIStackView!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeLabel: UILabel!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeTextView: UITextView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeSendButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var readStackView: UIStackView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var readButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var readTextView: UITextView!

    /* ################################################################## */
    /**
     The Characteristic that is associated with this view controller.
     */
    var characteristicInstance: CGA_Bluetooth_Characteristic!              
}

/* ###################################################################################################################################### */
// MARK: - IBAction Handlers -
/* ###################################################################################################################################### */
extension CGA_InteractionViewController {
    /* ################################################################## */
    /**
     */
    @IBAction func writeSendButtonHit(_ sender: Any) {
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func readButtonHit(_ sender: Any) {
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override -
/* ###################################################################################################################################### */
extension CGA_InteractionViewController {
    override func viewDidLoad() {
        writeLabel?.text = writeLabel?.text?.localizedVariant ?? "ERROR"
        writeSendButton?.setTitle(writeSendButton?.title(for: .normal)?.localizedVariant, for: .normal)

        if characteristicInstance?.canRead ?? false {
            readStackView?.isHidden = false
            readButton?.setTitle(readButton?.title(for: .normal)?.localizedVariant, for: .normal)
        } else {
            readStackView?.isHidden = true
        }
    }
}
