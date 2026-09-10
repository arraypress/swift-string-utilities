//
//  ListProcessor+SortOrder.swift
//  StringUtilities
//

import Foundation

extension ListProcessor {

    /// The orders a list can be put in.
    public enum SortOrder: Sendable {

        /// A to Z.
        case ascending

        /// Z to A.
        case descending

        /// Shortest item first.
        case byLength

        /// Longest item first.
        case byLengthDescending

        /// The order a person expects when items carry numbers: `item2`
        /// before `item10`, which a plain string sort gets backwards.
        case natural

        /// Shuffled. Different every call, by design.
        case random
    }
}
