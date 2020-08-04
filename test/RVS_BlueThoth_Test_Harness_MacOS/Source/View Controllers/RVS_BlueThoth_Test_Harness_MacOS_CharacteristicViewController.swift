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

import Cocoa
import RVS_BlueThoth_MacOS

/* ###################################################################################################################################### */
// MARK: - The Characteristic Screen View Controller -
/* ###################################################################################################################################### */
/**
 */
class RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController: RVS_BlueThoth_MacOS_Test_Harness_Base_SplitView_ViewController {
    /* ################################################################## */
    /**
     This is the storyboard ID that we use to create an instance of this view.
     */
    static let storyboardID  = "characteristic-view-controller"

    /* ################################################################## */
    /**
     This is a carriage return/linefeed pair, which will always be used in place of a simple CR or LF, alone.
     */
    private static let _crlf = "\r\n"

    /* ################################################################## */
    /**
     This is the initial width of the new section.
     */
    static let minimumThickness: CGFloat = 400
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var readButton: NSButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var notifyButton: NSButton!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var indicateLabel: NSTextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeResponseLabel: NSTextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeNoResponseLabel: NSTextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var extendedLabel: NSTextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var readHeaderStackView: NSStackView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var valueTextFieldLabelContainer: NSTextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var valueTextFieldLabel: NSTextFieldCell!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var valueTextViewContainer: NSTextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var valueTextView: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeTextFieldLabelContainer: NSTextField!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeTextFieldLabel: NSTextFieldCell!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var writeTextViewContainer: NSScrollView!
    
    /* ################################################################## */
    /**
     */
    @IBOutlet var writeTextView: NSTextView!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var sendButtonContainer: NSView!

    /* ################################################################## */
    /**
     */
    @IBOutlet weak var sendButtonText: NSButtonCell!
        
    /* ################################################################## */
    /**
     */
    @IBOutlet weak var sendResponseButtonText: NSButtonCell!
    
    /* ################################################################## */
    /**
     This allows you to wipe the value, and start over.
     */
    @IBOutlet weak var refreshButton: NSButton!
    
