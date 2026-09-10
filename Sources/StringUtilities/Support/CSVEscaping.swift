//
//  CSVEscaping.swift
//  StringUtilities
//
//  RFC 4180 field quoting.
//

import Foundation

/// CSV field escaping as a pure function.
enum CSVEscaping {

    /// Wraps the field in quotes when it holds a comma, a quote or a line
    /// break, doubling the quotes inside — RFC 4180's rule. A field that
    /// needs none is returned unchanged, which keeps plain files plain.
    ///
    /// Checked on scalars, not characters: `\r\n` is one `Character` in
    /// Swift, and a character search for `\n` would not find it.
    static func escape(_ text: String) -> String {
        let needsQuoting = text.unicodeScalars.contains { $0 == "," || $0 == "\"" || $0 == "\n" || $0 == "\r" }
        if needsQuoting {
            return "\"\(text.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return text
    }
}
