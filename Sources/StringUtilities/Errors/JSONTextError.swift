//
//  JSONTextError.swift
//  StringUtilities
//

import Foundation

/// What went wrong with a piece of JSON text, in words a caller can print.
public enum JSONTextError: Error, LocalizedError, Equatable, Sendable {

    /// The text is not JSON. The reason is the parser's own, which names
    /// the line and column where it gave up.
    case invalid(reason: String)

    public var errorDescription: String? {
        switch self {
        case .invalid(let reason):
            return "not valid JSON: \(reason)"
        }
    }
}
