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
}
