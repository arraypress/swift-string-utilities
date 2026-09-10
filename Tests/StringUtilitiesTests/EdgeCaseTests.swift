//
//  EdgeCaseTests.swift
//  StringUtilities
//
//  Every public function at its edges: empty, whitespace-only, unicode that
//  is one character but several scalars, Windows line breaks, very long
//  input, every option alone and combined. Fixed inputs, one right answer.
//

import XCTest
@testable import StringUtilities

// MARK: - StringCleaner

final class StringCleanerEdgeTests: XCTestCase {

    private let everyFlag: [StringCleaner.Options] = [
        .removeExtraSpaces, .removeEmptyLines, .trimWhitespace, .normalizeLineBreaks,
        .fixAllCaps, .removeExtraLineBreaks, .removeInvisible, .normalizeQuotes,
    ]

    func testEmptyTextStaysEmptyUnderEveryOption() {
        for flag in everyFlag {
            XCTAssertEqual(StringCleaner.clean("", options: flag), "")
        }
        XCTAssertEqual(StringCleaner.clean("", options: .all), "")
    }

    func testWhitespaceOnlyTextCollapsesOrVanishesDependingOnTheOption() {
        XCTAssertEqual(StringCleaner.clean("   \t  ", options: .removeExtraSpaces), " ")
        XCTAssertEqual(StringCleaner.clean("   \t  ", options: .trimWhitespace), "")
        XCTAssertEqual(StringCleaner.clean("   \t  ", options: .standard), "")
        XCTAssertEqual(StringCleaner.clean(" \n \n ", options: .removeEmptyLines), "")
    }

    func testRemoveExtraSpacesAloneLeavesLineBreaksAndEdgesAlone() {
        XCTAssertEqual(StringCleaner.clean(" a  \t b\n\n c ", options: .removeExtraSpaces), " a b\n\n c ")
    }

    func testRemoveEmptyLinesAloneDropsBlankLinesOnly() {
        XCTAssertEqual(StringCleaner.clean("a\n \n\t\n\nb", options: .removeEmptyLines), "a\nb")
    }

    func testTrimWhitespaceAloneTrimsNonBreakingSpacesToo() {
        XCTAssertEqual(StringCleaner.clean("\u{00A0} a \u{00A0}\n", options: .trimWhitespace), "a")
    }

    func testNormalizeLineBreaksAloneHandlesWindowsAndClassicMac() {
        XCTAssertEqual(StringCleaner.clean("a\r\nb\rc\nd", options: .normalizeLineBreaks), "a\nb\nc\nd")
    }

    func testFixAllCapsAloneLeavesAcronymsPunctuationAndMixedWordsAlone() {
        XCTAssertEqual(StringCleaner.clean("HELLO NASA HELLO! Hello", options: .fixAllCaps), "Hello NASA HELLO! Hello")
    }

    func testFixAllCapsDoesNotTouchAWordThatRunsIntoALineBreak() {
        XCTAssertEqual(StringCleaner.clean("HELLO\nWORLD", options: .fixAllCaps), "HELLO\nWORLD")
    }

    func testRemoveExtraLineBreaksAloneKeepsOneBlankLine() {
        XCTAssertEqual(StringCleaner.clean("a\n\n\n\n\nb\n\nc", options: .removeExtraLineBreaks), "a\n\nb\n\nc")
    }

    func testRemoveInvisibleAloneStripsEveryZeroWidthCharacter() {
        XCTAssertEqual(StringCleaner.clean("\u{FEFF}a\u{200B}b\u{200C}c\u{200D}d", options: .removeInvisible), "abcd")
    }

    func testNormalizeQuotesAloneHandlesEveryTypographicForm() {
        let text = "\u{201C}a\u{201D} \u{2018}b\u{2019} \u{00AB}c\u{00BB} \u{201E}d"
        XCTAssertEqual(StringCleaner.clean(text, options: .normalizeQuotes), "\"a\" 'b' \"c\" \"d")
    }

    func testAllOptionsTogetherOnAMessyFixture() {
        // The quoted word and the exclaimed one are not all letters, and DONE has
        // only four, so SHOUTING is the one word that gets capitalised.
        let messy = "\u{FEFF}  \u{201C}HELLO\u{201D}   SHOUTING WORLD!\r\n\r\n\r\n\r\n   \r\nDONE   "
        XCTAssertEqual(StringCleaner.clean(messy, options: .all), "\"HELLO\" Shouting WORLD!\nDONE")
    }

