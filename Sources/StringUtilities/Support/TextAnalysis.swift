//
//  TextAnalysis.swift
//  StringUtilities
//
//  Counting things in text, and pulling the words out of it.
//

import Foundation

/// Counting and word extraction as pure functions.
enum TextAnalysis {

    /// Non-overlapping occurrences of `substring`. An empty needle is found
    /// nowhere rather than everywhere.
    static func occurrences(of substring: String, in text: String, caseSensitive: Bool) -> Int {
        if caseSensitive {
            return text.components(separatedBy: substring).count - 1
        }
        return text.lowercased().components(separatedBy: substring.lowercased()).count - 1
    }

    /// Runs of non-whitespace.
    static func wordCount(of text: String) -> Int {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }

    /// Line-break-separated pieces, so empty text is one line.
    ///
    /// `\r\n` is folded to `\n` first. Foundation splits on the two scalars
    /// separately, which counted every Windows line break as two.
    static func lineCount(of text: String) -> Int {
        text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: .newlines).count
    }

    /// Grapheme clusters — what a person would count.
    static func characterCount(of text: String) -> Int {
        text.count
    }

    /// The words in order, split on whitespace and then on punctuation, so
    /// `fox.` and `fox` are the same word.
    static func words(in text: String, caseSensitive: Bool) -> [String] {
        text.components(separatedBy: .whitespacesAndNewlines)
            .flatMap { $0.components(separatedBy: .punctuationCharacters) }
            .filter { !$0.isEmpty }
            .map { caseSensitive ? $0 : $0.lowercased() }
    }

    /// The distinct words, sorted.
    static func uniqueWords(in text: String, caseSensitive: Bool) -> [String] {
        Array(Set(words(in: text, caseSensitive: caseSensitive))).sorted()
    }
}
