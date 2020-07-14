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

import Cocoa
import RVS_Generic_Swift_Toolbox

/* ################################################################################################################################## */
// MARK: - Basic Window Controller Class
/* ################################################################################################################################## */
/**
 The main reason for creating this class was to allow us to interpret settings, and to fix an issue with Interface Builder.
 */
class RVS_BlueThoth_MacOS_Test_Harness_Base_WindowController: NSWindowController {
    /* ################################################################## */
    /**
     This accounts for a bug in Xcode, where the [`restorable`](https://developer.apple.com/documentation/appkit/nswindow/1526255-restorable) flag is ignored. If you set the name here, it will restore.
     */
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.title = window?.title.localizedVariant ?? "ERROR"
        self.windowFrameAutosaveName = window?.title ?? "ERROR" // This is because there seems to be a bug (maybe in IB), where the auto-restore setting is not saved unless we do this.
    }
}