    /* ################################################################## */
    /**
     This is the Characteristic instance associated with this screen.
     When this is changed, we wipe the cache.
     */
    var characteristicInstance: CGA_Bluetooth_Characteristic? {
        didSet {
            updateUI()
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController {
    /* ################################################################## */
    /**
     - parameter: ignored
     */
    @IBAction func readButtonHit(_: Any) {
        valueTextView?.title = ""
        characteristicInstance?.clearConcatenate(newValue: true)
        characteristicInstance?.readValue()
    }
    
    /* ################################################################## */
    /**
     - parameter inButton: The Notify checkbox button
     */
    @IBAction func notifyButtonChanged(_ inButton: NSButton) {
        valueTextView?.title = ""
        if .on == inButton.state {
            characteristicInstance?.clearConcatenate(newValue: true)
            characteristicInstance?.startNotifying()
        } else {
            characteristicInstance?.stopNotifying()
        }
    }

    /* ################################################################## */
    /**
     - parameter inButton: used as a flag. If nil, then we are sending with response.
     */
    @IBAction func sendButtonHit(_ inButton: Any! = nil) {
        if var textToSend = writeTextView?.string {
            // See if we are to send CRLF as line endings.
            if prefs.alwaysUseCRLF {
                textToSend = textToSend.replacingOccurrences(of: "\n", with: Self._crlf).replacingOccurrences(of: "\r", with: Self._crlf)
            }
            if  let data = textToSend.data(using: .utf8) {
                let responseValue = nil == inButton
                #if DEBUG
                    print("Sending \"\(textToSend)\" to the Device")
                    if responseValue {
                        print("\tAnd asking for a response, if possible.")
                    }
                #endif
                characteristicInstance?.writeValue(data, withResponseIfPossible: responseValue)
            }
        }
    }
    
    /* ################################################################## */
    /**
     - parameter: ignored.
     */
    @IBAction func sendButtonResponseHit(_: Any) {
        sendButtonHit()
    }

    /* ################################################################## */
    /**
     - parameter: ignored.
     */
    @IBAction func refreshButtonHit(_: Any) {
        characteristicInstance?.clearConcatenate(newValue: true)
        updateUI()
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController {
    
    /* ################################################################## */
    /**
     This sets up the buttons and labels at the top of the screen.
     */
    func setButtonsAndLabelsVisibility() {
        readButton?.isHidden = !(characteristicInstance?.canRead ?? false)
        notifyButton?.isHidden = !(characteristicInstance?.canNotify ?? false)
        indicateLabel?.isHidden = !(characteristicInstance?.canIndicate ?? false)
        writeNoResponseLabel?.isHidden = !(characteristicInstance?.canWriteWithoutResponse ?? false)
        writeResponseLabel?.isHidden = !(characteristicInstance?.canWriteWithResponse ?? false)
        extendedLabel?.isHidden = !(characteristicInstance?.hasExtendedProperties ?? false)
        
    }
  
    /* ################################################################## */
    /**
     This either shows or hides the read items.
     */
    func setReadItemsVisibility() {
        if (characteristicInstance?.canNotify ?? false) || (characteristicInstance?.canRead ?? false) {
            refreshButton?.isHidden = (valueTextView?.title ?? "").isEmpty
            readHeaderStackView?.isHidden = false
            valueTextView?.title = characteristicInstance?.stringValue ?? ""
        } else {
            readHeaderStackView?.isHidden = true
            refreshButton?.isHidden = true
            valueTextViewContainer?.isHidden = true
        }
    }
    
    /* ################################################################## */
    /**
     This either shows or hides the write items.
     */
    func setWriteItemsVisibility() {
        if characteristicInstance?.canWrite ?? false {
            writeTextFieldLabelContainer?.isHidden = false
            writeTextViewContainer?.isHidden = false
            sendButtonContainer?.isHidden = false
            
            if characteristicInstance?.canWriteWithResponse ?? false {
                sendResponseButtonText?.controlView?.isHidden = false
            } else {
                sendResponseButtonText?.controlView?.isHidden = true
            }
            
            if characteristicInstance?.canWriteWithoutResponse ?? false {
                sendButtonText?.controlView?.isHidden = false
            } else {
                sendButtonText?.controlView?.isHidden = true
            }
        } else {
            writeTextFieldLabelContainer?.isHidden = true
            writeTextViewContainer?.isHidden = true
            sendButtonContainer?.isHidden = true
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController {
    /* ################################################################## */
    /**
     Called when the view hierachy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        readButton?.title = (readButton?.title ?? "ERROR").localizedVariant
        notifyButton?.title = (notifyButton?.title ?? "ERROR").localizedVariant
        indicateLabel?.stringValue = (indicateLabel?.stringValue ?? "ERROR").localizedVariant
        writeResponseLabel?.stringValue = (writeResponseLabel?.stringValue ?? "ERROR").localizedVariant
        writeNoResponseLabel?.stringValue = (writeNoResponseLabel?.stringValue ?? "ERROR").localizedVariant
        extendedLabel?.stringValue = (extendedLabel?.stringValue ?? "ERROR").localizedVariant
        sendButtonText?.title = (sendButtonText?.title ?? "ERROR").localizedVariant
        sendResponseButtonText?.title = (sendResponseButtonText?.title ?? "ERROR").localizedVariant
        valueTextFieldLabel?.stringValue = (valueTextFieldLabel?.stringValue ?? "ERROR").localizedVariant
        writeTextFieldLabel?.stringValue = (writeTextFieldLabel?.stringValue ?? "ERROR").localizedVariant
        notifyButton?.state = (characteristicInstance?.isNotifying ?? false) ? .on : .off

        setUpAccessibility()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen appears.
     We use this to register with the app delegate.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        appDelegateObject.screenList.addScreen(self)
        updateUI()
    }
    
    /* ################################################################## */
    /**
     Called just before the screen disappears.
     We use this to un-register with the app delegate.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        appDelegateObject.screenList.removeScreen(self)
    }
    
    /* ################################################################## */
    /**
     Sets up the various accessibility labels.
     */
    override func setUpAccessibility() {
        readButton?.setAccessibilityTitle("SLUG-ACC-CHARACTERISTIC-ROW-SLUG-PROPERTIES-READ".localizedVariant)
        readButton?.toolTip = readButton?.accessibilityTitle()
        indicateLabel?.setAccessibilityTitle("SLUG-ACC-CHARACTERISTIC-ROW-SLUG-PROPERTIES-INDICATE".localizedVariant)
        indicateLabel?.toolTip = indicateLabel?.accessibilityTitle()
        writeResponseLabel?.setAccessibilityTitle("SLUG-ACC-CHARACTERISTIC-ROW-SLUG-PROPERTIES-WRITE-RESPONSE".localizedVariant)
        writeResponseLabel?.toolTip = writeResponseLabel?.accessibilityTitle()
        writeNoResponseLabel?.setAccessibilityTitle("SLUG-ACC-CHARACTERISTIC-ROW-SLUG-PROPERTIES-WRITE".localizedVariant)
        writeNoResponseLabel?.toolTip = writeNoResponseLabel?.accessibilityTitle()
        extendedLabel?.setAccessibilityTitle("SLUG-ACC-CHARACTERISTIC-ROW-SLUG-PROPERTIES-EXTENDED".localizedVariant)
        extendedLabel?.toolTip = extendedLabel?.accessibilityTitle()
        sendButtonText?.setAccessibilityTitle("SLUG-ACC-SEND-BUTTON".localizedVariant)
        sendResponseButtonText?.setAccessibilityTitle("SLUG-ACC-SEND-BUTTON-RESPONSE".localizedVariant)
        valueTextFieldLabel?.setAccessibilityTitle("SLUG-ACC-VALUE".localizedVariant)
        writeTextFieldLabel?.setAccessibilityTitle("SLUG-ACC-WRITE-VALUE".localizedVariant)
        refreshButton?.setAccessibilityTitle("SLUG-ACC-REFRESH".localizedVariant)
        refreshButton?.toolTip = refreshButton?.accessibilityTitle()
        notifyButton?.setAccessibilityTitle(("SLUG-ACC-CHARACTERISTIC-ROW-SLUG-PROPERTIES-NOTIFY-O" + ((characteristicInstance?.isNotifying ?? false) ? "N" : "FF")).localizedVariant)
        notifyButton?.toolTip = notifyButton?.accessibilityTitle()
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_BlueThoth_Test_Harness_MacOS_Base_ViewController_Protocol Conformance -
/* ###################################################################################################################################### */
extension RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController: RVS_BlueThoth_Test_Harness_MacOS_ControllerList_Protocol {
    /* ################################################################## */
    /**
     This is a String key that uniquely identifies this screen.
     */
    var key: String { characteristicInstance?.id ?? "ERROR" }

    /* ################################################################## */
    /**
     This forces the UI elements to be updated.
     */
    func updateUI() {
        setButtonsAndLabelsVisibility()
        setReadItemsVisibility()
        setWriteItemsVisibility()
        setUpAccessibility()
    }
}
