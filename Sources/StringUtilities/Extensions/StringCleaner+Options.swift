//
//  StringCleaner+Options.swift
//  StringUtilities
//

import Foundation

extension StringCleaner {

    /// Which cleaning steps to run. Combine flags, or start from a preset.
    ///
    /// An option set rather than a list of booleans so a caller can say
    /// `[.standard, .normalizeQuotes]` and so presets compose without a
    /// parameter for every step.
    public struct Options: OptionSet, Sendable {

        /// The bit set backing the flags.
        public let rawValue: Int

        /// Creates options from a raw bit set.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Collapse runs of spaces and tabs to one space.
        public static let removeExtraSpaces     = Options(rawValue: 1 << 0)

        /// Drop lines that hold only whitespace.
        public static let removeEmptyLines      = Options(rawValue: 1 << 1)

        /// Trim whitespace and newlines from both ends.
        public static let trimWhitespace        = Options(rawValue: 1 << 2)

        /// Turn `\r\n` and `\r` line breaks into `\n`.
        public static let normalizeLineBreaks   = Options(rawValue: 1 << 3)

        /// Turn ALL-CAPS words of more than four letters into Capitalised
        /// ones. Four letters or fewer are left alone, because those are
        /// usually acronyms.
        public static let fixAllCaps            = Options(rawValue: 1 << 4)

        /// Collapse three or more line breaks to two — one blank line.
        public static let removeExtraLineBreaks = Options(rawValue: 1 << 5)

        /// Strip zero-width and byte-order-mark characters, which are
        /// invisible in an editor and break equality checks.
        public static let removeInvisible       = Options(rawValue: 1 << 6)

        /// Replace curly quotes and guillemets with straight quotes.
        public static let normalizeQuotes       = Options(rawValue: 1 << 7)

        /// The default: collapse extra spaces and trim.
        public static let standard: Options = [.removeExtraSpaces, .trimWhitespace]

        /// The common four: extra spaces, empty lines, trimming, line breaks.
        public static let aggressive: Options = [.removeExtraSpaces, .removeEmptyLines,
                                                 .trimWhitespace, .normalizeLineBreaks]

        /// Every step there is.
        public static let all: Options = [.removeExtraSpaces, .removeEmptyLines, .trimWhitespace,
                                          .normalizeLineBreaks, .fixAllCaps, .removeExtraLineBreaks,
                                          .removeInvisible, .normalizeQuotes]
    }
}
