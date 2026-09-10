//
//  Cleaning.swift
//  StringUtilities
//
//  The steps behind StringCleaner, each on its own so it can be tested alone.
//

import Foundation

/// The cleaning steps as pure functions, and the order they run in.
enum Cleaning {

    /// Characters that take up no space and survive copy and paste: the
    /// zero-width space, non-joiner and joiner, and the byte-order mark.
    static let invisibleCharacters: Set<Unicode.Scalar> = ["\u{200B}", "\u{200C}", "\u{200D}", "\u{FEFF}"]

    /// Typographic quotes and the straight quote each becomes.
    static let quotePairs: [(String, String)] = [
        ("\u{201C}", "\""), // left double
        ("\u{201D}", "\""), // right double
        ("\u{2018}", "'"),  // left single
        ("\u{2019}", "'"),  // right single
        ("\u{201E}", "\""), // low double
        ("\u{00AB}", "\""), // left guillemet
        ("\u{00BB}", "\""), // right guillemet
    ]

    /// Runs the requested steps in their fixed order.
    static func clean(_ text: String, options: StringCleaner.Options) -> String {
        var result = text
        if options.contains(.removeInvisible) { result = removeInvisible(result) }
        if options.contains(.normalizeQuotes) { result = normalizeQuotes(result) }
        if options.contains(.normalizeLineBreaks) { result = normalizeLineBreaks(result) }
        if options.contains(.removeExtraSpaces) { result = collapseSpaces(result) }
        if options.contains(.fixAllCaps) { result = fixAllCaps(result) }
        if options.contains(.removeEmptyLines) { result = removeEmptyLines(result) }
        if options.contains(.removeExtraLineBreaks) { result = collapseLineBreaks(result) }
        if options.contains(.trimWhitespace) { result = trim(result) }
        return result
    }

    /// Strips every scalar in ``invisibleCharacters``.
    ///
    /// Filtered on scalars rather than searched for, because a zero-width
    /// joiner glues itself to the character before it, and Foundation's
    /// search compares whole composed sequences — it never finds the joiner
    /// inside one.
    static func removeInvisible(_ text: String) -> String {
        var scalars = String.UnicodeScalarView()
        scalars.append(contentsOf: text.unicodeScalars.filter { !invisibleCharacters.contains($0) })
        return String(scalars)
    }

    /// Replaces each typographic quote with its straight form.
    static func normalizeQuotes(_ text: String) -> String {
        quotePairs.reduce(text) { $0.replacingOccurrences(of: $1.0, with: $1.1) }
    }

    /// Turns Windows and classic Mac line endings into `\n`. The pair goes
    /// first, or `\r\n` would become two breaks.
    static func normalizeLineBreaks(_ text: String) -> String {
        text.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
    }

    /// Collapses runs of spaces and tabs to a single space. Newlines are
    /// left alone; they are a different step.
    static func collapseSpaces(_ text: String) -> String {
        text.replacingOccurrences(of: #"[ \t]+"#, with: " ", options: .regularExpression)
    }

    /// Capitalises words written in ALL CAPS, leaving short ones alone.
    ///
    /// A word is changed only when every character is a letter and there are
    /// more than four of them: `HELLO` becomes `Hello`, but `NASA`, `USA` and
    /// `HTTP/2` stay as they are. Splits on spaces and tabs only, so a word
    /// that runs into a newline is never touched.
    static func fixAllCaps(_ text: String) -> String {
        text.components(separatedBy: .whitespaces).map { word in
            if word.uppercased() == word && word.count > 4 && word.filter({ $0.isLetter }).count == word.count {
                return word.capitalized
            }
            return word
        }.joined(separator: " ")
    }

    /// Drops lines that are blank once trimmed.
    static func removeEmptyLines(_ text: String) -> String {
        text.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .joined(separator: "\n")
    }

    /// Collapses three or more consecutive line breaks to two.
    static func collapseLineBreaks(_ text: String) -> String {
        text.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)
    }

    /// Trims whitespace and newlines from both ends.
    static func trim(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Whether anything but whitespace is left after trimming.
    static func isNotEmpty(_ text: String) -> Bool {
        !trim(text).isEmpty
    }
}
