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

/* ###################################################################################################################################### */
// MARK: - The Initial Screen View Controller -
/* ###################################################################################################################################### */
/**
 */
class RVS_BlueThoth_Test_Harness_MacOS_SplitViewController: NSSplitViewController {
    /* ################################################################## */
    /**
     The discovery navigator side of the screen.
     */
    @IBOutlet weak var discoveryScreenSplitViewItem: NSSplitViewItem!
    
    /* ################################################################## */
    /**
     The details side of the screen.
     */
    @IBOutlet var detailsSplitViewItem: NSSplitViewItem!
    
    /* ################################################################## */
    /**
     This allows us to associate a new View Controller with the details side of the split.
     
     - parameter inPeripheralViewController: The Peripheral View Controller to place there. If nil, or omitted, the placeholder will be set.
     */
    func setDetailsViewController(_ inPeripheralViewController: RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController? = nil) {
        if let detailsSplitViewItem = detailsSplitViewItem {
            removeSplitViewItem(detailsSplitViewItem)
        }
        guard let newDetailsViewController = inPeripheralViewController else {
             if let newPlaceholderViewController = storyboard?.instantiateController(withIdentifier: RVS_BlueThoth_Test_Harness_MacOS_PlaceholderViewController.storyboardID) as? NSViewController {
                detailsSplitViewItem = NSSplitViewItem(viewController: newPlaceholderViewController)
                addSplitViewItem(detailsSplitViewItem)
            }
            return
        }

        detailsSplitViewItem = NSSplitViewItem(viewController: newDetailsViewController)
        addSplitViewItem(detailsSplitViewItem)
    }
}
