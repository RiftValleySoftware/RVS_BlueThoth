/**
 © Copyright 2019, The Great Rift Valley Software Company
 
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

import WatchKit
import WatchConnectivity

/* ################################################################################################################################## */
// MARK: - Main Extension Delegate Class.
/* ################################################################################################################################## */
/**
 This is the extension delegate for an extremely simple WatchKit app.
 
 Its only purpose in life is to display a couple of values from a Dictionary of values sent from the phone.
 
 It maintains an instance of RVS_PersistentPrefs_TestSet locally, and updates the _values with the ones sent from the phone.
 
 It does not allow changes to the values, and does not send them back to the phone. It is completely one-way.
 
 The prefs object is managed in this instance.
 */
class RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    /* ############################################################################################################################## */
    // MARK: - Private Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     We simply call this to activate our session.
     */
    private func _activateSession() {
        if  WCSession.isSupported(),
            .activated != session.activationState {
            session.delegate = self
            session.activate()
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _replyHandler(_ inReply: [String: Any]) {
        #if DEBUG
            print("Reply From Phone: " + String(describing: inReply))
        #endif
        if let controller = WKExtension.shared().rootInterfaceController as? RVS_PersistentPrefs_watchOS_TestHarness_InterfaceController {
            controller.reEnableButton()
        }
    }
    
    /* ################################################################## */
    /**
     */
    private func _errorHandler(_ inError: Error) {
        #if DEBUG
            print("Error From Phone: " + String(describing: inError))
        #endif
        if let controller = WKExtension.shared().rootInterfaceController as? RVS_PersistentPrefs_watchOS_TestHarness_InterfaceController {
            controller.reEnableButton()
        }
    }
    
    /* ################################################################## */
    /**
     Called to ask the phone to send us its state.
     */
    private func _askPhoneForState() {
        if  .activated == session.activationState {
            let values = prefs.values
            #if DEBUG
                print("Sending Prefs to Phone: " + String(describing: values))
            #endif
            self.session.sendMessage([s_watchPhoneMessageHitMe: ""], replyHandler: _replyHandler, errorHandler: _errorHandler)   // No extra data necessary.
        } else {
            #if DEBUG
                print("ERROR! Session not active!")
            #endif
        }
    }

    /* ############################################################################################################################## */
    // MARK: - Static Constants
    /* ############################################################################################################################## */
    /// The main prefs key.
    static let prefsKey = "RVS_PersistentPrefs_iOS_TestHarness_Prefs"
    
    /* ############################################################################################################################## */
    // MARK: - Class Variables
    /* ############################################################################################################################## */
    /// The delegate object (quick accessor).
    class var delegateObject: RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate! {
        return WKExtension.shared().delegate as? RVS_PersistentPrefs_watchOS_TestHarness_ExtensionDelegate
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Properties
    /* ############################################################################################################################## */
    /// This is the preferences object.
    var prefs = RVS_PersistentPrefs_TestSet(key: prefsKey)

    /* ############################################################################################################################## */
    // MARK: - Instance Calculated Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Accessor for our session (the default).
     */
    var session: WCSession {
        return WCSession.default
    }
    
    /* ############################################################################################################################## */
    // MARK: - Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called to send our current state to the phone.
     */
    func sendResetToPhone() {
        if  .activated == session.activationState {
            #if DEBUG
                print("Sending Reset to Phone")
            #endif
            self.session.sendMessage([s_watchPhoneMessageReset: ""], replyHandler: _replyHandler, errorHandler: _errorHandler)
        } else {
            #if DEBUG
                print("ERROR! Session not active!")
            #endif
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - WKExtensionDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Called when the WatchKit application has completed launching.
     
     We simply activate our session here.
     */
    func applicationDidFinishLaunching() {
        _activateSession()
    }
    
    /* ################################################################## */
    /**
     Called when the WatchKit application has become active.
     
     We ask the phone (if any) for an update.
     */
    func applicationDidBecomeActive() {
        _askPhoneForState()
    }
    
    /* ############################################################################################################################## */
    // MARK: - WCSessionDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is called when the session activation is complete (not necessarily connected to anything).
     
     - parameter inSession: The WCSession that is being used to send this message.
     - parameter activationDidCompleteWith: An enum, with the current state of the activation.
     - parameter error: An optional error, if there were any errors.
     */
    func session(_ inSession: WCSession, activationDidCompleteWith inActivationState: WCSessionActivationState, error inError: Error?) {
        #if DEBUG
            print("Watch Activation Complete")
        #endif
        _askPhoneForState()
    }
    
    /* ################################################################## */
    /**
     This is called when the phone sends us a message.
     
     There's only one message it can send: A new set of values.
     
     - parameter inSession: The WCSession that is being used to send this message.
     - parameter didReceiveMessage: The message that the phone sent us.
     - parameter replyHandler: A closure that we are supposed to call, when we have digested what the phone sent us. It will be sent back to the phone.
     */
    func session(_ inSession: WCSession, didReceiveMessage inMessage: [String: Any], replyHandler inReplyHandler: @escaping ([String: Any]) -> Void) {
        #if DEBUG
            print("\n###\nBEGIN Watch Received Message: " + String(describing: inMessage))
        #endif
        prefs.values = inMessage
        inReplyHandler([s_watchPhoneReplySuccessKey: true]) // Let the phone know we got the message.
        // Tel our controller to update the state display with whatever the phone sent us.
        if let controller = WKExtension.shared().rootInterfaceController as? RVS_PersistentPrefs_watchOS_TestHarness_InterfaceController {
            controller.setUpLabels()
        }
        #if DEBUG
            print("###\nEND Watch Received Message\n")
        #endif
    }
}
