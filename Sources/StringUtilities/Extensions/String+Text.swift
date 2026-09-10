//
//  String+Text.swift
//  StringUtilities
//
//  TextUtilities, called on the string itself.
//

import Foundation

/// ``TextUtilities``, called on the string itself.
public extension String {

    /// The number of words.
    var wordCount: Int {
        TextUtilities.wordCount(of: self)
    }

    /// The number of lines.
    var lineCount: Int {
        TextUtilities.lineCount(of: self)
    }

    /// The number of characters, as a person counts them.
    var characterCount: Int {
        TextUtilities.characterCount(of: self)
    }

    /// The distinct words, lowercased and sorted.
    var uniqueWords: [String] {
        TextUtilities.extractUniqueWords(from: self)
    }

    /// Every word in order, lowercased.
    var words: [String] {
        TextUtilities.extractWords(from: self)
    }

    /// The string backwards.
    var reversed: String {
        TextUtilities.reverse(self)
    }

    /// The string cut to `length` characters with a trailing `...`.
    func truncated(to length: Int) -> String {
        TextUtilities.truncate(self, to: length)
    }

    /// The string wrapped into lines no longer than `width`.
    func wrapped(at width: Int) -> String {
        TextUtilities.wrap(self, width: width)
    }

    /// The string quoted for a CSV field when it needs to be.
    var csvEscaped: String {
        TextUtilities.escapeCSV(self)
    }

    /// The text between `start` and `end` replaced, or `nil` when either
    /// delimiter is missing.
    func replacingBetween(start: String, end: String, with replacement: String) -> String? {
        TextUtilities.replaceBetween(in: self, start: start, end: end, with: replacement)
    }
}