    func testTheOrderOfStepsIsFixedRegardlessOfHowTheSetWasWritten() {
        let text = "a\r\n\r\n\r\n\r\nb"
        let a = StringCleaner.clean(text, options: [.removeExtraLineBreaks, .normalizeLineBreaks])
        let b = StringCleaner.clean(text, options: [.normalizeLineBreaks, .removeExtraLineBreaks])
        XCTAssertEqual(a, "a\n\nb")
        XCTAssertEqual(a, b)
    }

    func testPresetsContainWhatTheyClaim() {
        XCTAssertEqual(StringCleaner.Options.standard, [.removeExtraSpaces, .trimWhitespace])
        XCTAssertEqual(StringCleaner.Options.aggressive, [.removeExtraSpaces, .removeEmptyLines, .trimWhitespace, .normalizeLineBreaks])
        for flag in everyFlag {
            XCTAssertTrue(StringCleaner.Options.all.contains(flag))
        }
        XCTAssertEqual(StringCleaner.Options.all.rawValue, 255)
    }

    func testOptionsRoundTripThroughTheirRawValue() {
        XCTAssertEqual(StringCleaner.Options(rawValue: 3), [.removeExtraSpaces, .removeEmptyLines])
        XCTAssertEqual(StringCleaner.Options(rawValue: 0), [])
    }

    func testCombiningMarksAndEmojiSurviveCleaning() {
        XCTAssertEqual(StringCleaner.clean("  e\u{301}   🙂  🇬🇧 ", options: .all), "e\u{301} 🙂 🇬🇧")
    }

    func testWindowsLineBreaksBecomeSingleLinesWhenNormalisedAndEmptied() {
        XCTAssertEqual(StringCleaner.clean("a\r\n\r\nb\r\n", options: [.normalizeLineBreaks, .removeEmptyLines]), "a\nb")
    }

    func testAMegabyteCleansInReasonableTime() {
        let text = String(repeating: "word  ", count: 200_000)
        let start = Date()
        let cleaned = StringCleaner.clean(text, options: .all)
        XCTAssertLessThan(Date().timeIntervalSince(start), 5)
        XCTAssertEqual(cleaned.wordCount, 200_000)
    }

    func testIsNotEmptyTreatsEveryKindOfWhitespaceAsEmpty() {
        XCTAssertFalse(StringCleaner.isNotEmpty(""))
        XCTAssertFalse(StringCleaner.isNotEmpty("   \n\t\r\n"))
        XCTAssertFalse(StringCleaner.isNotEmpty("\u{00A0}"))
        XCTAssertTrue(StringCleaner.isNotEmpty(" a "))
        XCTAssertTrue(StringCleaner.isNotEmpty("🙂"))
    }

    func testNormalizeQuotesLeavesTextWithoutQuotesUntouched() {
        XCTAssertEqual(StringCleaner.normalizeQuotes(""), "")
        XCTAssertEqual(StringCleaner.normalizeQuotes("no quotes here"), "no quotes here")
        XCTAssertEqual(StringCleaner.normalizeQuotes("\"already\" 'straight'"), "\"already\" 'straight'")
    }
}

// MARK: - ListProcessor

final class ListProcessorEdgeTests: XCTestCase {

    func testEmptyAndWhitespaceOnlyListsComeBackEmpty() {
        XCTAssertEqual(ListProcessor.process(""), "")
        XCTAssertEqual(ListProcessor.process(" \n \n"), "")
        XCTAssertEqual(ListProcessor.process(" \n ", options: .init(removeEmpty: false)), "\n")
    }

    func testACustomSeparatorIsSplitOnAndJoinedWith() {
        XCTAssertEqual(ListProcessor.process("b, a ,c", separator: ",", sortOrder: .ascending), "a,b,c")
        XCTAssertEqual(ListProcessor.process("b|a", separator: "|"), "b|a")
    }

    func testEverySortOrder() {
        let mixed = "banana\nApple\ncherry"
        XCTAssertEqual(ListProcessor.process(mixed, sortOrder: .ascending), "Apple\nbanana\ncherry")
        XCTAssertEqual(ListProcessor.process(mixed, sortOrder: .descending), "cherry\nbanana\nApple")
        XCTAssertEqual(ListProcessor.process("ccc\na\nbb", sortOrder: .byLength), "a\nbb\nccc")
        XCTAssertEqual(ListProcessor.process("ccc\na\nbb", sortOrder: .byLengthDescending), "ccc\nbb\na")
        XCTAssertEqual(ListProcessor.process("item10\nitem2\nitem1", sortOrder: .natural), "item1\nitem2\nitem10")
        let shuffled = ListProcessor.process("a\nb\nc\nd", sortOrder: .random)
        XCTAssertEqual(shuffled.components(separatedBy: "\n").sorted(), ["a", "b", "c", "d"])
    }

