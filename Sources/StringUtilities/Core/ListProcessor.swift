//
//  ListProcessor.swift
//  StringUtilities
//
//  Lists held in text: split, tidied, deduplicated, sorted and formatted.
//

import Foundation

/// Processing of lists that arrive as text — one item per line, or per any
/// separator.
///
/// The work is in `ListProcessing`; this type is the public face. Every
/// function takes text and returns text, because that is the shape a list
/// has in a clipboard, a shortcut or a form field.
public struct ListProcessor {

    /// Splits, tidies, optionally deduplicates and sorts a list, and joins it
    /// back up with the same separator.
    ///
    /// Items are trimmed before duplicates are looked for, so `"a"` and
    /// `" a "` count as one; duplicates are found case-insensitively unless
    /// ``Options/caseSensitive`` says otherwise, and the first spelling wins.
    ///
    /// - Parameters:
    ///   - text: The list as text.
    ///   - separator: What sits between items. Defaults to a newline.
    ///   - sortOrder: How to sort, or `nil` to keep the order given.
    ///   - options: Trimming, empty-item and duplicate handling.
    /// - Returns: The processed list, joined by `separator`.
    public static func process(
        _ text: String,
        separator: String = "\n",
        sortOrder: SortOrder? = nil,
        options: Options = Options()
    ) -> String {
        ListProcessing.process(text, separator: separator, sortOrder: sortOrder, options: options)
    }

    /// Sorts the lines of `text`, optionally dropping duplicate lines.
    public static func sortLines(_ text: String, order: SortOrder, removeDuplicates: Bool = false) -> String {
        process(text, separator: "\n", sortOrder: order,
                options: Options(removeDuplicates: removeDuplicates))
    }

    /// Drops repeated lines, keeping the first occurrence and its order.
    public static func deduplicateLines(_ text: String) -> String {
        process(text, separator: "\n", options: Options(removeDuplicates: true))
    }

    /// Prefixes each item with `1.`, `2.`, `3.`… Blank items are skipped so
    /// the numbering has no gaps.
    ///
    /// - Parameters:
    ///   - text: The list as text.
    ///   - separator: What sits between items. Defaults to a newline.
    ///   - startIndex: The first number. Defaults to 1.
    public static func numberList(_ text: String, separator: String = "\n", startIndex: Int = 1) -> String {
        ListProcessing.numbered(text, separator: separator, startIndex: startIndex)
    }

    /// Prefixes each item with a bullet. Blank items are skipped.
    ///
    /// - Parameters:
    ///   - text: The list as text.
    ///   - bullet: The marker to use. Defaults to `•`.
    ///   - separator: What sits between items. Defaults to a newline.
    public static func bulletList(_ text: String, bullet: String = "•", separator: String = "\n") -> String {
        ListProcessing.bulleted(text, bullet: bullet, separator: separator)
    }
}
