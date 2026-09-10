//
//  JSONStrictness.swift
//  StringUtilities
//
//  The one leniency Foundation's parser has that RFC 8259 does not.
//

import Foundation

/// A check Foundation skips: trailing commas.
///
/// `JSONSerialization` accepts `[1, 2,]` and `{"a": 1,}`. Most other parsers
/// do not, so text that passed here would fail at the API it was written
/// for. The scanner walks the text outside strings and reports the first
/// comma that is followed only by whitespace and a closing bracket.
enum JSONStrictness {

    /// Where a trailing comma sits, or `nil` when there is none.
    ///
    /// Positions are one-based, counted in scalars, with `\n` starting a
    /// new line — the same convention as Foundation's own messages, so the
    /// two kinds of reason read alike.
    static func trailingComma(in text: String) -> (line: Int, column: Int, bracket: Character)? {
        let scalars = Array(text.unicodeScalars)
        var inString = false
        var escaped = false
        var line = 1
        var column = 0

        for (index, scalar) in scalars.enumerated() {
            column += 1
            if scalar == "\n" {
                line += 1
                column = 0
            }
            if inString {
                if escaped {
                    escaped = false
                } else if scalar == "\\" {
                    escaped = true
                } else if scalar == "\"" {
                    inString = false
                }
                continue
            }
            if scalar == "\"" {
                inString = true
                continue
            }
            guard scalar == "," else { continue }
            var next = index + 1
            while next < scalars.count, isWhitespace(scalars[next]) {
                next += 1
            }
            guard next < scalars.count else { continue }
            if scalars[next] == "]" || scalars[next] == "}" {
                return (line, column, Character(scalars[next]))
            }
        }
        return nil
    }

    /// The four whitespace characters JSON allows between tokens.
    private static func isWhitespace(_ scalar: Unicode.Scalar) -> Bool {
        scalar == " " || scalar == "\t" || scalar == "\n" || scalar == "\r"
    }
}
