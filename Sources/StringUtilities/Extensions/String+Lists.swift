//
//  String+Lists.swift
//  StringUtilities
//
//  ListProcessor, called on the string itself.
//

import Foundation

/// ``ListProcessor``, called on the string itself.
public extension String {

    /// The lines sorted, ascending by default.
    func sortedLines(_ order: ListProcessor.SortOrder = .ascending) -> String {
        ListProcessor.sortLines(self, order: order)
    }

    /// The lines with repeats dropped, first occurrence kept.
    func deduplicatedLines() -> String {
        ListProcessor.deduplicateLines(self)
    }

    /// The lines numbered from `startIndex`.
    func numberedList(startIndex: Int = 1) -> String {
        ListProcessor.numberList(self, startIndex: startIndex)
    }

    /// The lines bulleted with `bullet`.
    func bulletedList(bullet: String = "•") -> String {
        ListProcessor.bulletList(self, bullet: bullet)
    }
}
