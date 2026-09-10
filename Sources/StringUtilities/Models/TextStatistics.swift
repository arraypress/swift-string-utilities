//
//  TextStatistics.swift
//  StringUtilities
//

import Foundation

/// What a word processor's statistics panel shows, as one value.
public struct TextStatistics: Sendable, Hashable, Codable {

    /// Characters as a person counts them: `é` is one and so is a flag emoji.
    public let characters: Int

    /// Characters with every space, tab and line break left out.
    public let charactersExcludingWhitespace: Int

    /// Runs of non-whitespace.
    public let words: Int

    /// Sentences, closed by `.`, `!` or `?` — abbreviations such as `e.g.`
    /// and initials such as `J.` do not close one.
    public let sentences: Int

    /// Blocks of text separated by blank lines.
    public let paragraphs: Int

    /// Line breaks plus one; zero for empty text.
    public let lines: Int

    /// Mean characters per word, punctuation stripped.
    public let averageWordLength: Double

    /// Seconds to read at 238 words a minute, the adult silent-reading rate.
    public let readingTimeSeconds: Int

    /// The same, as `3 min` — never less than a minute for any text at all.
    public let readingTimeText: String
}
