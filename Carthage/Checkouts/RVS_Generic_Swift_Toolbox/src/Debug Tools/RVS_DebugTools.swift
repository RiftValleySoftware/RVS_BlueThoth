/**
© Copyright 2019-2020, The Great Rift Valley Software Company

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
 
Version: 1.1.0
*/

import Foundation   // Required for the ProcessInfo stuff.

/* ###################################################################################################################################### */
// MARK: - Debug Tools Class -
/* ###################################################################################################################################### */
/**
 This class is a "junk drawer" of vrious debug/testing tools.
 */
public class RVS_DebugTools {
    /* ################################################################## */
    /**
     This is used to see whether or not we are running under unit tests. It is optional, and isn't really supposed to be replaced.
     
     - returns: True, if we are currently in a unit test.
     */
    static public var isRunningUnitTests: Bool { nil != NSClassFromString("XCTest") }
}
