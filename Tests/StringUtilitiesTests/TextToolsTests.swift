//
//  TextToolsTests.swift
//  StringUtilities
//
//  Slugs, padding, joined lines, hashtags and mentions, and the statistics
//  panel — each a fixed input with one right answer.
//

import XCTest
@testable import StringUtilities

final class SlugifyTests: XCTestCase {

    func testAPlainTitle() {
        XCTAssertEqual(TextTransform.slugify("Hello, World!"), "hello-world")
        XCTAssertEqual("Hello, World!".slugified(), "hello-world")
    }

    func testAccentsFoldToPlainLetters() {
        XCTAssertEqual(TextTransform.slugify("Zürich café résumé"), "zurich-cafe-resume")
        XCTAssertEqual(TextTransform.slugify("São Paulo"), "sao-paulo")
    }

    func testTheLettersFoundationCannotDecompose() {
        XCTAssertEqual(TextTransform.slugify("Straße"), "strasse")
        XCTAssertEqual(TextTransform.slugify("Ærø Øresund"), "aero-oresund")
        XCTAssertEqual(TextTransform.slugify("Łódź Đakovo þing"), "lodz-dakovo-thing")
        XCTAssertEqual(TextTransform.slugify("İstanbul"), "istanbul")
    }

    func testEmojiAndSymbolsAreDropped() {
        XCTAssertEqual(TextTransform.slugify("Launch 🚀 day"), "launch-day")
        XCTAssertEqual(TextTransform.slugify("AT&T + C++"), "at-t-c")
    }

    func testOtherScriptsAreDroppedUnlessAllowedOrTransliterated() {
        XCTAssertEqual(TextTransform.slugify("Москва 2026"), "2026")
        XCTAssertEqual(TextTransform.slugify("Москва 2026", allowUnicode: true), "москва-2026")
        XCTAssertEqual(TextTransform.slugify("Москва 2026", transliterate: true), "moskva-2026")
        XCTAssertEqual(TextTransform.slugify("東京", allowUnicode: true), "東京")
    }

    func testRunsCollapseAndEndsAreTrimmed() {
        XCTAssertEqual(TextTransform.slugify("  --Hello   ...   World--  "), "hello-world")
        XCTAssertEqual(TextTransform.slugify("!!!"), "")
        XCTAssertEqual(TextTransform.slugify(""), "")
    }

    func testSeparatorAndCaseOptions() {
        XCTAssertEqual(TextTransform.slugify("Hello World", separator: "_"), "hello_world")
        XCTAssertEqual(TextTransform.slugify("Hello World", lowercase: false), "Hello-World")
        XCTAssertEqual(TextTransform.slugify("Hello World", separator: ""), "helloworld")
    }

    func testMaxLengthCutsOnAWordBoundary() {
        XCTAssertEqual(TextTransform.slugify("the quick brown fox", maxLength: 9), "the-quick")
        XCTAssertEqual(TextTransform.slugify("the quick brown fox", maxLength: 11), "the-quick")
        XCTAssertEqual(TextTransform.slugify("the quick brown fox", maxLength: 10), "the-quick")
        XCTAssertEqual(TextTransform.slugify("the quick brown fox", maxLength: 100), "the-quick-brown-fox")
        // One long word has no boundary to fall back to, so it is cut.
        XCTAssertEqual(TextTransform.slugify("supercalifragilistic", maxLength: 5), "super")
        XCTAssertEqual(TextTransform.slugify("hello world", maxLength: 0), "hello-world")
    }

    func testSlugIsNotKebabCase() {
        // Kebab keeps the accented letter as an identifier would; a slug folds it.
        XCTAssertEqual(TextTransform.transform("Café Menu", to: .kebabCase), "café-menu")
        XCTAssertEqual(TextTransform.slugify("Café Menu"), "cafe-menu")
    }

    func testTheFoldOnItsOwn() {
        XCTAssertEqual(Slugging.fold("ßæøł", transliterate: false), "ssaeol")
        XCTAssertEqual(Slugging.fold("é", transliterate: false), "e")
        XCTAssertTrue(Slugging.keeps("a", allowUnicode: false))
        XCTAssertFalse(Slugging.keeps("é", allowUnicode: false))
        XCTAssertTrue(Slugging.keeps("é", allowUnicode: true))
        XCTAssertFalse(Slugging.keeps("-", allowUnicode: true))
    }
}

final class PaddingAndJoiningTests: XCTestCase {

