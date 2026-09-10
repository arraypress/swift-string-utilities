//
//  ListProcessing.swift
//  StringUtilities
//
//  Splitting, tidying, deduplicating, sorting and decorating list items.
//

import Foundation

/// The list operations as pure functions over `[String]`.
enum ListProcessing {

    /// Splits `text` on `separator` and applies the tidying half of the
    /// options: trimming, dropping empties, dropping duplicates.
    static func items(in text: String, separator: String, options: ListProcessor.Options) -> [String] {
        var items = text.components(separatedBy: separator)
        if options.trimItems {
            items = items.map { $0.trimmingCharacters(in: .whitespaces) }
        }
        if options.removeEmpty {
            items = items.filter { !$0.isEmpty }
        }
        if options.removeDuplicates {
            items = deduplicated(items, caseSensitive: options.caseSensitive)
        }
        return items
    }

    /// Drops repeats, keeping the first occurrence and the original order.
    /// A `Set` alone would lose the order.
    static func deduplicated(_ items: [String], caseSensitive: Bool) -> [String] {
        var seen = Set<String>()
        return items.filter { item in
            let key = caseSensitive ? item : item.lowercased()
            return seen.insert(key).inserted
        }
    }

    /// Sorts `items` in the given order.
    ///
    /// `.natural` uses `localizedStandardCompare`, the comparison Finder
    /// uses, so `item2` sorts before `item10`.
    static func sorted(_ items: [String], by order: ListProcessor.SortOrder, caseSensitive: Bool) -> [String] {
        switch order {
        case .ascending:
            return caseSensitive ? items.sorted() : items.sorted { $0.caseInsensitiveCompare($1) == .orderedAscending }
        case .descending:
            return caseSensitive ? items.sorted(by: >) : items.sorted { $0.caseInsensitiveCompare($1) == .orderedDescending }
        case .byLength:
            return items.sorted { $0.count < $1.count }
        case .byLengthDescending:
            return items.sorted { $0.count > $1.count }
        case .natural:
            return items.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
        case .random:
            return items.shuffled()
        }
    }

    /// The whole pipeline: split, tidy, sort, join.
    static func process(
        _ text: String,
        separator: String,
        sortOrder: ListProcessor.SortOrder?,
        options: ListProcessor.Options
    ) -> String {
        var result = items(in: text, separator: separator, options: options)
        if let order = sortOrder {
            result = sorted(result, by: order, caseSensitive: options.caseSensitive)
        }
        return result.joined(separator: separator)
    }

    /// The items of `text` that are not blank, each trimmed.
    static func nonBlankItems(in text: String, separator: String) -> [String] {
        text.components(separatedBy: separator)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }

    /// `1. first`, `2. second`… from `startIndex`, blanks skipped.
    static func numbered(_ text: String, separator: String, startIndex: Int) -> String {
        nonBlankItems(in: text, separator: separator).enumerated().map { index, item in
            "\(index + startIndex). \(item)"
        }.joined(separator: separator)
    }

    /// `• first`, `• second`…, blanks skipped.
    static func bulleted(_ text: String, bullet: String, separator: String) -> String {
        nonBlankItems(in: text, separator: separator).map { item in
            "\(bullet) \(item)"
        }.joined(separator: separator)
    }
}
