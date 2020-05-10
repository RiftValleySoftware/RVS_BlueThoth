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
 
Version: 1.0.5
*/

import XCTest

/* ###################################################################################################################################### */
// MARK: - RVS_Int_Extensions_Tests -
/* ###################################################################################################################################### */
/**
 These are specific unit tests for the Int extension.
 */
class RVS_Int_Extensions_Tests: XCTestCase {
    /* ################################################################## */
    /**
     This is the maskedValue() extension function test (Signed Int).
     */
    func testMaskInt() {
        // 0xF30 (Value, in hex) 111100110000 (Value, in binary)
        let targetTest = 3888
        // 111111111111 (Mask, in binary)
        XCTAssertEqual(3888, targetTest.maskedValue(firstPlace: 0, runLength: 12))
        // 111111110000
        XCTAssertEqual(243, targetTest.maskedValue(firstPlace: 4, runLength: 8))
        // 000000000011
        XCTAssertEqual(0, targetTest.maskedValue(firstPlace: 0, runLength: 2))
        // 000000111100
        XCTAssertEqual(12, targetTest.maskedValue(firstPlace: 2, runLength: 4))
        // 000111100000
        XCTAssertEqual(9, targetTest.maskedValue(firstPlace: 5, runLength: 4))
        // 011111111111
        XCTAssertEqual(1840, targetTest.maskedValue(firstPlace: 0, runLength: 11))
        // 111111111110
        XCTAssertEqual(1944, targetTest.maskedValue(firstPlace: 1, runLength: 11))
        // 000000110000
        XCTAssertEqual(3, targetTest.maskedValue(firstPlace: 4, runLength: 2))
        // 000001100000
        XCTAssertEqual(1, targetTest.maskedValue(firstPlace: 5, runLength: 2))
        // 000011000000
        XCTAssertEqual(0, targetTest.maskedValue(firstPlace: 6, runLength: 2))

        // 111111111111 (Mask, in binary)
        XCTAssertEqual(3888, 3888.maskedValue(firstPlace: 0, runLength: 12))
        // 111111110000
        XCTAssertEqual(243, 3888.maskedValue(firstPlace: 4, runLength: 8))
        // 000000000011
        XCTAssertEqual(0, 3888.maskedValue(firstPlace: 0, runLength: 2))
        // 000000111100
        XCTAssertEqual(12, 3888.maskedValue(firstPlace: 2, runLength: 4))
        // 000111100000
        XCTAssertEqual(9, 3888.maskedValue(firstPlace: 5, runLength: 4))
        // 011111111111
        XCTAssertEqual(1840, 3888.maskedValue(firstPlace: 0, runLength: 11))
        // 111111111110
        XCTAssertEqual(1944, 3888.maskedValue(firstPlace: 1, runLength: 11))
        // 000000110000
        XCTAssertEqual(3, 3888.maskedValue(firstPlace: 4, runLength: 2))
        // 000001100000
        XCTAssertEqual(1, 3888.maskedValue(firstPlace: 5, runLength: 2))
        // 000011000000
        XCTAssertEqual(0, 3888.maskedValue(firstPlace: 6, runLength: 2))
        
        let maxSize = (MemoryLayout<Int>.size * 8) - 1
        let testVal = Int.max
        
        for indent in 1...maxSize {
            XCTAssertEqual(testVal >> indent, testVal.maskedValue(firstPlace: 0, runLength: maxSize - indent))
            if indent == maxSize {
                XCTAssertEqual(0, testVal.maskedValue(firstPlace: indent, runLength: 1))
            } else {
                XCTAssertEqual(1, testVal.maskedValue(firstPlace: indent, runLength: 1))
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the maskedValue() extension function test (Unsigned Int).
     */
    func testMaskUInt() {
        // 0xF30 (Value, in hex) 111100110000 (Value, in binary)
        let targetTest = UInt(3888)
        // 111111111111 (Mask, in binary)
        XCTAssertEqual(3888, targetTest.maskedValue(firstPlace: 0, runLength: 12))
        // 111111110000
        XCTAssertEqual(243, targetTest.maskedValue(firstPlace: 4, runLength: 8))
        // 000000000011
        XCTAssertEqual(0, targetTest.maskedValue(firstPlace: 0, runLength: 2))
        // 000000111100
        XCTAssertEqual(12, targetTest.maskedValue(firstPlace: 2, runLength: 4))
        // 000111100000
        XCTAssertEqual(9, targetTest.maskedValue(firstPlace: 5, runLength: 4))
        // 011111111111
        XCTAssertEqual(1840, targetTest.maskedValue(firstPlace: 0, runLength: 11))
        // 111111111110
        XCTAssertEqual(1944, targetTest.maskedValue(firstPlace: 1, runLength: 11))
        // 000000110000
        XCTAssertEqual(3, targetTest.maskedValue(firstPlace: 4, runLength: 2))
        // 000001100000
        XCTAssertEqual(1, targetTest.maskedValue(firstPlace: 5, runLength: 2))
        // 000011000000
        XCTAssertEqual(0, targetTest.maskedValue(firstPlace: 6, runLength: 2))

        // 111111111111 (Mask, in binary)
        XCTAssertEqual(3888, UInt(3888).maskedValue(firstPlace: 0, runLength: 12))
        // 111111110000
        XCTAssertEqual(243, UInt(3888).maskedValue(firstPlace: 4, runLength: 8))
        // 000000000011
        XCTAssertEqual(0, UInt(3888).maskedValue(firstPlace: 0, runLength: 2))
        // 000000111100
        XCTAssertEqual(12, UInt(3888).maskedValue(firstPlace: 2, runLength: 4))
        // 000111100000
        XCTAssertEqual(9, UInt(3888).maskedValue(firstPlace: 5, runLength: 4))
        // 011111111111
        XCTAssertEqual(1840, UInt(3888).maskedValue(firstPlace: 0, runLength: 11))
        // 111111111110
        XCTAssertEqual(1944, UInt(3888).maskedValue(firstPlace: 1, runLength: 11))
        // 000000110000
        XCTAssertEqual(3, UInt(3888).maskedValue(firstPlace: 4, runLength: 2))
        // 000001100000
        XCTAssertEqual(1, UInt(3888).maskedValue(firstPlace: 5, runLength: 2))
        // 000011000000
        XCTAssertEqual(0, UInt(3888).maskedValue(firstPlace: 6, runLength: 2))
        
        let maxSize = MemoryLayout<UInt>.size * 8
        let testVal = UInt.max
        
        for indent in 1..<maxSize {
            XCTAssertEqual(testVal >> indent, testVal.maskedValue(firstPlace: 0, runLength: UInt(maxSize - indent)))
            XCTAssertEqual(1, testVal.maskedValue(firstPlace: UInt(indent), runLength: 1))
        }
    }
    
    /* ################################################################## */
    /**
     This is the maskedValue() extension function test (Unsigned Int 64).
     */
    func testMaskUInt64() {
        // 0xF30 (Value, in hex) 111100110000 (Value, in binary)
        let targetTest = UInt64(3888)
        // 111111111111 (Mask, in binary)
        XCTAssertEqual(3888, targetTest.maskedValue(firstPlace: 0, runLength: 12))
        // 111111110000
        XCTAssertEqual(243, targetTest.maskedValue(firstPlace: 4, runLength: 8))
        // 000000000011
        XCTAssertEqual(0, targetTest.maskedValue(firstPlace: 0, runLength: 2))
        // 000000111100
        XCTAssertEqual(12, targetTest.maskedValue(firstPlace: 2, runLength: 4))
        // 000111100000
        XCTAssertEqual(9, targetTest.maskedValue(firstPlace: 5, runLength: 4))
        // 011111111111
        XCTAssertEqual(1840, targetTest.maskedValue(firstPlace: 0, runLength: 11))
        // 111111111110
        XCTAssertEqual(1944, targetTest.maskedValue(firstPlace: 1, runLength: 11))
        // 000000110000
        XCTAssertEqual(3, targetTest.maskedValue(firstPlace: 4, runLength: 2))
        // 000001100000
        XCTAssertEqual(1, targetTest.maskedValue(firstPlace: 5, runLength: 2))
        // 000011000000
        XCTAssertEqual(0, targetTest.maskedValue(firstPlace: 6, runLength: 2))

        // 111111111111 (Mask, in binary)
        XCTAssertEqual(3888, UInt64(3888).maskedValue(firstPlace: 0, runLength: 12))
        // 111111110000
        XCTAssertEqual(243, UInt64(3888).maskedValue(firstPlace: 4, runLength: 8))
        // 000000000011
        XCTAssertEqual(0, UInt64(3888).maskedValue(firstPlace: 0, runLength: 2))
        // 000000111100
        XCTAssertEqual(12, UInt64(3888).maskedValue(firstPlace: 2, runLength: 4))
        // 000111100000
        XCTAssertEqual(9, UInt64(3888).maskedValue(firstPlace: 5, runLength: 4))
        // 011111111111
        XCTAssertEqual(1840, UInt64(3888).maskedValue(firstPlace: 0, runLength: 11))
        // 111111111110
        XCTAssertEqual(1944, UInt64(3888).maskedValue(firstPlace: 1, runLength: 11))
        // 000000110000
        XCTAssertEqual(3, UInt64(3888).maskedValue(firstPlace: 4, runLength: 2))
        // 000001100000
        XCTAssertEqual(1, UInt64(3888).maskedValue(firstPlace: 5, runLength: 2))
        // 000011000000
        XCTAssertEqual(0, UInt64(3888).maskedValue(firstPlace: 6, runLength: 2))
        
        let maxSize = MemoryLayout<UInt64>.size * 8
        let testVal = UInt64.max
        
        for indent in 1..<maxSize {
            XCTAssertEqual(testVal >> indent, testVal.maskedValue(firstPlace: 0, runLength: UInt(maxSize - indent)))
            XCTAssertEqual(1, testVal.maskedValue(firstPlace: UInt(indent), runLength: 1))
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - NSLocalizedString Override -
/* ###################################################################################################################################### */
/**
 We override this, because we are running a test, so the bundle is in the XCTest bundle. We override this to intercept the standard call, and reference the testing bundle.
 
 - parameters:
    - inKey: The String we are using to key the token.
    - comment: Ignored
 
 - returns: The localized String (if the key matches).
 */
public func NSLocalizedString(_ inKey: String, comment: String) -> String {
    let bundle = Bundle(for: RVS_String_Extensions_Tests.self)
    return NSLocalizedString(inKey, tableName: nil, bundle: bundle, comment: "")
}

/* ###################################################################################################################################### */
// MARK: - Debug Tools Tests -
/* ###################################################################################################################################### */
/**
 These are specific unit tests for the Debug Tools.
 */
class RVS_DebugTools_Tests: XCTestCase {
    /* ################################################################## */
    /**
     Just a flag to see if we are running as a test case.
     
     Unfortunately, we can't test if we AREN'T running as a test, because...heisenbug.
     */
    func testIsRunningDebug() {
        XCTAssertTrue(RVS_DebugTools.isRunningUnitTests)
    }
}

/* ###################################################################################################################################### */
// MARK: - RVS_String_Extensions_Tests -
/* ###################################################################################################################################### */
/**
 These are specific unit tests for the StringProtocol extension.
 */
class RVS_String_Extensions_Tests: XCTestCase {
    /* ################################################################## */
    /**
     Test our localizedVariant computed property.
     */
    func testLocalizedVariant() {
        XCTAssertEqual("Test String 1", "TEST-1-SLUG".localizedVariant)
        XCTAssertEqual("Test String Two", "TEST-2-SLUG".localizedVariant)
    }
    
    /* ################################################################## */
    /**
     Test our md5 computed property.
     */
    func testMD5() {
        XCTAssertEqual("860820C8ABCB42F9C831CB5CA982A06D", "How now, brown cow?".md5)
        XCTAssertEqual("DC8BD40E7C60AA1D8EA9E450DAE4DDFB", "The Foxy Cabbage Absconds With the Sleepy Canine.".md5)
        XCTAssertEqual("A0FF1D5CC6CFC4A81C91EFDA93C77187", "All Your Bases Belongs To Us!".md5)
        
        let testString1 = "Luke, I Am Your Farter!"
        XCTAssertEqual("97EA9B296503B4A173C182829BDD5E49", testString1.md5)
        
        let testString2 = ""
        XCTAssertEqual("D41D8CD98F00B204E9800998ECF8427E", testString2.md5)
    }
    
    /* ################################################################## */
    /**
     Test our UUID scrubber computed property.
     */
    func testUUIDParser() {
        XCTAssertEqual("0123", "0123".uuidFormat)
        XCTAssertNil("01234".uuidFormat)
        XCTAssertNil("0123A".uuidFormat)
        XCTAssertEqual("0123", "0123g".uuidFormat)
        XCTAssertEqual("0123", "0123-".uuidFormat)
        XCTAssertEqual("01234567-8901-2345-6789-012345678901", "01234567890123456789012345678901".uuidFormat)
        
        XCTAssertEqual("01234567-89AB-CDEF-0123-456789ABCDEF", "0123456789ABcdEf0123456789abcdEF".uuidFormat)
        
        XCTAssertEqual("01234567-89AB-CDEF-0123-456789ABCDEF", "0123456789ABcdEf012345RowRowRowYour6789abcdEFShip".uuidFormat)

        XCTAssertEqual("89AB", "89a-b".uuidFormat)
        
        XCTAssertEqual("89AB", "89axb".uuidFormat)
    }
    
    /* ################################################################## */
    /**
     Test our md5 computed property.
     */
    func testSHA256() {
        XCTAssertEqual("B21E0C613CEEC9A65AFB9FD0E25E58BE7BA5CAB933F40A89AE45BB52A92116D7", "How now, brown cow?".sha256)
        XCTAssertEqual("902F24E682A0F016F64D8C16DA76897AD0726B44A07FCC412D98D48D52B37F0B", "The Foxy Cabbage Absconds With the Sleepy Canine.".sha256)
        XCTAssertEqual("1E2847A4A9E34B70C3B196241BFE0CA2B4D4FEBA8E39DDE200C6081EE1792AD9", "All Your Bases Belongs To Us!".sha256)
        
        let testString1 = "Luke, I Am Your Farter!"
        XCTAssertEqual("1FC51E504917018E57B6D52371552339CEF83BEEE0D4BA1360F54CBCACDF3387", testString1.sha256)
        
        let testString2 = ""
        XCTAssertEqual("E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855", testString2.sha256)
    }
    
    /* ################################################################## */
    /**
     Test the two hexDump8/16 computed properties.
     */
    func testHexDumps() {
        let testTarget = "05FE6410ACD6"
        XCTAssertEqual(["30", "35", "46", "45", "36", "34", "31", "30", "41", "43", "44", "36"], testTarget.hexDump8)
        XCTAssertEqual(["0030", "0035", "0046", "0045", "0036", "0034", "0031", "0030", "0041", "0043", "0044", "0036"], testTarget.hexDump16)
    }
    
    /* ################################################################## */
    /**
     Test the firstUppercased computed property.
     */
    func testFirstUppercased() {
        let testTarget = "john jacob jingleheimerschmidt"
        XCTAssertEqual("John jacob jingleheimerschmidt", testTarget.firstUppercased)
    }
    
    /* ################################################################## */
    /**
     Test the URL encoding/decoding computed properties.
     */
    func testURLEncoding() {
        let testTarget = "Sticks & Stones-May/Break+My%Bones"
        let urlencoded = testTarget.urlEncodedString
        XCTAssertEqual("Sticks%20&%20Stones-May/Break+My%25Bones", urlencoded)
        XCTAssertEqual("Sticks & Stones-May/Break+My%Bones", urlencoded?.urlDecodedString)
    }
    
    /* ################################################################## */
    /**
     Test the various "XXOnly" computed properties.
     */
    func testBinaryOctalHexOnly() {
        let testTarget = "1 Is Too Many, A Thousand Never Enough, Unless you have 2, 7, 8, or 9 more than 0."
        XCTAssertEqual("10", testTarget.binaryOnly)
        XCTAssertEqual("1270", testTarget.octalOnly)
        XCTAssertEqual("127890", testTarget.decimalOnly)
        XCTAssertEqual("1AAADEEEEAE2789EA0", testTarget.hexOnly)
    }
    
    /* ################################################################## */
    /**
     Test the UTF8 converter computed property.
     */
    func testHex2UTF8() {
        var testTarget = "30 35 46 45 36 34 31 30 41 43 44 36"
        XCTAssertEqual("05FE6410ACD6", testTarget.hex2UTF8)
        testTarget = "30354645 36 34 31 304143 44 36"
        XCTAssertEqual("05FE6410ACD6", testTarget.hex2UTF8)
        testTarget = "30354645D36 34 31 304143 44 36"
        XCTAssertEqual("05FEÓ410ACD6", testTarget.hex2UTF8)
        testTarget = "30354645 D 36 34 31 304143 44 36"
        XCTAssertEqual("05FE6410ACD6", testTarget.hex2UTF8)
    }
    
    /* ################################################################## */
    /**
     Test the Int converter computed property.
     */
    func testHex2Int() {
        let testTarget = "20"
        XCTAssertEqual(32, testTarget.hex2Int)
        XCTAssertEqual(61696, "F100".hex2Int)
        XCTAssertEqual(3, "3".hex2Int)
        XCTAssertNil("G".hex2Int)
        XCTAssertEqual(238, "George".hex2Int)
    }
    
    /* ################################################################## */
    /**
     This tests the various substring methods of the extension.
     */
    func testSubstringFinder() {
        let testString = "Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal.\nNow we are engaged in a great civil war, testing whether that nation, or any nation so conceived and so dedicated, can long endure. We are met on a great battle-field of that war. We have come to dedicate a portion of that field, as a final resting place for those who here gave their lives that that nation might live. It is altogether fitting and proper that we should do this.\nBut, in a larger sense, we can not dedicate—we can not consecrate—we can not hallow—this ground. The brave men, living and dead, who struggled here, have consecrated it, far above our poor power to add or detract. The world will little note, nor long remember what we say here, but it can never forget what they did here. It is for us the living, rather, to be dedicated here to the unfinished work which they who fought here have thus far so nobly advanced. It is rather for us to be here dedicated to the great task remaining before us—that from these honored dead we take increased devotion to that cause for which they gave the last full measure of devotion—that we here highly resolve that these dead shall not have died in vain—that this nation, under God, shall have a new birth of freedom—and that government of the people, by the people, for the people, shall not perish from the earth."
        
        if let substringIndex = testString.index(of: "Four") {
            XCTAssertEqual(0, testString.distance(from: testString.startIndex, to: substringIndex))
        } else {
            XCTFail("Invalid Substring Response")
        }
        
        if let substringIndex = testString.index(of: "score") {
            XCTAssertEqual(5, testString.distance(from: testString.startIndex, to: substringIndex))
        } else {
            XCTFail("Invalid Substring Response")
        }

        if let substringIndex = testString.endIndex(of: "score") {
            XCTAssertEqual(10, testString.distance(from: testString.startIndex, to: substringIndex))
        } else {
            XCTFail("Invalid Substring Response")
        }
        
        if let substringIndex = testString.index(of: "seven") {
            XCTAssertEqual(15, testString.distance(from: testString.startIndex, to: substringIndex))
        } else {
            XCTFail("Invalid Substring Response")
        }
        
        if let substringIndex = testString.endIndex(of: "seven") {
            XCTAssertEqual(20, testString.distance(from: testString.startIndex, to: substringIndex))
        } else {
            XCTFail("Invalid Substring Response")
        }

        if let substringIndex = testString.index(of: "we here highly resolve") {
            XCTAssertEqual(1224, testString.distance(from: testString.startIndex, to: substringIndex))
        } else {
            XCTFail("Invalid Substring Response")
        }
        
        let rangesOf1 = testString.ranges(of: "We")
        XCTAssertEqual(2, rangesOf1.count)
        XCTAssertEqual(309, testString.distance(from: testString.startIndex, to: rangesOf1[0].lowerBound))
        XCTAssertEqual(311, testString.distance(from: testString.startIndex, to: rangesOf1[0].upperBound))
        XCTAssertEqual(357, testString.distance(from: testString.startIndex, to: rangesOf1[1].lowerBound))
        XCTAssertEqual(359, testString.distance(from: testString.startIndex, to: rangesOf1[1].upperBound))

        let rangesOf2 = testString.ranges(of: "we")
        XCTAssertEqual(9, rangesOf2.count)
        XCTAssertEqual(181, testString.distance(from: testString.startIndex, to: rangesOf2[0].lowerBound))
        XCTAssertEqual(183, testString.distance(from: testString.startIndex, to: rangesOf2[0].upperBound))
        XCTAssertEqual(1224, testString.distance(from: testString.startIndex, to: rangesOf2[8].lowerBound))
        XCTAssertEqual(1226, testString.distance(from: testString.startIndex, to: rangesOf2[8].upperBound))
        
        let rangesOf3 = testString.ranges(of: "WE", options: [.caseInsensitive])
        XCTAssertEqual(11, rangesOf3.count)
        XCTAssertEqual(181, testString.distance(from: testString.startIndex, to: rangesOf3[0].lowerBound))
        XCTAssertEqual(183, testString.distance(from: testString.startIndex, to: rangesOf3[0].upperBound))
        XCTAssertEqual(1224, testString.distance(from: testString.startIndex, to: rangesOf3[10].lowerBound))
        XCTAssertEqual(1226, testString.distance(from: testString.startIndex, to: rangesOf3[10].upperBound))

        let rangesOf4 = testString.ranges(of: "w")
        XCTAssertEqual(26, rangesOf4.count)
        XCTAssertEqual(80, testString.distance(from: testString.startIndex, to: rangesOf4[0].lowerBound))
        XCTAssertEqual(81, testString.distance(from: testString.startIndex, to: rangesOf4[0].upperBound))
        XCTAssertEqual(1335, testString.distance(from: testString.startIndex, to: rangesOf4[25].lowerBound))
        XCTAssertEqual(1336, testString.distance(from: testString.startIndex, to: rangesOf4[25].upperBound))
        
        let indexesOf1 = testString.indexes(of: "We")
        XCTAssertEqual(2, indexesOf1.count)
        XCTAssertEqual(309, testString.distance(from: testString.startIndex, to: indexesOf1[0]))
        XCTAssertEqual(357, testString.distance(from: testString.startIndex, to: indexesOf1[1]))
        
        let indexesOf2 = testString.indexes(of: "we")
        XCTAssertEqual(9, indexesOf2.count)
        XCTAssertEqual(181, testString.distance(from: testString.startIndex, to: indexesOf2[0]))
        XCTAssertEqual(1224, testString.distance(from: testString.startIndex, to: indexesOf2[8]))
        
        let indexesOf3 = testString.indexes(of: "WE", options: [.caseInsensitive])
        XCTAssertEqual(11, rangesOf3.count)
        XCTAssertEqual(181, testString.distance(from: testString.startIndex, to: indexesOf3[0]))
        XCTAssertEqual(1224, testString.distance(from: testString.startIndex, to: indexesOf3[10]))
    }
}
