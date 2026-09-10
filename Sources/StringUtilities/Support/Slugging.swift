//
//  Slugging.swift
//  StringUtilities
//
//  Text into a URL segment.
//

import Foundation

/// The slug pipeline as pure functions.
enum Slugging {

    /// Letters `stripDiacritics` leaves alone, because they are letters in
    /// their own right rather than a base letter plus a mark. Each is folded
    /// to what an English keyboard would type for it.
    static let foldedLetters: [Character: String] = [
        "ß": "ss", "ẞ": "SS", "æ": "ae", "Æ": "AE", "œ": "oe", "Œ": "OE",
        "ø": "o", "Ø": "O", "đ": "d", "Đ": "D", "ł": "l", "Ł": "L",
        "ı": "i", "İ": "I", "þ": "th", "Þ": "TH", "ð": "d", "Ð": "D",
        "ħ": "h", "Ħ": "H", "ŧ": "t", "Ŧ": "T", "ŋ": "ng", "Ŋ": "NG",
        "ĸ": "k", "ſ": "s", "ƒ": "f",
    ]

    /// Folds accented and special Latin letters to plain ones. Diacritics are
    /// stripped by Foundation; the letters it cannot decompose come from
    /// ``foldedLetters``. With `transliterate`, other scripts are romanised
    /// first (`Москва` → `Moskva`) instead of being dropped.
    static func fold(_ text: String, transliterate: Bool) -> String {
        var source = text
        if transliterate {
            source = source.applyingTransform(.toLatin, reverse: false) ?? source
        }
        let substituted = source.map { foldedLetters[$0] ?? String($0) }.joined()
        return substituted.applyingTransform(.stripDiacritics, reverse: false) ?? substituted
    }

    /// Whether a character survives into the slug.
    static func keeps(_ character: Character, allowUnicode: Bool) -> Bool {
        guard character.isLetter || character.isNumber else { return false }
        return allowUnicode || character.isASCII
    }

    /// The slug: fold, keep letters and digits, turn every other run into one
    /// separator, trim, lowercase, and cap on a word boundary.
    static func slug(
        _ text: String, separator: String, lowercase: Bool, maxLength: Int?, allowUnicode: Bool, transliterate: Bool
    ) -> String {
        let folded = fold(text, transliterate: transliterate)
        var pieces: [String] = []
        var current = ""
        for character in folded {
            if keeps(character, allowUnicode: allowUnicode) {
                current.append(character)
            } else if !current.isEmpty {
                pieces.append(current)
                current = ""
            }
        }
        if !current.isEmpty { pieces.append(current) }
        var joined = pieces.joined(separator: separator)
        if lowercase { joined = joined.lowercased() }
        guard let maxLength, maxLength > 0, joined.count > maxLength else { return joined }
        return capped(joined, to: maxLength, separator: separator)
    }

    /// Cuts at `maxLength`, then back to the last separator inside the cut so
    /// a word is never left in half; a slug with no separator inside the cut
    /// is simply cut.
    static func capped(_ slug: String, to maxLength: Int, separator: String) -> String {
        let cut = String(slug.prefix(maxLength))
        if !separator.isEmpty, let range = cut.range(of: separator, options: .backwards),
           slug.dropFirst(maxLength).hasPrefix(separator) == false {
            let trimmed = String(cut[..<range.lowerBound])
            if !trimmed.isEmpty { return trimmed }
        }
        return trimSeparators(cut, separator: separator)
    }

    /// Separators off both ends.
    static func trimSeparators(_ text: String, separator: String) -> String {
        guard !separator.isEmpty else { return text }
        var result = text
        while result.hasSuffix(separator) { result.removeLast(separator.count) }
        while result.hasPrefix(separator) { result.removeFirst(separator.count) }
        return result
    }
}