    func testNumbersSortAsTextUnlessTheOrderIsNatural() {
        XCTAssertEqual(ListProcessor.process("10\n9\n2", sortOrder: .ascending), "10\n2\n9")
        XCTAssertEqual(ListProcessor.process("10\n9\n2", sortOrder: .natural), "2\n9\n10")
        XCTAssertEqual(ListProcessor.process("10\n9\n2", sortOrder: .descending), "9\n2\n10")
    }

    func testCaseSensitivityChangesBothSortingAndDeduplication() {
        let list = "banana\nApple\napple"
        XCTAssertEqual(ListProcessor.process(list, sortOrder: .ascending, options: .init(caseSensitive: true)), "Apple\napple\nbanana")
        XCTAssertEqual(ListProcessor.process(list, sortOrder: .ascending, options: .init(removeDuplicates: true)), "Apple\nbanana")
        XCTAssertEqual(ListProcessor.process(list, sortOrder: .ascending, options: .init(removeDuplicates: true, caseSensitive: true)), "Apple\napple\nbanana")
    }

    func testDuplicatesAreFoundAfterTrimmingAndTheFirstSpellingWins() {
        XCTAssertEqual(ListProcessor.process("a\n a \nA", options: .init(removeDuplicates: true)), "a")
        XCTAssertEqual(ListProcessor.process("Apple\napple", options: .init(removeDuplicates: true)), "Apple")
    }

    func testTrimmingCanBeTurnedOff() {
        XCTAssertEqual(ListProcessor.process(" a \n b ", options: .init(trimItems: false)), " a \n b ")
    }

    func testOptionsDefaults() {
        let options = ListProcessor.Options()
        XCTAssertFalse(options.removeDuplicates)
        XCTAssertTrue(options.removeEmpty)
        XCTAssertTrue(options.trimItems)
        XCTAssertFalse(options.caseSensitive)
    }

    func testSortLinesWithAndWithoutDeduplication() {
        XCTAssertEqual(ListProcessor.sortLines("b\na\nb", order: .ascending), "a\nb\nb")
        XCTAssertEqual(ListProcessor.sortLines("b\na\nb", order: .ascending, removeDuplicates: true), "a\nb")
    }

    func testDeduplicateLinesKeepsTheFirstOccurrenceInPlace() {
        XCTAssertEqual(ListProcessor.deduplicateLines("b\na\nb\na"), "b\na")
        XCTAssertEqual(ListProcessor.deduplicateLines(""), "")
    }

    func testNumberingStartsWhereAskedIncludingZeroAndNegatives() {
        XCTAssertEqual(ListProcessor.numberList("a\nb", startIndex: 0), "0. a\n1. b")
        XCTAssertEqual(ListProcessor.numberList("a\nb", startIndex: -1), "-1. a\n0. b")
        XCTAssertEqual(ListProcessor.numberList("a,b", separator: ",", startIndex: 5), "5. a,6. b")
        XCTAssertEqual(ListProcessor.numberList(""), "")
        XCTAssertEqual(ListProcessor.numberList(" \n "), "")
    }

    func testBulletsTakeAnyMarkerAndSeparator() {
        XCTAssertEqual(ListProcessor.bulletList("a\nb", bullet: "-"), "- a\n- b")
        XCTAssertEqual(ListProcessor.bulletList("a,b", bullet: "*", separator: ","), "* a,* b")
        XCTAssertEqual(ListProcessor.bulletList("🙂\n🇬🇧"), "• 🙂\n• 🇬🇧")
        XCTAssertEqual(ListProcessor.bulletList(""), "")
    }

    func testAccentedItemsSortAfterTheirPlainLetter() {
        XCTAssertEqual(ListProcessor.process("é\nz\ne", sortOrder: .ascending), "e\né\nz")
    }

    func testWindowsLineBreaksAreNotLineSeparatorsHere() {
        // The separator is exactly "\n"; a CRLF list keeps its "\r" on each item.
        XCTAssertEqual(ListProcessor.process("b\r\na\r\n", sortOrder: .ascending), "a\r\nb\r")
        XCTAssertEqual(ListProcessor.process("b\r\na\r\n", separator: "\r\n", sortOrder: .ascending), "a\r\nb")
    }

