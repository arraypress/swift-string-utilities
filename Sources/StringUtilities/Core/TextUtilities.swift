//
//  TextUtilities.swift
//  StringUtilities
//
//  Counting, extracting, editing and escaping text.
//

import Foundation

/// Counting, extracting, editing and escaping text.
///
/// The work is in `TextAnalysis`, `TextEditing` and `CSVEscaping`; this type
/// is the public face.
public struct TextUtilities {

    // MARK: Counting

    /// How many times `substring` occurs in `text`, without overlap.
    ///
    /// - Parameters:
    ///   - substring: What to look for.
    ///   - text: Where to look.
    ///   - caseSensitive: Match exactly. On by default.
    public static func count(of substring: String, in text: String, caseSensitive: Bool = true) -> Int {
        TextAnalysis.occurrences(of: substring, in: text, caseSensitive: caseSensitive)
    }

    /// The number of words — runs of non-whitespace.
    public static func wordCount(of text: String) -> Int {
        TextAnalysis.wordCount(of: text)
    }

    /// The number of lines. Empty text is one line, and a trailing newline
    /// adds one, because that is what a line-numbered editor shows.
    public static func lineCount(of text: String) -> Int {
        TextAnalysis.lineCount(of: text)
    }

    /// The number of characters, as a person counts them: `é` is one and
    /// so is a flag emoji.
    public static func characterCount(of text: String) -> Int {
        TextAnalysis.characterCount(of: text)
    }

    // MARK: Extracting

    /// Every distinct word, sorted. Punctuation is stripped and, unless
    /// `caseSensitive`, words are lowercased so `The` and `the` are one.
    public static func extractUniqueWords(from text: String, caseSensitive: Bool = false) -> [String] {
        TextAnalysis.uniqueWords(in: text, caseSensitive: caseSensitive)
    }

    /// Every word in order, duplicates included, punctuation stripped.
    public static func extractWords(from text: String, caseSensitive: Bool = false) -> [String] {
        TextAnalysis.words(in: text, caseSensitive: caseSensitive)
    }

    // MARK: Editing

    /// Replaces what sits between the first `startDelimiter` and the next
    /// `endDelimiter` after it, keeping both delimiters.
    ///
    /// - Returns: The edited text, or `nil` when either delimiter is missing.
    public static func replaceBetween(
        in text: String,
        start startDelimiter: String,
        end endDelimiter: String,
        with replacement: String
    ) -> String? {
        TextEditing.replaceBetween(in: text, start: startDelimiter, end: endDelimiter, with: replacement)
    }

    /// The text backwards, by character, so combined characters survive.
    public static func reverse(_ text: String) -> String {
        TextEditing.reverse(text)
    }

    /// The text with every space, tab and line break removed.
    public static func removeAllWhitespace(from text: String) -> String {
        TextEditing.removeAllWhitespace(from: text)
    }

    /// Cuts the text to `length` characters, ending it with `ellipsis`. The
    /// ellipsis counts towards the length, so the result never exceeds it.
    ///
    /// - Parameters:
    ///   - text: The text to shorten.
    ///   - length: The most characters to keep, ellipsis included.
    ///   - ellipsis: What marks the cut. Defaults to `...`.
    public static func truncate(_ text: String, to length: Int, ellipsis: String = "...") -> String {
        TextEditing.truncate(text, to: length, ellipsis: ellipsis)
    }

    /// Breaks the text into lines no longer than `width`, at spaces. A word
    /// longer than the width gets a line of its own rather than being cut.
    public static func wrap(_ text: String, width: Int) -> String {
        TextEditing.wrap(text, width: width)
    }

    /// Fills the text to `length` characters with `pad` on the given side.
    /// Text already that long is returned unchanged; this never truncates.
    ///
    /// - Parameters:
    ///   - text: The text to fill out.
    ///   - length: The length to reach, in characters.
    ///   - pad: The character to fill with. A space by default.
    ///   - side: Where the padding goes. After the text by default.
    public static func pad(
        _ text: String, toLength length: Int, with pad: Character = " ", side: PadSide = .trailing
    ) -> String {
        TextEditing.pad(text, toLength: length, with: pad, side: side)
    }

    /// The lines of the text joined with `separator`, empty lines skipped
    /// unless asked otherwise. Windows and classic Mac line breaks count as
    /// one break each.
    public static func joinLines(_ text: String, with separator: String = " ", skippingEmpty: Bool = true) -> String {
        TextEditing.joinLines(text, with: separator, skippingEmpty: skippingEmpty)
    }

    // MARK: Social tokens

    /// The hashtags in the text, without their `#`, in order of appearance.
    ///
    /// A tag starts at the beginning, after whitespace, or after an opening
    /// bracket or quote — so `a#b` and the `#` in `site.com/#anchor` are not
    /// tags — and runs over letters of any script, digits and underscores,
    /// which is why trailing punctuation never sticks to it. It needs at
    /// least one letter, as the networks rule, so `#2024` is a number.
    /// `unique` keeps the first spelling of each tag, compared without case.
    public static func hashtags(in text: String, unique: Bool = false) -> [String] {
        SocialTokens.tokens(in: text, marker: "#", requireLetter: true, unique: unique)
    }

    /// The mentions in the text, without their `@`, in order of appearance.
    ///
    /// The same boundary rule as ``hashtags(in:unique:)``, which is what keeps
    /// `me@example.com` from counting as a mention of `example`. Digits alone
    /// are allowed, because `@2pac` is a name.
    public static func mentions(in text: String, unique: Bool = false) -> [String] {
        SocialTokens.tokens(in: text, marker: "@", requireLetter: false, unique: unique)
    }

    // MARK: Statistics

    /// What a statistics panel shows: characters, words, sentences,
    /// paragraphs, lines, the average word length, and the reading time at
    /// the adult silent-reading rate of 238 words a minute.
    public static func statistics(of text: String) -> TextStatistics {
        let words = Readability.words(in: text)
        return TextStatistics(
            characters: text.count,
            charactersExcludingWhitespace: TextEditing.removeAllWhitespace(from: text).count,
            words: words.count,
            sentences: Readability.sentenceCount(of: text),
            paragraphs: Readability.paragraphCount(of: text),
            lines: Readability.lineCount(of: text),
            averageWordLength: Readability.averageWordLength(of: words),
            readingTimeSeconds: Readability.readingTimeSeconds(words: words.count),
            readingTimeText: Readability.readingTimeText(words: words.count)
        )
    }

    // MARK: Escaping

    /// Quotes the text for a CSV field when it needs it — when it holds a
    /// comma, a quote or a line break — doubling any quotes inside.
    public static func escapeCSV(_ text: String) -> String {
        CSVEscaping.escape(text)
    }
}
