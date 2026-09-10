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

    /// Turns text into a URL segment: `Zürich & Co. — 2026!` becomes `zurich-co-2026`.
    ///
    /// Not the same job as ``CaseStyle/kebabCase``. Kebab is a case style for
    /// identifiers and keeps every letter it is given; a slug is what goes
    /// after the last `/` in an address, so accents are folded to plain
    /// letters (`é` → `e`, `ß` → `ss`, `ø` → `o`), everything that is not a
    /// letter or digit becomes one separator, runs collapse, and the ends are
    /// trimmed. Letters outside ASCII are dropped unless `allowUnicode`
    /// keeps them, or `transliterate` romanises them first (`Москва` →
    /// `moskva`). A `maxLength` cuts on a word boundary, never mid-word.
    ///
    /// - Parameters:
    ///   - text: The title, name or phrase.
    ///   - separator: What joins the words. A hyphen by default.
    ///   - lowercase: Lowercase the result. On by default.
    ///   - maxLength: The most characters to keep, or `nil` for all of them.
    ///   - allowUnicode: Keep letters of any script rather than ASCII only.
    ///   - transliterate: Romanise other scripts before folding.
    public static func slugify(
        _ text: String,
        separator: String = "-",
        lowercase: Bool = true,
        maxLength: Int? = nil,
        allowUnicode: Bool = false,
        transliterate: Bool = false
    ) -> String {
        Slugging.slug(
            text, separator: separator, lowercase: lowercase, maxLength: maxLength,
            allowUnicode: allowUnicode, transliterate: transliterate
        )
    }
}