    func testATwentyThousandLineListSortsNaturallyInReasonableTime() {
        let lines = (0..<20_000).map { "item\($0)" }.shuffled().joined(separator: "\n")
        let start = Date()
        let sorted = ListProcessor.process(lines, sortOrder: .natural)
        XCTAssertLessThan(Date().timeIntervalSince(start), 5)
        XCTAssertTrue(sorted.hasPrefix("item0\nitem1\nitem2\n"))
        XCTAssertTrue(sorted.hasSuffix("\nitem19998\nitem19999"))
    }
}

// MARK: - TextTransform

final class TextTransformEdgeTests: XCTestCase {

    private let everyStyle: [TextTransform.CaseStyle] = [
        .uppercase, .lowercase, .capitalized, .sentence, .camelCase, .pascalCase,
        .snakeCase, .kebabCase, .constantCase, .dotCase, .pathCase, .alternating,
    ]

    func testEmptyTextIsEmptyInEveryStyle() {
        for style in everyStyle {
            XCTAssertEqual(TextTransform.transform("", to: style), "", "\(style)")
        }
    }

    func testEveryStyleOnTwoWords() {
        let expected: [(TextTransform.CaseStyle, String)] = [
            (.uppercase, "HELLO WORLD"), (.lowercase, "hello world"), (.capitalized, "Hello World"),
            (.sentence, "Hello world"), (.camelCase, "helloWorld"), (.pascalCase, "HelloWorld"),
            (.snakeCase, "hello_world"), (.kebabCase, "hello-world"), (.constantCase, "HELLO_WORLD"),
            (.dotCase, "hello.world"), (.pathCase, "hello/world"), (.alternating, "hElLo WoRlD"),
        ]
        for (style, result) in expected {
            XCTAssertEqual(TextTransform.transform("hello world", to: style), result, "\(style)")
        }
    }

    func testEveryStyleRoundTripsBackToSnakeCase() {
        // Whatever case the words were written in, the words are still there.
        for style in everyStyle {
            let there = TextTransform.transform("hello world foo", to: style)
            XCTAssertEqual(TextTransform.transform(there, to: .snakeCase), "hello_world_foo", "\(style)")
        }
    }

    func testIdentifiersSplitOnTheirCapitals() {
        XCTAssertEqual(TextTransform.transform("HTTPServerError", to: .snakeCase), "http_server_error")
        XCTAssertEqual(TextTransform.transform("helloWorld", to: .kebabCase), "hello-world")
        XCTAssertEqual(TextTransform.transform("iOSApp", to: .snakeCase), "i_os_app")
    }

    func testADigitDoesNotStartANewWord() {
        XCTAssertEqual(TextTransform.transform("version2Update", to: .snakeCase), "version2update")
        XCTAssertEqual(TextTransform.transform("v2 beta", to: .camelCase), "v2Beta")
    }

    func testSentenceCaseCapitalisesAfterAFullStopAndSpace() {
        XCTAssertEqual(TextTransform.transform("hello. world. FOO", to: .sentence), "Hello. World. Foo")
        XCTAssertEqual(TextTransform.transform("hello.world", to: .sentence), "Hello.world")
    }

    func testAccentedLettersKeepTheirAccents() {
        XCTAssertEqual(TextTransform.transform("Ünïcode Wörds", to: .snakeCase), "ünïcode_wörds")
        XCTAssertEqual(TextTransform.transform("über ß", to: .alternating), "üBeR ß")
        XCTAssertEqual(TextTransform.transform("aß", to: .alternating), "aSS")
    }

    func testPunctuationOnlyTextHasNoWords() {
        XCTAssertEqual(TextTransform.transform("!!!", to: .camelCase), "!!!")
        XCTAssertEqual(TextTransform.transform("!!!", to: .snakeCase), "")
        XCTAssertEqual(TextTransform.transform("!!!", to: .pascalCase), "")
    }

    func testEmojiAreNotWords() {
        XCTAssertEqual(TextTransform.transform("hello 🙂 world", to: .snakeCase), "hello_world")
        XCTAssertEqual(TextTransform.transform("🙂", to: .alternating), "🙂")
    }

    func testAHundredThousandWordsConvertInReasonableTime() {
        let text = Array(repeating: "hello world", count: 50_000).joined(separator: " ")
        let start = Date()
        let camel = TextTransform.transform(text, to: .camelCase)
        XCTAssertLessThan(Date().timeIntervalSince(start), 5)
        XCTAssertTrue(camel.hasPrefix("helloWorldHelloWorld"))
    }
}

