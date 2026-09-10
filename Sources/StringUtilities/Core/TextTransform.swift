//
//  TextTransform.swift
//  StringUtilities
//
//  Changing the case of text, including the cases programmers write in.
//

import Foundation

/// Case transformation, from `UPPERCASE` to `snake_case` to `aLtErNaTiNg`.
///
/// The conversions live in `CaseConversion`; this type is the public face.
public struct TextTransform {

    /// Rewrites `text` in the given ``CaseStyle``.
    ///
    /// The programmer cases (`camelCase`, `snake_case` and their relatives)
    /// first split the text into words on anything that is not a letter or
    /// digit; when that yields one unbroken word, the text is split on its
    /// own capitals instead, so `helloWorld` and `hello world` both become
    /// `hello_world`.
    ///
    /// - Parameters:
    ///   - text: The text to rewrite.
    ///   - style: The case to write it in.
    /// - Returns: The rewritten text.
    public static func transform(_ text: String, to style: CaseStyle) -> String {
        CaseConversion.convert(text, to: style)
    }
}
