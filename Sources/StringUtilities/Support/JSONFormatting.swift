//
//  JSONFormatting.swift
//  StringUtilities
//
//  Parse with Foundation, check what it lets through, write with JSONWriting.
//

import Foundation

/// The parse-and-rewrite behind ``JSONText``.
enum JSONFormatting {

    /// Parses any JSON value, including a bare scalar at the top level, and
    /// refuses the trailing commas Foundation would accept.
    ///
    /// Foundation's error carries the useful part — the line and column —
    /// in `NSDebugDescription` and only a generic sentence in
    /// `localizedDescription`; the debug text is the one worth showing.
    static func value(from text: String) throws -> Any {
        let value: Any
        do {
            value = try JSONSerialization.jsonObject(with: Data(text.utf8), options: [.fragmentsAllowed])
        } catch {
            let error = error as NSError
            let reason = (error.userInfo[NSDebugDescriptionErrorKey] as? String) ?? error.localizedDescription
            throw JSONTextError.invalid(reason: reason)
        }
        if let comma = JSONStrictness.trailingComma(in: text) {
            throw JSONTextError.invalid(reason: "Trailing comma before '\(comma.bracket)' around line \(comma.line), column \(comma.column).")
        }
        return value
    }

    /// Two-space indentation, keys optionally sorted.
    static func pretty(_ text: String, sortedKeys: Bool) throws -> String {
        JSONWriting.text(try value(from: text), pretty: true, sortedKeys: sortedKeys)
    }

    /// No whitespace outside strings, keys optionally sorted.
    static func minify(_ text: String, sortedKeys: Bool) throws -> String {
        JSONWriting.text(try value(from: text), pretty: false, sortedKeys: sortedKeys)
    }

    /// Whether ``value(from:)`` succeeds.
    static func isValid(_ text: String) -> Bool {
        (try? value(from: text)) != nil
    }

    /// Throws ``JSONTextError/invalid(reason:)`` when the text is not JSON.
    static func validate(_ text: String) throws {
        _ = try value(from: text)
    }
}