// MARK: - TextUtilities

final class TextUtilitiesEdgeTests: XCTestCase {

    func testCountingDoesNotOverlapAndIgnoresAnEmptyNeedle() {
        XCTAssertEqual(TextUtilities.count(of: "aa", in: "aaa"), 1)
        XCTAssertEqual(TextUtilities.count(of: "", in: "abc"), 0)
        XCTAssertEqual(TextUtilities.count(of: "a", in: ""), 0)
        XCTAssertEqual(TextUtilities.count(of: "abc", in: "ABC abc", caseSensitive: false), 2)
        XCTAssertEqual(TextUtilities.count(of: "🙂", in: "🙂🙂 🙂"), 3)
    }

    func testWordCountAtTheEdges() {
        XCTAssertEqual(TextUtilities.wordCount(of: ""), 0)
        XCTAssertEqual(TextUtilities.wordCount(of: "   \n\t"), 0)
        XCTAssertEqual(TextUtilities.wordCount(of: "a\r\nb"), 2)
        XCTAssertEqual(TextUtilities.wordCount(of: "a\u{00A0}b"), 2)
        XCTAssertEqual(TextUtilities.wordCount(of: "e\u{301} 🙂"), 2)
    }

    func testLineCountCountsWindowsLineBreaksOnce() {
        XCTAssertEqual(TextUtilities.lineCount(of: ""), 1)
        XCTAssertEqual(TextUtilities.lineCount(of: "a"), 1)
        XCTAssertEqual(TextUtilities.lineCount(of: "a\n"), 2)
        XCTAssertEqual(TextUtilities.lineCount(of: "\n"), 2)
        XCTAssertEqual(TextUtilities.lineCount(of: "a\r\nb"), 2)
        XCTAssertEqual(TextUtilities.lineCount(of: "a\nb\nc"), 3)
    }

    func testCharacterCountCountsWhatAPersonSees() {
        XCTAssertEqual(TextUtilities.characterCount(of: ""), 0)
        XCTAssertEqual(TextUtilities.characterCount(of: "e\u{301}"), 1)
        XCTAssertEqual(TextUtilities.characterCount(of: "🇬🇧"), 1)
        XCTAssertEqual(TextUtilities.characterCount(of: "a\r\nb"), 3)
    }

    func testWordExtractionAtTheEdges() {
        XCTAssertEqual(TextUtilities.extractUniqueWords(from: ""), [])
        XCTAssertEqual(TextUtilities.extractUniqueWords(from: "The the THE"), ["the"])
        XCTAssertEqual(TextUtilities.extractUniqueWords(from: "The the THE", caseSensitive: true), ["THE", "The", "the"])
        XCTAssertEqual(TextUtilities.extractWords(from: "don't stop"), ["don", "t", "stop"])
        XCTAssertEqual(TextUtilities.extractWords(from: "well-known"), ["well", "known"])
        XCTAssertEqual(TextUtilities.extractWords(from: "hi 🙂"), ["hi", "🙂"])
        XCTAssertEqual(TextUtilities.extractWords(from: "b a b"), ["b", "a", "b"])
    }

    func testReplaceBetweenAtTheEdges() {
        XCTAssertNil(TextUtilities.replaceBetween(in: "no delimiters", start: "[", end: "]", with: "x"))
        XCTAssertNil(TextUtilities.replaceBetween(in: "a [b", start: "[", end: "]", with: "x"))
        XCTAssertNil(TextUtilities.replaceBetween(in: "]a[", start: "[", end: "]", with: "x"))
        XCTAssertEqual(TextUtilities.replaceBetween(in: "[]", start: "[", end: "]", with: "x"), "[x]")
        XCTAssertEqual(TextUtilities.replaceBetween(in: "[a]", start: "[", end: "]", with: ""), "[]")
        XCTAssertEqual(TextUtilities.replaceBetween(in: "[a] [b]", start: "[", end: "]", with: "x"), "[x] [b]")
        XCTAssertEqual(TextUtilities.replaceBetween(in: "*a*", start: "*", end: "*", with: "x"), "*x*")
        XCTAssertEqual(TextUtilities.replaceBetween(in: "<🙂>", start: "<", end: ">", with: "🇬🇧"), "<🇬🇧>")
    }

