//
//  SupportTests.swift
//  StringUtilities
//
//  The Support functions tested on their own, without going through the
//  public faces. Each is a fixed input with one right answer.
//

import XCTest
@testable import StringUtilities

final class CaseConversionSupportTests: XCTestCase {

    func testWordsSplitOnPunctuationFirst() {
        XCTAssertEqual(CaseConversion.words(in: "hello_world-foo bar"), ["hello", "world", "foo", "bar"])
    }

    func testWordsFallBackToSplittingAnIdentifierOnItsCapitals() {
        XCTAssertEqual(CaseConversion.words(in: "helloWorld"), ["hello", "World"])
        XCTAssertEqual(CaseConversion.words(in: "HTTPServer"), ["HTTP", "Server"])
    }

    func testTextWithNoWordsHasNone() {
        XCTAssertEqual(CaseConversion.words(in: "!!!"), [])
    }

    func testAlternatingSurvivesALetterWhoseUppercaseIsTwoCharacters() {
        // "ß".uppercased() is "SS"; Character("SS") traps. This used to crash.
        XCTAssertEqual(CaseConversion.alternating("aß"), "aSS")
        XCTAssertEqual(CaseConversion.alternating("a b"), "a B")
    }
}

final class CleaningSupportTests: XCTestCase {

    func testAllCapsWordsAreCapitalisedButShortOnesAreLeftAsAcronyms() {
        XCTAssertEqual(Cleaning.fixAllCaps("NASA SPEAKS HELLO"), "NASA Speaks Hello")
    }

    func testRunsOfSpacesAndTabsCollapseToOneSpace() {
        XCTAssertEqual(Cleaning.collapseSpaces("a \t  b"), "a b")
    }

    func testWindowsAndClassicMacLineBreaksBecomeNewlines() {
        XCTAssertEqual(Cleaning.normalizeLineBreaks("a\r\nb\rc"), "a\nb\nc")
    }

    func testInvisibleCharactersAreRemoved() {
        XCTAssertEqual(Cleaning.removeInvisible("a\u{200B}b\u{FEFF}"), "ab")
    }

    func testThreeOrMoreLineBreaksBecomeTwo() {
        XCTAssertEqual(Cleaning.collapseLineBreaks("a\n\n\n\nb"), "a\n\nb")
    }
}

final class ListProcessingSupportTests: XCTestCase {

    func testDeduplicationIgnoresCaseAndKeepsTheFirstSpelling() {
        XCTAssertEqual(ListProcessing.deduplicated(["Apple", "apple", "b"], caseSensitive: false), ["Apple", "b"])
        XCTAssertEqual(ListProcessing.deduplicated(["Apple", "apple", "b"], caseSensitive: true), ["Apple", "apple", "b"])
    }

    func testNaturalSortPutsItem2BeforeItem10() {
        XCTAssertEqual(ListProcessing.sorted(["item10", "item2", "item1"], by: .natural, caseSensitive: false), ["item1", "item2", "item10"])
    }

    func testBlankItemsAreSkippedWhenDecorating() {
        XCTAssertEqual(ListProcessing.numbered("a\n \n b", separator: "\n", startIndex: 1), "1. a\n2. b")
        XCTAssertEqual(ListProcessing.bulleted("a\n\nb", bullet: "-", separator: "\n"), "- a\n- b")
    }
}

final class TextEditingSupportTests: XCTestCase {

    func testTruncatingShorterThanTheEllipsisGivesTheEllipsis() {
        // prefix(-1) used to trap here.
        XCTAssertEqual(TextEditing.truncate("hello world", to: 2, ellipsis: "..."), "...")
    }

    func testWrapNeverCutsAWord() {
        XCTAssertEqual(TextEditing.wrap("aaa bbb ccc", width: 7), "aaa bbb\nccc")
        XCTAssertEqual(TextEditing.wrap("abcdefghij", width: 3), "abcdefghij")
    }

    func testReplaceBetweenIsNilWhenADelimiterIsMissing() {
        XCTAssertNil(TextEditing.replaceBetween(in: "a [b", start: "[", end: "]", with: "x"))
        XCTAssertEqual(TextEditing.replaceBetween(in: "a [b] c", start: "[", end: "]", with: "x"), "a [x] c")
    }
}

final class TextAnalysisSupportTests: XCTestCase {

    func testAnEmptyNeedleIsFoundNowhere() {
        XCTAssertEqual(TextAnalysis.occurrences(of: "", in: "abc", caseSensitive: true), 0)
    }

    func testWordsDropPunctuationSoFoxAndFoxDotMatch() {
        XCTAssertEqual(TextAnalysis.words(in: "The fox. the fox!", caseSensitive: false), ["the", "fox", "the", "fox"])
        XCTAssertEqual(TextAnalysis.uniqueWords(in: "The fox. the fox!", caseSensitive: false), ["fox", "the"])
    }
}

final class CSVEscapingSupportTests: XCTestCase {

    func testQuotesInsideAFieldAreDoubled() {
        XCTAssertEqual(CSVEscaping.escape("say \"hi\""), "\"say \"\"hi\"\"\"")
        XCTAssertEqual(CSVEscaping.escape("plain"), "plain")
    }
}
