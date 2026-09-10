//
//  SocialTokens.swift
//  StringUtilities
//
//  Hashtags and mentions, found the way the networks find them.
//

import Foundation

/// The `#tag` and `@name` scanner as pure functions.
enum SocialTokens {

    /// A marker starts a token only at the start of the text or after
    /// whitespace or an opening bracket or quote. After a letter, digit, `/`
    /// or `.` it is part of something else: `a#b`, `me@example.com`,
    /// `site.com/#anchor`.
    static func mayStart(after previous: Character?) -> Bool {
        guard let previous else { return true }
        if previous.isWhitespace || previous.isNewline { return true }
        return "([{\"'“‘«".contains(previous)
    }

    /// The body of a token: letters of any script, digits and underscores.
    static func isBody(_ character: Character) -> Bool {
        character.isLetter || character.isNumber || character == "_"
    }

    /// Tokens introduced by `marker`, without the marker, in order.
    ///
    /// A hashtag needs at least one letter, so `#2024` is a number and not a
    /// tag, as the networks rule; a mention only needs a body.
    static func tokens(in text: String, marker: Character, requireLetter: Bool, unique: Bool) -> [String] {
        var found: [String] = []
        var seen: Set<String> = []
        var previous: Character?
        var index = text.startIndex
        while index < text.endIndex {
            let character = text[index]
            if character == marker, mayStart(after: previous) {
                var body = ""
                var cursor = text.index(after: index)
                while cursor < text.endIndex, isBody(text[cursor]) {
                    body.append(text[cursor])
                    cursor = text.index(after: cursor)
                }
                let qualifies = !body.isEmpty && (!requireLetter || body.contains { $0.isLetter })
                if qualifies {
                    let key = body.lowercased()
                    if !unique || !seen.contains(key) {
                        found.append(body)
                        seen.insert(key)
                    }
                    previous = text[text.index(before: cursor)]
                    index = cursor
                    continue
                }
            }
            previous = character
            index = text.index(after: index)
        }
        return found
    }
}
