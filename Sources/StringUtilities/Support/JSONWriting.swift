//
//  JSONWriting.swift
//  StringUtilities
//
//  Serialising a parsed JSON value back to text, our way.
//

import Foundation

/// Writes a value `JSONSerialization` parsed back out as text.
///
/// Foundation's own writer is not used because of two habits: it prints
/// `0.1` as `0.10000000000000001`, and it puts a space on both sides of a
/// colon. This writer renders a double in the shortest form that reads back
/// to the same value, prints an integral double as an integer, and writes
/// `"key": value`. Strings are escaped as the grammar requires — quotes,
/// backslashes and control characters — and nothing else: non-ASCII text
/// and slashes are written as themselves.
enum JSONWriting {

    /// The value as text, pretty (two-space indent) or minified.
    static func text(_ value: Any, pretty: Bool, sortedKeys: Bool) -> String {
        var out = ""
        write(value, into: &out, pretty: pretty, sortedKeys: sortedKeys, depth: 0)
        return out
    }

    /// The string in quotes, with the escapes RFC 8259 requires.
    static func quoted(_ string: String) -> String {
        var out = "\""
        for scalar in string.unicodeScalars {
            switch scalar {
            case "\"": out += "\\\""
            case "\\": out += "\\\\"
            case "\n": out += "\\n"
            case "\r": out += "\\r"
            case "\t": out += "\\t"
            case "\u{08}": out += "\\b"
            case "\u{0C}": out += "\\f"
            case _ where scalar.value < 0x20:
                out += String(format: "\\u%04x", scalar.value)
            default:
                out.unicodeScalars.append(scalar)
            }
        }
        return out + "\""
    }

    /// A number as JSON text.
    ///
    /// Booleans arrive as numbers from Foundation and are told apart by
    /// their Core Foundation type, not their value — `NSNumber(1)` is not
    /// `true`. An integral double within the exactly-representable range is
    /// printed as an integer, so `1.0` becomes `1`; any other double takes
    /// Swift's shortest round-trip description, so `0.1` stays `0.1`.
    static func number(_ number: NSNumber) -> String {
        if CFGetTypeID(number) == CFBooleanGetTypeID() {
            return number.boolValue ? "true" : "false"
        }
        if let decimal = number as? NSDecimalNumber {
            return decimal.description(withLocale: nil)
        }
        switch String(cString: number.objCType) {
        case "d", "f":
            let value = number.doubleValue
            if value.isFinite, value == value.rounded(), abs(value) < 9_007_199_254_740_992 {
                return String(Int64(value))
            }
            return value.description
        default:
            return number.stringValue
        }
    }

    private static func write(_ value: Any, into out: inout String, pretty: Bool, sortedKeys: Bool, depth: Int) {
        switch value {
        case let dictionary as [String: Any]:
            guard !dictionary.isEmpty else { return out += "{}" }
            let keys = sortedKeys ? dictionary.keys.sorted() : Array(dictionary.keys)
            out += "{"
            for (index, key) in keys.enumerated() {
                if index > 0 { out += "," }
                if pretty { out += "\n" + indent(depth + 1) }
                out += quoted(key) + (pretty ? ": " : ":")
                write(dictionary[key]!, into: &out, pretty: pretty, sortedKeys: sortedKeys, depth: depth + 1)
            }
            if pretty { out += "\n" + indent(depth) }
            out += "}"
        case let array as [Any]:
            guard !array.isEmpty else { return out += "[]" }
            out += "["
            for (index, element) in array.enumerated() {
                if index > 0 { out += "," }
                if pretty { out += "\n" + indent(depth + 1) }
                write(element, into: &out, pretty: pretty, sortedKeys: sortedKeys, depth: depth + 1)
            }
            if pretty { out += "\n" + indent(depth) }
            out += "]"
        case let string as String:
            out += quoted(string)
        case let number as NSNumber:
            out += self.number(number)
        default:
            out += "null"
        }
    }

    private static func indent(_ depth: Int) -> String {
        String(repeating: " ", count: depth * 2)
    }
}
