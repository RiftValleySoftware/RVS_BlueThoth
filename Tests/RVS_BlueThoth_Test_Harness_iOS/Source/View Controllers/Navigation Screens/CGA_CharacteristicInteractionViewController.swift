/*
© Copyright 2020-2022, The Great Rift Valley Software Company

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
import RVS_BlueThoth

/* ###################################################################################################################################### */
// MARK: - The Characteristic Interaction View Controller -
/* ###################################################################################################################################### */
/**
 This controls the Interaction View.
 */
class CGA_CharacteristicInteractionViewController: CGA_BaseViewController, CGA_WriteableElementContainer {
    /* ################################################################## */
    /**
     This is a carriage return/linefeed pair, which will always be used in place of a simple CR or LF, alone.
     */
    private static let _crlf = "\r\n"

    /* ################################################################## */
    /**
     This stack view contains the items at the top of the screen.
     */
    @IBOutlet weak var writeStackView: UIStackView!

    /* ################################################################## */
    /**
     This is the label for the write section.
     */
    @IBOutlet weak var writeLabel: UILabel!
    
    /* ################################################################## */
    /**
     This button will send the data.
     */
    @IBOutlet weak var writeSendButton: UIButton!
    
    /* ################################################################## */
    /**
     This contains the response switch and button label.
     */
    @IBOutlet weak var responseContainer: UIStackView!
    
    /* ################################################################## */
    /**
     This button toggles the switch value, and acts like a label.
     */
    @IBOutlet weak var responseLabelButton: UIButton!
    
    /* ################################################################## */
    /**
     This switch denotes whether or not to request a response to the write.
     */
    @IBOutlet weak var responseSwitch: UISwitch!

    /* ################################################################## */
    /**
     This is the text view that receives text to be written.
     */
    @IBOutlet weak var writeTextView: UITextView!

    /* ################################################################## */
    /**
     This holds the vartious read/indicate stuff.
     */
    @IBOutlet weak var readStackView: UIStackView!
    
    /* ################################################################## */
    /**
     This button triggers a read.
     */
    @IBOutlet weak var readButton: UIButton!
    
    /* ################################################################## */
    /**
     This text view displays the read data as a string.
     */
    @IBOutlet weak var readTextView: UITextView!

    /* ################################################################## */
    /**
     This button toggles notification state.
     */
    @IBOutlet weak var notifyButton: UIButton!
    
    /* ################################################################## */
    /**
     The Characteristic that is associated with this view controller.
     */
    var writeableElementInstance: CGA_Bluetooth_Writable?
    
    /* ################################################################## */
    /**
     The Characteristic that is associated with this view controller, cast from the writable entity.
     */
    var myCharacteristicInstance: CGA_Bluetooth_Characteristic? {
        writeableElementInstance as? CGA_Bluetooth_Characteristic
    }
}

/* ###################################################################################################################################### */
// MARK: - Private Methods -
/* ###################################################################################################################################### */
extension CGA_CharacteristicInteractionViewController {
    /* ################################################################## */
    /**
     This sets up the accessibility and voiceover strings for the screen.
     */
    func setUpAccessibility() {
        notifyButton?.accessibilityLabel = notifyButton?.accessibilityLabel?.localizedVariant
        responseLabelButton?.accessibilityLabel = notifyButton?.accessibilityLabel?.localizedVariant
        responseSwitch?.accessibilityLabel = responseSwitch?.accessibilityLabel?.localizedVariant
        writeSendButton?.accessibilityLabel = writeSendButton?.accessibilityLabel?.localizedVariant
        writeTextView?.accessibilityLabel = writeTextView?.accessibilityLabel?.localizedVariant
        readButton?.accessibilityLabel = readButton?.accessibilityLabel?.localizedVariant
        readTextView?.accessibilityLabel = readTextView?.accessibilityLabel?.localizedVariant
        notifyButton?.accessibilityLabel = notifyButton?.accessibilityLabel?.localizedVariant
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Handlers -
/* ###################################################################################################################################### */
extension CGA_CharacteristicInteractionViewController {
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
            if  let data = sendingText.data(using: .utf8),
                let responseValue = (responseSwitch?.isHidden ?? false) ? false : responseSwitch?.isOn {
                #if DEBUG
                    print("Sending \"\(sendingText)\" to the Device")
                    if responseValue {
                        print("\tAnd asking for a response, if possible.")
                    }
                #endif
                myCharacteristicInstance?.writeValue(data, withResponseIfPossible: responseValue)
            }
        }
    }
    
