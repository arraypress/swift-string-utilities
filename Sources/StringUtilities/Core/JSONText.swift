//
//  JSONText.swift
//  StringUtilities
//
//  JSON as text: pretty, minified or checked, with no model in between.
//

import Foundation

/// Formatting and checking JSON text without decoding it into a type.
///
/// Parsing is Foundation's `JSONSerialization` — fast, already on the
/// device, and strict about the grammar in every way but one: it accepts a
/// trailing comma, so that is checked separately and refused. Writing is
/// this package's own, because Foundation prints `0.1` as
/// `0.10000000000000001` and puts a space before every colon.
///
/// Three things about the output are worth knowing before relying on it:
///
/// - **Keys come back in a different order** unless `sortedKeys` is asked
///   for. A dictionary has no order, and Foundation does not keep the one
///   it read.
/// - **Numbers are re-rendered**, not copied: `1.0` becomes `1`, `1e10`
///   becomes `10000000000`, `-0` becomes `0`. A fractional value is printed
///   in the shortest form that reads back to the same double. Integers up
///   to 64 bits survive exactly.
/// - **Duplicate keys keep the first value.** The grammar allows them and
///   says nothing about which wins; Foundation keeps the first.
///
/// Any JSON value is accepted at the top level — `42`, `"text"`, `null` —
/// as RFC 8259 allows, not only objects and arrays.
public enum JSONText {

    /// The text re-indented with two spaces per level, as `"key": value`.
    ///
    /// Empty containers stay on one line as `[]` and `{}`; everything else
    /// gets a line per element.
    ///
    /// - Parameters:
    ///   - text: JSON text.
    ///   - sortedKeys: Sort object keys alphabetically at every level. Off by
    ///     default; on, the output is stable across runs and diffs cleanly.
    /// - Throws: ``JSONTextError/invalid(reason:)`` when the text is not JSON.
    public static func pretty(_ text: String, sortedKeys: Bool = false) throws -> String {
        try JSONFormatting.pretty(text, sortedKeys: sortedKeys)
    }

    /// The text with every space and line break outside strings removed.
    ///
    /// Strings are untouched, including their spaces; slashes and non-ASCII
    /// characters are written as themselves, so a URL or a name stays
    /// readable.
    ///
    /// - Parameters:
    ///   - text: JSON text.
    ///   - sortedKeys: Sort object keys alphabetically at every level.
    /// - Throws: ``JSONTextError/invalid(reason:)`` when the text is not JSON.
    public static func minify(_ text: String, sortedKeys: Bool = false) throws -> String {
        try JSONFormatting.minify(text, sortedKeys: sortedKeys)
    }

    /// Whether the text parses as JSON. The question without the reason;
    /// ``validate(_:)`` gives the reason.
    public static func isValid(_ text: String) -> Bool {
        JSONFormatting.isValid(text)
    }

    /// Parses the text and throws when it is not JSON, with the line and
    /// column in the reason.
    ///
    /// - Throws: ``JSONTextError/invalid(reason:)``.
    public static func validate(_ text: String) throws {
        try JSONFormatting.validate(text)
    }
}
