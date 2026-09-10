//
//  StringCleaner.swift
//  StringUtilities
//
//  Cleaning and normalising text, one composable option at a time.
//

import Foundation

/// Text cleaning and normalisation, driven by ``StringCleaner/Options``.
///
/// Every step is a pure function in `Cleaning`; this type names them and runs
/// them in the one order that keeps them from undoing each other. Invisible
/// characters go first, so a zero-width space cannot survive as "extra"
/// whitespace; trimming goes last, so it sees the finished text.
public struct StringCleaner {

    /// Cleans `text` with the given options — `.standard` when none are given.
    ///
    /// Options are applied in a fixed order regardless of how the set was
    /// written, because the steps are not independent: collapsing spaces
    /// before normalising line breaks would leave `\r\n` pairs behind, and
    /// trimming before removing empty lines would leave a blank last line.
    ///
    /// - Parameters:
    ///   - text: The text to clean.
    ///   - options: The steps to run. Defaults to ``Options/standard``.
    /// - Returns: The cleaned text.
    public static func clean(_ text: String, options: Options = .standard) -> String {
        Cleaning.clean(text, options: options)
    }

    /// Whether the text has anything in it besides whitespace.
    ///
    /// `isEmpty` says a string of spaces is not empty, which is true and
    /// unhelpful when the question is whether a field was filled in.
    public static func isNotEmpty(_ text: String) -> Bool {
        Cleaning.isNotEmpty(text)
    }

    /// Replaces curly quotes and guillemets with straight ASCII quotes.
    ///
    /// Word processors and phone keyboards insert the typographic forms; code,
    /// shells and CSV readers want the plain ones.
    public static func normalizeQuotes(_ text: String) -> String {
        Cleaning.normalizeQuotes(text)
    }
}