    func testPaddingOnEachSide() {
        XCTAssertEqual(TextUtilities.pad("ab", toLength: 5), "ab   ")
        XCTAssertEqual(TextUtilities.pad("ab", toLength: 5, side: .leading), "   ab")
        XCTAssertEqual(TextUtilities.pad("ab", toLength: 5, side: .both), " ab  ")
        XCTAssertEqual(TextUtilities.pad("ab", toLength: 6, side: .both), "  ab  ")
        XCTAssertEqual("7".padded(toLength: 3, with: "0", side: .leading), "007")
    }

    func testPaddingNeverTruncates() {
        XCTAssertEqual(TextUtilities.pad("hello world", toLength: 5), "hello world")
        XCTAssertEqual(TextUtilities.pad("hello", toLength: 5), "hello")
        XCTAssertEqual(TextUtilities.pad("", toLength: 0), "")
        XCTAssertEqual(TextUtilities.pad("", toLength: 2, with: "."), "..")
    }

    func testPaddingCountsCharactersNotBytes() {
        // A flag is one character, four scalars, eight bytes.
        XCTAssertEqual(TextUtilities.pad("🇬🇧", toLength: 3, with: "-"), "🇬🇧--")
        XCTAssertEqual(TextUtilities.pad("é", toLength: 2), "é ")
    }

    func testJoiningLines() {
        XCTAssertEqual(TextUtilities.joinLines("a\nb\nc"), "a b c")
        XCTAssertEqual(TextUtilities.joinLines("a\nb\nc", with: ", "), "a, b, c")
        XCTAssertEqual("a\nb".joinedLines(with: "|"), "a|b")
    }

    func testJoiningTreatsEveryLineBreakAsOne() {
        XCTAssertEqual(TextUtilities.joinLines("a\r\nb\rc\nd"), "a b c d")
    }

    func testJoiningSkipsOrKeepsEmptyLines() {
        XCTAssertEqual(TextUtilities.joinLines("a\n\n  \nb"), "a b")
        // Four lines, three separators: "a", "", "  ", "b" joined by a space is five spaces.
        XCTAssertEqual(TextUtilities.joinLines("a\n\n  \nb", skippingEmpty: false), "a     b")
        XCTAssertEqual(TextUtilities.joinLines("a\n\nb", with: "|", skippingEmpty: false), "a||b")
        XCTAssertEqual(TextUtilities.joinLines(""), "")
        XCTAssertEqual(TextUtilities.joinLines("\n\n"), "")
    }

    func testThePadSideRoundTrips() throws {
        for side in TextUtilities.PadSide.allCases {
            XCTAssertEqual(try JSONDecoder().decode(TextUtilities.PadSide.self, from: JSONEncoder().encode(side)), side)
        }
    }
}

final class SocialTokenTests: XCTestCase {

    func testHashtagsInOrderWithoutTheMarker() {
        XCTAssertEqual(TextUtilities.hashtags(in: "Loving #swift and #SwiftUI today"), ["swift", "SwiftUI"])
        XCTAssertEqual("#a #b #c".hashtags, ["a", "b", "c"])
    }

    func testTrailingPunctuationDoesNotStick() {
        XCTAssertEqual(TextUtilities.hashtags(in: "Try #swift, #swiftui! (#macos) \"#ios\"."), ["swift", "swiftui", "macos", "ios"])
    }

    func testATagNeedsAWordBoundaryBeforeIt() {
        XCTAssertEqual(TextUtilities.hashtags(in: "a#b c#d"), [])
        XCTAssertEqual(TextUtilities.hashtags(in: "see https://example.com/#anchor and site.com/#top"), [])
        XCTAssertEqual(TextUtilities.hashtags(in: "#start of text"), ["start"])
    }

    func testATagNeedsALetter() {
        XCTAssertEqual(TextUtilities.hashtags(in: "#2024 was #1 but #y2k and #4ever count"), ["y2k", "4ever"])
        XCTAssertEqual(TextUtilities.hashtags(in: "# not a tag, #_ neither"), [])
    }

    func testTagsInAnyScript() {
        XCTAssertEqual(TextUtilities.hashtags(in: "#日本 #Zürich #café_bar"), ["日本", "Zürich", "café_bar"])
    }

    func testUniqueTagsIgnoreCaseAndKeepTheFirstSpelling() {
        XCTAssertEqual(TextUtilities.hashtags(in: "#Swift #swift #SWIFT #ios"), ["Swift", "swift", "SWIFT", "ios"])
        XCTAssertEqual(TextUtilities.hashtags(in: "#Swift #swift #SWIFT #ios", unique: true), ["Swift", "ios"])
    }

