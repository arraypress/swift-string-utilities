//
//  ListProcessor+Options.swift
//  StringUtilities
//

import Foundation

extension ListProcessor {

    /// How items are tidied before they are sorted.
    public struct Options: Sendable {

        /// Drop repeated items, keeping the first.
        public let removeDuplicates: Bool

        /// Drop items that are empty after trimming.
        public let removeEmpty: Bool

        /// Trim spaces and tabs from each item.
        public let trimItems: Bool

        /// Compare items exactly. Off by default, so `Apple` and `apple`
        /// are one item and sort together.
        public let caseSensitive: Bool

        /// Creates the options. The defaults trim, drop empties, keep
        /// duplicates and ignore case.
        ///
        /// - Parameters:
        ///   - removeDuplicates: Drop repeated items.
        ///   - removeEmpty: Drop empty items.
        ///   - trimItems: Trim each item.
        ///   - caseSensitive: Compare exactly.
        public init(
            removeDuplicates: Bool = false,
            removeEmpty: Bool = true,
            trimItems: Bool = true,
            caseSensitive: Bool = false
        ) {
            self.removeDuplicates = removeDuplicates
            self.removeEmpty = removeEmpty
            self.trimItems = trimItems
            self.caseSensitive = caseSensitive
        }
    }
}
