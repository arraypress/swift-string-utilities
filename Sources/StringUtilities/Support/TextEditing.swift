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

    /// Fills to `length` characters with `pad`, by Character so a flag emoji
    /// counts as one. Text already that long is returned unchanged — this
    /// never truncates, because the caller asked for a minimum, not a cut.
    static func pad(_ text: String, toLength length: Int, with pad: Character, side: TextUtilities.PadSide) -> String {
        let missing = length - text.count
        guard missing > 0 else { return text }
        switch side {
        case .leading:
            return String(repeating: pad, count: missing) + text
        case .trailing:
            return text + String(repeating: pad, count: missing)
        case .both:
            let leading = missing / 2
            return String(repeating: pad, count: leading) + text + String(repeating: pad, count: missing - leading)
        }
    }

    /// The lines joined with `separator`. Every kind of line break is one
    /// break, and a line with nothing but whitespace is empty for the purpose
    /// of `skippingEmpty`.
    static func joinLines(_ text: String, with separator: String, skippingEmpty: Bool) -> String {
        let normalised = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        let lines = normalised.components(separatedBy: "\n")
        let kept = skippingEmpty ? lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } : lines
        return kept.joined(separator: separator)
    }
}