    func testMentions() {
        XCTAssertEqual(TextUtilities.mentions(in: "cc @alice and @bob_2, thanks @Alice!"), ["alice", "bob_2", "Alice"])
        XCTAssertEqual(TextUtilities.mentions(in: "cc @alice and @Alice", unique: true), ["alice"])
        XCTAssertEqual("@2pac".mentions, ["2pac"])
    }

    func testAnEmailIsNotAMention() {
        XCTAssertEqual(TextUtilities.mentions(in: "write to me@example.com or @support"), ["support"])
        XCTAssertEqual(TextUtilities.mentions(in: "a@b"), [])
    }

    func testNothingToFind() {
        XCTAssertEqual(TextUtilities.hashtags(in: ""), [])
        XCTAssertEqual(TextUtilities.mentions(in: "no tags here"), [])
        XCTAssertEqual(TextUtilities.hashtags(in: "##double"), [])
    }
}

final class StatisticsTests: XCTestCase {

    func testEmptyText() {
        let stats = TextUtilities.statistics(of: "")
        XCTAssertEqual(stats.characters, 0)
        XCTAssertEqual(stats.words, 0)
        XCTAssertEqual(stats.sentences, 0)
        XCTAssertEqual(stats.paragraphs, 0)
        XCTAssertEqual(stats.lines, 0)
        XCTAssertEqual(stats.averageWordLength, 0)
        XCTAssertEqual(stats.readingTimeSeconds, 0)
        XCTAssertEqual(stats.readingTimeText, "0 min")
    }

    func testOneWord() {
        let stats = "Hello".statistics
        XCTAssertEqual(stats.characters, 5)
        XCTAssertEqual(stats.charactersExcludingWhitespace, 5)
        XCTAssertEqual(stats.words, 1)
        XCTAssertEqual(stats.sentences, 1)
        XCTAssertEqual(stats.paragraphs, 1)
        XCTAssertEqual(stats.lines, 1)
        XCTAssertEqual(stats.averageWordLength, 5)
        XCTAssertEqual(stats.readingTimeText, "1 min")
    }

    func testSentencesCloseOnStopsBangsAndQuestions() {
        XCTAssertEqual(TextUtilities.statistics(of: "One. Two! Three? Four").sentences, 4)
        XCTAssertEqual(TextUtilities.statistics(of: "Wait... what?! Really.").sentences, 3)
        XCTAssertEqual(TextUtilities.statistics(of: "He said \"Go.\" (Then left.)").sentences, 2)
    }

    func testAbbreviationsAndInitialsDoNotCloseASentence() {
        XCTAssertEqual(TextUtilities.statistics(of: "Ask Dr. Smith, e.g. on Mon. at 9 a.m. sharp.").sentences, 1)
        XCTAssertEqual(TextUtilities.statistics(of: "J. R. R. Tolkien wrote it. It sold.").sentences, 2)
        XCTAssertEqual(TextUtilities.statistics(of: "Made in the U.S. by Acme Inc. Fine.").sentences, 1)
    }

    func testParagraphsAreBlankLineBlocks() {
        XCTAssertEqual(TextUtilities.statistics(of: "one\ntwo\n\nthree").paragraphs, 2)
        XCTAssertEqual(TextUtilities.statistics(of: "one\n\n\n\ntwo").paragraphs, 2)
        XCTAssertEqual(TextUtilities.statistics(of: "one\r\n\r\ntwo\r\n\r\n").paragraphs, 2)
        XCTAssertEqual(TextUtilities.statistics(of: "\n\n   \n\n").paragraphs, 0)
    }

    func testLinesCountBreaksPlusOne() {
        XCTAssertEqual(TextUtilities.statistics(of: "a\nb\nc").lines, 3)
        XCTAssertEqual(TextUtilities.statistics(of: "a\r\nb").lines, 2)
        XCTAssertEqual(TextUtilities.statistics(of: "a\n").lines, 2)
    }

    func testCharactersAndWordsWithUnicode() {
        let stats = TextUtilities.statistics(of: "naïve 🇬🇧 café")
        XCTAssertEqual(stats.characters, 12)
        XCTAssertEqual(stats.charactersExcludingWhitespace, 10)
        XCTAssertEqual(stats.words, 3)
    }

    func testAverageWordLengthStripsPunctuation() {
        XCTAssertEqual(TextUtilities.statistics(of: "Hi, there.").averageWordLength, 3.5)
        XCTAssertEqual(TextUtilities.statistics(of: "aaa bb c").averageWordLength, 2, accuracy: 1e-9)
    }

