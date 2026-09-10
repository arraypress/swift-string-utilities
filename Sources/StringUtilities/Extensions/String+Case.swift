//
//  String+Case.swift
//  StringUtilities
//
//  TextTransform, called on the string itself.
//

import Foundation

/// ``TextTransform``, called on the string itself.
public extension String {

    /// The string rewritten in a ``TextTransform/CaseStyle``.
    func transformed(to style: TextTransform.CaseStyle) -> String {
        TextTransform.transform(self, to: style)
    }

    /// The string as a URL slug: folded to plain letters, joined by `separator`, lowercased.
    func slugified(separator: String = "-", maxLength: Int? = nil) -> String {
        TextTransform.slugify(self, separator: separator, maxLength: maxLength)
    }
}
