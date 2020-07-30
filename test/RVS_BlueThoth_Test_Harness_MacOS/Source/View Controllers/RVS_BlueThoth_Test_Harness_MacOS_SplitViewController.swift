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
    @IBOutlet var peripheralSplitViewItem: NSSplitViewItem!
    
    /* ################################################################## */
    /**
     The characteristic split view, which is displayed to the right of the details view.
     */
    @IBOutlet var characteristicSplitViewItem: NSSplitViewItem!
    
    /* ################################################################## */
    /**
     This allows us to associate a new View Controller with the details side of the split.
     
     - parameter inPeripheralViewController: The Peripheral View Controller to place there. If nil, or omitted, the placeholder will be set.
     */
    func setPeripheralViewController(_ inPeripheralViewController: RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController? = nil) {
        if let peripheralSplitViewItem = peripheralSplitViewItem {
            removeSplitViewItem(peripheralSplitViewItem)
            setCharacteristicViewController()
        }
        
        peripheralSplitViewItem = nil
        characteristicSplitViewItem = nil

        guard let newDetailsViewController = inPeripheralViewController else { return }

        peripheralSplitViewItem = NSSplitViewItem(viewController: newDetailsViewController)
        peripheralSplitViewItem.minimumThickness = RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController.minimumThickness
        peripheralSplitViewItem.maximumThickness = RVS_BlueThoth_Test_Harness_MacOS_PeripheralViewController.minimumThickness
        addSplitViewItem(peripheralSplitViewItem)
    }
    
    /* ################################################################## */
    /**
     This allows us to associate a new View Controller with the characteristic details side of the split.
     
     - parameter inCharacteristicViewController: The Characteristic View Controller to place there. If nil, or omitted, the view will be removed.
     */
    func setCharacteristicViewController(_ inCharacteristicViewController: RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController? = nil) {
        if let characteristicSplitViewItem = characteristicSplitViewItem {
            removeSplitViewItem(characteristicSplitViewItem)
        }
        
        characteristicSplitViewItem = nil
        
        guard let newCharacteristicViewController = inCharacteristicViewController else { return }

        characteristicSplitViewItem = NSSplitViewItem(viewController: newCharacteristicViewController)
        characteristicSplitViewItem.minimumThickness = RVS_BlueThoth_Test_Harness_MacOS_CharacteristicViewController.minimumThickness
        addSplitViewItem(characteristicSplitViewItem)
    }
}