    func testReadingTimeAtTheAdultRate() {
        let hundred = Array(repeating: "word", count: 100).joined(separator: " ")
        XCTAssertEqual(TextUtilities.statistics(of: hundred).readingTimeSeconds, 25)
        XCTAssertEqual(TextUtilities.statistics(of: hundred).readingTimeText, "1 min")
        let sixHundred = Array(repeating: "word", count: 600).joined(separator: " ")
        XCTAssertEqual(TextUtilities.statistics(of: sixHundred).readingTimeSeconds, 151)
        XCTAssertEqual(TextUtilities.statistics(of: sixHundred).readingTimeText, "3 min")
    }

    func testReadingTimeTextNeverSaysZeroForRealText() {
        for count in [1, 50, 118, 119, 300] {
            let text = Array(repeating: "w", count: count).joined(separator: " ")
            XCTAssertEqual(TextUtilities.statistics(of: text).readingTimeText, "1 min", "\(count) words")
        }
        XCTAssertEqual(Readability.readingTimeText(words: 358), "2 min")
    }

    func testStatisticsRoundTripThroughJSON() throws {
        let stats = TextUtilities.statistics(of: "Two words. Another sentence!")
        XCTAssertEqual(try JSONDecoder().decode(TextStatistics.self, from: JSONEncoder().encode(stats)), stats)
    }

    func testTheSentenceRuleOnItsOwn() {
        XCTAssertTrue(Readability.endsSentence("done."))
        XCTAssertTrue(Readability.endsSentence("done.\""))
        XCTAssertTrue(Readability.endsSentence("really?!"))
        XCTAssertFalse(Readability.endsSentence("e.g."))
        XCTAssertFalse(Readability.endsSentence("Dr."))
        XCTAssertFalse(Readability.endsSentence("J."))
        XCTAssertFalse(Readability.endsSentence("word"))
        XCTAssertTrue(Readability.endsSentence("."))
    }
}

final class TextToolsEdgeTests: XCTestCase {

    func testSlugifyIsIdempotent() {
        let once = TextTransform.slugify("Zürich & Co. — 2026!")
        XCTAssertEqual(TextTransform.slugify(once), once)
    }

    func testSlugifyKeepsDigitsAndUnderscoresBecomeSeparators() {
        XCTAssertEqual(TextTransform.slugify("iPhone_17 Pro 2026"), "iphone-17-pro-2026")
    }

    func testSlugifiedWithAMaximumLength() {
        XCTAssertEqual("The Quick Brown Fox".slugified(maxLength: 9), "the-quick")
        XCTAssertEqual("The Quick Brown Fox".slugified(separator: "_"), "the_quick_brown_fox")
    }

    func testJoiningASingleLineIsThatLine() {
        XCTAssertEqual(TextUtilities.joinLines("only"), "only")
        XCTAssertEqual(TextUtilities.joinLines("only\n"), "only")
    }

    func testAdjacentMarkersAreOneToken() {
        // "#a#b": the second # follows a letter, so it belongs to the first tag's neighbour, not a new tag.
        XCTAssertEqual(TextUtilities.hashtags(in: "#a#b"), ["a"])
        XCTAssertEqual(TextUtilities.mentions(in: "@a@b"), ["a"])
    }

    func testMentionsUniqueKeepsFirstSpelling() {
        XCTAssertEqual(TextUtilities.mentions(in: "@Bob @bob @BOB", unique: true), ["Bob"])
    }

    func testWhitespaceOnlyTextHasNoWordsSentencesOrParagraphs() {
        let stats = TextUtilities.statistics(of: "  \n\t\n  ")
        XCTAssertEqual(stats.words, 0)
        XCTAssertEqual(stats.sentences, 0)
        XCTAssertEqual(stats.paragraphs, 0)
        XCTAssertEqual(stats.lines, 3)
        XCTAssertEqual(stats.charactersExcludingWhitespace, 0)
        XCTAssertEqual(stats.readingTimeText, "0 min")
    }

    func testTheWordSplitterOnItsOwn() {
        XCTAssertEqual(Readability.words(in: " one\ttwo\nthree  "), ["one", "two", "three"])
        XCTAssertEqual(Readability.words(in: ""), [])
        XCTAssertEqual(Readability.readingTimeSeconds(words: 238), 60)
        XCTAssertEqual(Readability.readingTimeSeconds(words: 0), 0)
    }
}
