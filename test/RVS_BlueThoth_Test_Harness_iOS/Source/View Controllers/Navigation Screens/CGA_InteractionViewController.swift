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
     */
    @IBOutlet weak var notifyButton: UIButton!
    
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
        if  let sendingText = writeTextView?.text,
            !sendingText.isEmpty,
            let data = sendingText.data(using: .utf8) {
            #if DEBUG
                print("Sending \"\(sendingText)\" to the Device")
            #endif
            characteristicInstance?.writeValue(data)
        }
    }
    
    /* ################################################################## */
    /**
     - parameter: ignored (and optional)
     */
    @IBAction func readButtonHit(_: Any! = nil) {
        tappedInScreen()
        characteristicInstance.readValue()
    }
    
    /* ################################################################## */
    /**
     - parameter: ignored (and optional)
     */
    @IBAction func notifyButtonHit(_: Any! = nil) {
        if !(characteristicInstance?.isNotifying ?? false) {
            characteristicInstance?.startNotifying()
        } else {
            characteristicInstance?.stopNotifying()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override -
/* ###################################################################################################################################### */
extension CGA_InteractionViewController {
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        writeLabel?.text = writeLabel?.text?.localizedVariant ?? "ERROR"
        writeSendButton?.setTitle(writeSendButton?.title(for: .normal)?.localizedVariant, for: .normal)
        notifyButton?.isHidden = !(characteristicInstance?.canNotify ?? true)
        navigationItem.title = "SLUG-INTERACT".localizedVariant
        
        if characteristicInstance?.canRead ?? false {
            readStackView?.isHidden = false
            readButton?.setTitle(readButton?.title(for: .normal)?.localizedVariant, for: .normal)
        } else {
            readStackView?.isHidden = true
        }

        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_InteractionViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the Characteristic.
     */
    func updateUI() {
        if  let data = characteristicInstance?.value,
            let stringValue = String(data: data, encoding: .utf8) {
            if characteristicInstance?.canRead ?? false {
                readTextView?.text = stringValue
            } else {
                writeTextView?.text = stringValue
            }
        }
        
        writeLabel?.isHidden = !(writeSendButton?.isHidden ?? false)

        if characteristicInstance?.canNotify ?? false {
            let title = "SLUG-PROPERTIES-NOTIFY-\(characteristicInstance.isNotifying ? "ON" : "OFF")"
            notifyButton.setTitle(title.localizedVariant, for: .normal)
            notifyButton.setTitleColor(characteristicInstance.isNotifying ? (isDarkMode ? .black : .blue) : .white, for: .normal)
            notifyButton.backgroundColor = characteristicInstance.isNotifying ? .green : .red
            notifyButton.accessibilityLabel = notifyButton.accessibilityLabel?.localizedVariant
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Text View Delegate -
/* ###################################################################################################################################### */
extension CGA_InteractionViewController: UITextViewDelegate {
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
