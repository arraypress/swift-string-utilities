//
//  TextEditing.swift
//  StringUtilities
//
//  Cutting, wrapping, reversing and splicing text.
//

import Foundation

/// The editing operations as pure functions.
enum TextEditing {

    /// Replaces the text between the first `start` and the following `end`.
    /// Returns `nil` when either is missing, so a caller can tell "nothing to
    /// replace" from "replaced with nothing".
    static func replaceBetween(in text: String, start: String, end: String, with replacement: String) -> String? {
        guard let startRange = text.range(of: start),
              let endRange = text.range(of: end, range: startRange.upperBound..<text.endIndex) else {
            return nil
        }
        var result = text
        result.replaceSubrange(startRange.upperBound..<endRange.lowerBound, with: replacement)
        return result
    }

    /// Reversed by character, not by byte or scalar.
    static func reverse(_ text: String) -> String {
        String(text.reversed())
    }

    /// Every whitespace and newline character removed.
    static func removeAllWhitespace(from text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines).joined()
    }

    /// Cuts to `length` characters including the ellipsis. Text that already
    /// fits is returned unchanged, ellipsis and all left out.
    ///
    /// A `length` shorter than the ellipsis yields the ellipsis alone rather
    /// than a negative prefix, which would trap.
    static func truncate(_ text: String, to length: Int, ellipsis: String) -> String {
        guard text.count > length else { return text }
        return String(text.prefix(max(0, length - ellipsis.count))) + ellipsis
    }

    /// Greedy word wrap at spaces and tabs. A word longer than `width`
    /// stands on its own line; nothing is cut mid-word.
    static func wrap(_ text: String, width: Int) -> String {
        var result = ""
        var currentLine = ""
        for word in text.components(separatedBy: .whitespaces) {
            if currentLine.isEmpty {
                currentLine = word
            } else if currentLine.count + 1 + word.count <= width {
                currentLine += " " + word
            } else {
                result += currentLine + "\n"
                currentLine = word
            }
        }
        if !currentLine.isEmpty {
            result += currentLine
        }
        return result
    }
}