    /* ################################################################## */
    /**
     - parameter: ignored (and optional)
     */
    @IBAction func responseButtonHit(_: Any! = nil) {
        tappedInScreen()
        responseSwitch?.isOn = !(responseSwitch?.isOn ?? true)
    }
    
    /* ################################################################## */
    /**
     - parameter: ignored (and optional)
     */
    @IBAction func readButtonHit(_: Any! = nil) {
        tappedInScreen()
        myCharacteristicInstance?.readValue()
    }

    /* ################################################################## */
    /**
     - parameter: ignored (and optional)
     */
    @IBAction func notifyButtonHit(_: Any! = nil) {
        if !(myCharacteristicInstance?.isNotifying ?? false) {
            myCharacteristicInstance?.startNotifying()
        } else {
            myCharacteristicInstance?.stopNotifying()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override -
/* ###################################################################################################################################### */
extension CGA_CharacteristicInteractionViewController {
    /* ################################################################## */
    /**
     Called when the view hierarchy has been loaded from the nib.
     */
    override func viewDidLoad() {
        guard let myCharacteristicInstance = myCharacteristicInstance else { return }
        writeLabel?.text = writeLabel?.text?.localizedVariant ?? "ERROR"
        writeSendButton?.setTitle(writeSendButton?.title(for: .normal)?.localizedVariant, for: .normal)
        responseLabelButton?.setTitle(responseLabelButton?.title(for: .normal)?.localizedVariant, for: .normal)
        notifyButton?.isHidden = !(myCharacteristicInstance.canNotify || myCharacteristicInstance.canIndicate)
        responseContainer?.isHidden = !(myCharacteristicInstance.canWriteWithResponse && myCharacteristicInstance.canWriteWithoutResponse)
        
        navigationItem.title = "SLUG-INTERACT".localizedVariant
        if myCharacteristicInstance.canRead || myCharacteristicInstance.canNotify {
            readStackView?.isHidden = false
            readButton?.setTitle("SLUG-PROPERTIES-READ".localizedVariant, for: .normal)
            readButton?.isHidden = !myCharacteristicInstance.canRead
        } else {
            readStackView?.isHidden = true
        }

        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - CGA_UpdatableScreenViewController Conformance -
/* ###################################################################################################################################### */
extension CGA_CharacteristicInteractionViewController: CGA_UpdatableScreenViewController {
    /* ################################################################## */
    /**
     This simply makes sure that the UI matches the state of the Characteristic.
     */
    func updateUI() {
        guard let myCharacteristicInstance = myCharacteristicInstance else { return }
        if  (myCharacteristicInstance.canRead || myCharacteristicInstance.canNotify),
            let data = myCharacteristicInstance.value,
            let stringValue = String(data: data, encoding: .utf8) {
            readTextView?.text = stringValue
        }
        
        writeLabel?.isHidden = !(writeSendButton?.isHidden ?? false)

        if myCharacteristicInstance.canNotify || myCharacteristicInstance.canIndicate {
            let title = (!myCharacteristicInstance.canNotify && myCharacteristicInstance.canIndicate) ? "SLUG-PROPERTIES-INDICATE-\(myCharacteristicInstance.isNotifying ? "ON" : "OFF")" : "SLUG-PROPERTIES-NOTIFY-\(myCharacteristicInstance.isNotifying ? "ON" : "OFF")"
            notifyButton?.setTitle(title, for: .normal)
            notifyButton?.setTitle(title.localizedVariant, for: .normal)
            notifyButton?.setTitleColor(myCharacteristicInstance.isNotifying ? (isDarkMode ? .black : .blue) : .white, for: .normal)
            notifyButton?.backgroundColor = myCharacteristicInstance.isNotifying ? .green : .red
        }
        
        setUpAccessibility()
    }
}

/* ###################################################################################################################################### */
// MARK: - Text View Delegate -
/* ###################################################################################################################################### */
extension CGA_CharacteristicInteractionViewController: UITextViewDelegate {
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
