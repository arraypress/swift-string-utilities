//
//  String+Cleaning.swift
//  StringUtilities
//
//  StringCleaner, called on the string itself.
//

import Foundation

/// ``StringCleaner``, called on the string itself.
public extension String {

    /// The string cleaned with ``StringCleaner/Options``, `.standard` by default.
    func cleaned(options: StringCleaner.Options = .standard) -> String {
        StringCleaner.clean(self, options: options)
    }

    /// Curly quotes and guillemets replaced with straight quotes.
    var quotesNormalized: String {
        StringCleaner.normalizeQuotes(self)
    }

    /// Whether there is anything here besides whitespace.
    var isNotEmpty: Bool {
        StringCleaner.isNotEmpty(self)
    }
}
