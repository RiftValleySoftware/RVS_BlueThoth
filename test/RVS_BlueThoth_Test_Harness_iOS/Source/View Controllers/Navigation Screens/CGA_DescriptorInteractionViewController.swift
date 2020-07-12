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
class CGA_DescriptorInteractionViewController: CGA_BaseViewController, CGA_WriteableElementContainer {
    /* ################################################################## */
    /**
     This is a carriage return/linefeed pair, which will always be used in place of a simple CR or LF, alone.
     */
    private static let _crlf = "\r\n"

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
     The Descriptor that is associated with this view controller.
     */
    var writeableElementInstance: CGA_Bluetooth_Writable?
    
    /* ################################################################## */
    /**
     The Descriptor that is associated with this view controller, cast from the writable entity.
     */
    var myDescriptorInstance: CGA_Bluetooth_Descriptor? {
        writeableElementInstance as? CGA_Bluetooth_Descriptor
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_DescriptorInteractionViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    private func _setUpAccessibility() {
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Handlers -
/* ###################################################################################################################################### */
extension CGA_DescriptorInteractionViewController {
    /* ################################################################## */
    /**
     This reacts to a tap in the area outside the keyboard, and puts away the keyboard.
     
     - parameter: ignored (and optional)
     */
    @IBAction func tappedInScreen(_: Any! = nil) {
        resignAllFirstResponders()
    }

    /* ################################################################## */
    /**
     - parameter: ignored (and optional)
     */
    @IBAction func writeSendButtonHit(_: Any! = nil) {
        tappedInScreen()
        // Have to have something to send.
        if  var sendingText = writeTextView?.text,
            !sendingText.isEmpty {
            // See if we are to send CRLF as line endings.
            if prefs.alwaysUseCRLF {
                sendingText = sendingText.replacingOccurrences(of: "\n", with: Self._crlf).replacingOccurrences(of: "\r", with: Self._crlf)
            }
            if let data = sendingText.data(using: .utf8) {
                myDescriptorInstance?.writeValue(data)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override -
/* ###################################################################################################################################### */
extension CGA_DescriptorInteractionViewController {
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        writeLabel?.text = writeLabel?.text?.localizedVariant ?? "ERROR"
        writeSendButton?.setTitle(writeSendButton?.title(for: .normal)?.localizedVariant, for: .normal)
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_DescriptorInteractionViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the Characteristic.
     */
    func updateUI() {
        _setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - Text View Delegate -
/* ###################################################################################################################################### */
extension CGA_DescriptorInteractionViewController: UITextViewDelegate {
    /* ################################################################## */
    /**
     Called when some text or attributes change in the text view.
     
     - parameter inTextView: The Text View that experienced the change.
     */
    func textViewDidChange(_ inTextView: UITextView) {
        // The only text view we care about is the write one.
        if writeTextView == inTextView {
            writeSendButton?.isHidden = inTextView.text.isEmpty
            writeLabel?.isHidden = !inTextView.text.isEmpty
        }
    }
}