    func testReversingKeepsCombinedCharactersTogether() {
        XCTAssertEqual(TextUtilities.reverse(""), "")
        XCTAssertEqual(TextUtilities.reverse("abc"), "cba")
        XCTAssertEqual(TextUtilities.reverse("e\u{301}x"), "xe\u{301}")
        XCTAssertEqual(TextUtilities.reverse("🇬🇧a"), "a🇬🇧")
        XCTAssertEqual(TextUtilities.reverse("a\r\nb"), "b\r\na")
    }

    func testRemovingAllWhitespaceIncludesEveryKind() {
        XCTAssertEqual(TextUtilities.removeAllWhitespace(from: " a\tb\nc\r\nd\u{00A0}e "), "abcde")
        XCTAssertEqual(TextUtilities.removeAllWhitespace(from: ""), "")
    }

    func testTruncationAtZeroAtTheLengthAndJustPastIt() {
        XCTAssertEqual(TextUtilities.truncate("hello", to: 5), "hello")
        XCTAssertEqual(TextUtilities.truncate("hello", to: 4), "h...")
        XCTAssertEqual(TextUtilities.truncate("hello", to: 0), "...")
        XCTAssertEqual(TextUtilities.truncate("hello", to: 4, ellipsis: ""), "hell")
        XCTAssertEqual(TextUtilities.truncate("hello", to: 4, ellipsis: "…"), "hel…")
        XCTAssertEqual(TextUtilities.truncate("", to: 0), "")
        XCTAssertEqual(TextUtilities.truncate("🙂🙂🙂🙂🙂", to: 4), "🙂...")
    }

    func testWrappingAtWidthOneAndAtAWidthWiderThanTheText() {
        XCTAssertEqual(TextUtilities.wrap("a b c", width: 1), "a\nb\nc")
        XCTAssertEqual(TextUtilities.wrap("a b c", width: 100), "a b c")
        XCTAssertEqual(TextUtilities.wrap("", width: 10), "")
        XCTAssertEqual(TextUtilities.wrap("abcdef", width: 3), "abcdef")
        XCTAssertEqual(TextUtilities.wrap("aaa bbb ccc", width: 7), "aaa bbb\nccc")
    }

    func testWrappingPreservesDoubleSpacesAndExistingLineBreaks() {
        XCTAssertEqual(TextUtilities.wrap("a  b", width: 10), "a  b")
        XCTAssertEqual(TextUtilities.wrap("a\nb c", width: 3), "a\nb\nc")
    }

    func testCSVEscapingCoversEveryTriggerIncludingWindowsLineBreaks() {
        XCTAssertEqual(TextUtilities.escapeCSV(""), "")
        XCTAssertEqual(TextUtilities.escapeCSV("plain"), "plain")
        XCTAssertEqual(TextUtilities.escapeCSV("a,b"), "\"a,b\"")
        XCTAssertEqual(TextUtilities.escapeCSV("a\nb"), "\"a\nb\"")
        XCTAssertEqual(TextUtilities.escapeCSV("a\r\nb"), "\"a\r\nb\"")
        XCTAssertEqual(TextUtilities.escapeCSV("a\rb"), "\"a\rb\"")
        XCTAssertEqual(TextUtilities.escapeCSV("say \"hi\""), "\"say \"\"hi\"\"\"")
        XCTAssertEqual(TextUtilities.escapeCSV("🙂"), "🙂")
    }
}

// MARK: - String extension

final class StringExtensionCoverageTests: XCTestCase {

    func testEveryConvenienceReachesItsFunction() {
        XCTAssertEqual("  a  b ".cleaned(), "a b")
        XCTAssertEqual("a\n\n b".cleaned(options: .aggressive), "a\n b")
        XCTAssertEqual("\u{201C}q\u{201D}".quotesNormalized, "\"q\"")
        XCTAssertTrue("a".isNotEmpty)
        XCTAssertFalse("  ".isNotEmpty)
        XCTAssertEqual("b\na".sortedLines(), "a\nb")
        XCTAssertEqual("b\na".sortedLines(.descending), "b\na")
        XCTAssertEqual("a\na".deduplicatedLines(), "a")
        XCTAssertEqual("a\nb".numberedList(), "1. a\n2. b")
        XCTAssertEqual("a\nb".numberedList(startIndex: 3), "3. a\n4. b")
        XCTAssertEqual("a".bulletedList(), "• a")
        XCTAssertEqual("a".bulletedList(bullet: ">"), "> a")
        XCTAssertEqual("hello world".transformed(to: .pascalCase), "HelloWorld")
        XCTAssertEqual("a b c".wordCount, 3)
        XCTAssertEqual("a\nb".lineCount, 2)
        XCTAssertEqual("🇬🇧".characterCount, 1)
        XCTAssertEqual("b a b".uniqueWords, ["a", "b"])
        XCTAssertEqual("b a b".words, ["b", "a", "b"])
        XCTAssertEqual("abc".reversed, "cba")
        XCTAssertEqual("hello world".truncated(to: 8), "hello...")
        XCTAssertEqual("a b c".wrapped(at: 3), "a b\nc")
        XCTAssertEqual("a,b".csvEscaped, "\"a,b\"")
        XCTAssertEqual("[a]".replacingBetween(start: "[", end: "]", with: "x"), "[x]")
        XCTAssertNil("a".replacingBetween(start: "[", end: "]", with: "x"))
    }
}

