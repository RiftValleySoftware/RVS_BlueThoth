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
// MARK: - Bundle Extension -
/* ###################################################################################################################################### */
/**
 This extension adds a few simple accessors for some of the more common bundle items.
 */
extension Bundle {
    // MARK: General Stuff for common Apple-Supplied Items
    
    /* ################################################################## */
    /**
     The app name, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appDisplayName: String { (object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "ERROR" }

    /* ################################################################## */
    /**
     The app version, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appVersionString: String { object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "ERROR" }
    
    /* ################################################################## */
    /**
     The build version, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appVersionBuildString: String { object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "ERROR" }
    
    /* ################################################################## */
    /**
     If there is a copyright string, it is returned here. It may be nil.
     */
    var copyrightString: String? { object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String }

    // MARK: Specific to this app.
    
    /* ################################################################## */
    /**
     If there is a copyright site URI, it is returned here as a String. It may be nil.
     */
    var siteURIAsString: String? { object(forInfoDictionaryKey: "InfoScreenCopyrightSiteURL") as? String }
    
    /* ################################################################## */
    /**
     If there is a help site URI, it is returned here as a String. It may be nil.
     */
    var helpURIAsString: String? { object(forInfoDictionaryKey: "InfoScreenHelpSiteURL") as? String }
    
    /* ################################################################## */
    /**
     If there is a copyright site URI, it is returned here as a URL. It may be nil.
     */
    var siteURI: URL? { URL(string: siteURIAsString ?? "") }
    
    /* ################################################################## */
    /**
     If there is a help site URI, it is returned here as a URL. It may be nil.
     */
    var helpURI: URL? { URL(string: helpURIAsString ?? "") }
}

/* ###################################################################################################################################### */
// MARK: - Info View Controller -
/* ###################################################################################################################################### */
/**
 */
class CGA_InfoViewController: UIViewController {
    /* ################################################################## */
    /**
     The label at the top, with the app name and version.
     */
    @IBOutlet weak var titleLabel: UILabel!

    /* ################################################################## */
    /**
     The main text body.
     */
    @IBOutlet weak var infoTextView: UITextView!
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension CGA_InfoViewController {
    /* ################################################################## */
    /**
     Called just after the view hierarchy has loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTextView?.text = "SLUG-MAIN-INFO-TEXT".localizedVariant
        titleLabel?.text = Bundle.main.appDisplayName + " (" + String(format: "SLUG-VERSION-FORMAT".localizedVariant, Bundle.main.appVersionString, Bundle.main.appVersionBuildString) + ")"
    }
    
    /* ################################################################## */
    /**
     Called just before the view will disappear.
     
     - parameter inAnimated: ignored, but passed to the superclas.
     */
    override func viewWillDisappear(_ inAnimated: Bool) {
        super.viewWillDisappear(inAnimated)
    }
}
