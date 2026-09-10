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

    // MARK: Escaping

    /// Quotes the text for a CSV field when it needs it — when it holds a
    /// comma, a quote or a line break — doubling any quotes inside.
    public static func escapeCSV(_ text: String) -> String {
        CSVEscaping.escape(text)
    }
}