// MARK: - JSONText

final class JSONTextEdgeTests: XCTestCase {

    func testEmptyAndWhitespaceOnlyTextAreNotJSON() {
        XCTAssertFalse(JSONText.isValid(""))
        XCTAssertFalse(JSONText.isValid("   \n\t"))
        XCTAssertThrowsError(try JSONText.validate("   ")) { error in
            guard case JSONTextError.invalid(let reason) = error else { return XCTFail("\(error)") }
            XCTAssertTrue(reason.lowercased().contains("content"), reason)
        }
    }

    func testBareScalarsAreValidAndMinifyToThemselves() throws {
        XCTAssertEqual(try JSONText.minify(" 42 "), "42")
        XCTAssertEqual(try JSONText.minify("\"x\""), "\"x\"")
        XCTAssertEqual(try JSONText.minify("null"), "null")
        XCTAssertEqual(try JSONText.minify("true"), "true")
        XCTAssertEqual(try JSONText.minify("false"), "false")
        XCTAssertEqual(try JSONText.pretty("42"), "42")
    }

    func testNestedEmptyContainersStayOnOneLine() throws {
        let pretty = try JSONText.pretty(#"{"a":[],"b":{},"c":[[]],"d":[{}]}"#, sortedKeys: true)
        XCTAssertEqual(pretty, """
        {
          "a": [],
          "b": {},
          "c": [
            []
          ],
          "d": [
            {}
          ]
        }
        """)
        XCTAssertEqual(try JSONText.minify("[]"), "[]")
        XCTAssertEqual(try JSONText.minify("{}"), "{}")
        XCTAssertEqual(try JSONText.pretty("[]"), "[]")
    }

    func testUnicodeIsKeptAndEscapedUnicodeIsDecoded() throws {
        XCTAssertEqual(try JSONText.minify(#"{"a":"é🙂 日本"}"#), #"{"a":"é🙂 日本"}"#)
        XCTAssertEqual(try JSONText.minify(#"{"a":"é"}"#), #"{"a":"é"}"#)
        XCTAssertEqual(try JSONText.minify(#"["\/"]"#), #"["/"]"#)
    }

    func testControlCharactersAreEscapedAsTheGrammarRequires() throws {
        XCTAssertEqual(try JSONText.minify(#"{"a":"tab\there\nnl\r\b\f"}"#), #"{"a":"tab\there\nnl\r\b\f"}"#)
        XCTAssertEqual(try JSONText.minify("[\"\\u0001\"]"), "[\"\\u0001\"]")
        XCTAssertEqual(try JSONText.minify(#"[""]"#), #"[""]"#)
        XCTAssertEqual(try JSONText.minify(#"["quote \" and backslash \\"]"#), #"["quote \" and backslash \\"]"#)
    }

    func testNumbersAreRenderedShortAndIntegralDoublesAsIntegers() throws {
        XCTAssertEqual(try JSONText.minify(#"{"a":1.0}"#), #"{"a":1}"#)
        XCTAssertEqual(try JSONText.minify(#"{"a":1e10}"#), #"{"a":10000000000}"#)
        XCTAssertEqual(try JSONText.minify(#"{"a":1E2}"#), #"{"a":100}"#)
        XCTAssertEqual(try JSONText.minify(#"{"a":0.1}"#), #"{"a":0.1}"#)
        XCTAssertEqual(try JSONText.minify(#"{"a":1.5e-3}"#), #"{"a":0.0015}"#)
        XCTAssertEqual(try JSONText.minify(#"{"a":-12.5}"#), #"{"a":-12.5}"#)
        XCTAssertEqual(try JSONText.minify(#"{"a":-0}"#), #"{"a":0}"#)
        XCTAssertEqual(try JSONText.minify("12345678901234567890"), "12345678901234567890")
        XCTAssertEqual(try JSONText.minify("-9223372036854775808"), "-9223372036854775808")
        XCTAssertEqual(try JSONText.minify("1e300"), "1e+300")
    }

    func testDuplicateKeysKeepTheFirstValue() throws {
        XCTAssertEqual(try JSONText.minify(#"{"a":1,"a":2}"#), #"{"a":1}"#)
    }

    func testTrailingCommasAreRefusedWithAPosition() {
        XCTAssertFalse(JSONText.isValid(#"{"a":1,}"#))
        XCTAssertFalse(JSONText.isValid("[1,2,]"))
        XCTAssertFalse(JSONText.isValid("[1, 2 ,\n]"))
        XCTAssertThrowsError(try JSONText.validate("[1,\n2,]")) { error in
            guard case JSONTextError.invalid(let reason) = error else { return XCTFail("\(error)") }
            XCTAssertEqual(reason, "Trailing comma before ']' around line 2, column 2.")
        }
    }

    func testACommaInsideAStringIsNotATrailingComma() {
        XCTAssertTrue(JSONText.isValid(#"{"a":",]"}"#))
        XCTAssertTrue(JSONText.isValid(#"{"a":"\",]"}"#))
        XCTAssertTrue(JSONText.isValid(#"[",", "}"]"#))
    }

    func testSortedKeysSortsAtEveryLevel() throws {
        let text = #"{"b":{"z":1,"y":2},"a":[{"d":1,"c":2}]}"#
        XCTAssertEqual(try JSONText.minify(text, sortedKeys: true), #"{"a":[{"c":2,"d":1}],"b":{"y":2,"z":1}}"#)
        XCTAssertEqual(try JSONText.pretty(text, sortedKeys: true), """
        {
          "a": [
            {
              "c": 2,
              "d": 1
            }
          ],
          "b": {
            "y": 2,
            "z": 1
          }
        }
        """)
    }

    func testMinifyAndPrettyAreIdempotent() throws {
        let text = #"{"name":"café","tags":["a","b"],"count":3,"nested":{"ok":true,"none":null}}"#
        let minified = try JSONText.minify(text, sortedKeys: true)
        XCTAssertEqual(try JSONText.minify(minified, sortedKeys: true), minified)
        let pretty = try JSONText.pretty(text, sortedKeys: true)
        XCTAssertEqual(try JSONText.pretty(pretty, sortedKeys: true), pretty)
        XCTAssertEqual(try JSONText.minify(pretty, sortedKeys: true), minified)
    }

    func testValidationRejectsWhatOtherParsersReject() {
        for bad in ["{", "nan", "NaN", "01", "+1", ".5", "'x'", "{a:1}", "[1 2]", "undefined"] {
            XCTAssertFalse(JSONText.isValid(bad), bad)
            XCTAssertThrowsError(try JSONText.validate(bad), bad)
        }
    }

    func testTheErrorReadsAsASentence() {
        let error = JSONTextError.invalid(reason: "Invalid value around line 1, column 5.")
        XCTAssertEqual(error.errorDescription, "not valid JSON: Invalid value around line 1, column 5.")
        XCTAssertEqual(error.localizedDescription, "not valid JSON: Invalid value around line 1, column 5.")
        XCTAssertEqual(error, JSONTextError.invalid(reason: "Invalid value around line 1, column 5."))
    }

    func testAMegabyteFormatsInReasonableTimeAndRoundTrips() throws {
        let objects = (0..<20_000).map { index in
            #"{"id":\#(index),"name":"item \#(index)","tags":["a","b","c"],"price":\#(Double(index) * 1.25)}"#
        }
        let text = "[" + objects.joined(separator: ",") + "]"
        XCTAssertGreaterThan(text.utf8.count, 1_000_000)
        let start = Date()
        let pretty = try JSONText.pretty(text, sortedKeys: true)
        let minified = try JSONText.minify(pretty, sortedKeys: true)
        XCTAssertLessThan(Date().timeIntervalSince(start), 5)
        let original = try JSONSerialization.jsonObject(with: Data(text.utf8)) as? NSArray
        let back = try JSONSerialization.jsonObject(with: Data(minified.utf8)) as? NSArray
        XCTAssertEqual(original, back)
        XCTAssertEqual(back?.count, 20_000)
    }
}
