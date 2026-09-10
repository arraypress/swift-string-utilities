//
//  Readability.swift
//  StringUtilities
//
//  Sentences, paragraphs and reading time, counted the way an editor does.
//

import Foundation

/// The statistics as pure functions.
enum Readability {

    /// Words per minute for silent reading of English by an adult: 238,
    /// the mean across 190 studies in Brysbaert (2019), *How many words do
    /// we read per minute? A review and meta-analysis of reading rate*,
    /// Journal of Memory and Language 109.
    static let wordsPerMinute = 238.0

    /// Words that end in a full stop without ending a sentence. Lowercase,
    /// without the trailing stop. Small on purpose: a long list guesses more
    /// often than it helps.
    static let abbreviations: Set<String> = [
        "e.g", "i.e", "etc", "vs", "dr", "mr", "mrs", "ms", "prof", "sr", "jr", "st",
        "no", "inc", "ltd", "co", "corp", "u.s", "u.k", "a.m", "p.m", "approx", "dept", "fig",
        "mon", "tue", "tues", "wed", "thu", "thur", "thurs", "fri", "sat", "sun",
        "jan", "feb", "mar", "apr", "jun", "jul", "aug", "sep", "sept", "oct", "nov", "dec",
    ]

    /// Runs of non-whitespace.
    static func words(in text: String) -> [String] {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    /// Whether a word closes a sentence: it ends in `.`, `!` or `?`
    /// (closing quotes and brackets may follow), and its stem is not an
    /// abbreviation or a single initial like `J.`.
    static func endsSentence(_ word: String) -> Bool {
        var stripped = word
        while let last = stripped.last, "\"'”’)]}".contains(last) { stripped.removeLast() }
        guard let terminator = stripped.last, ".!?".contains(terminator) else { return false }
        guard terminator == "." else { return true }
        let stem = String(stripped.dropLast()).lowercased()
        if stem.isEmpty { return true }
        if abbreviations.contains(stem) { return false }
        if stem.count == 1, stem.first?.isLetter == true { return false }
        return true
    }

    /// Sentences: one per closing word, plus one for words left after the
    /// last close. Empty text has none.
    static func sentenceCount(of text: String) -> Int {
        let words = words(in: text)
        guard !words.isEmpty else { return 0 }
        var count = 0
        var open = false
        for word in words {
            open = true
            if endsSentence(word) { count += 1; open = false }
        }
        return count + (open ? 1 : 0)
    }

    /// Paragraphs: blocks with something in them, separated by blank lines.
    static func paragraphCount(of text: String) -> Int {
        let normalised = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        return normalised.components(separatedBy: "\n\n")
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
            .count
    }

    /// Lines with something to count: zero for empty text, otherwise one more
    /// than the number of line breaks. Differs from `lineCount`, which counts
    /// editor lines and so says one for empty text.
    static func lineCount(of text: String) -> Int {
        guard !text.isEmpty else { return 0 }
        let normalised = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        return normalised.components(separatedBy: "\n").count
    }

    /// The average word length in characters, with surrounding punctuation
    /// stripped from each word. Zero when there are no words.
    static func averageWordLength(of words: [String]) -> Double {
        guard !words.isEmpty else { return 0 }
        let lengths = words.map { $0.trimmingCharacters(in: .punctuationCharacters).count }
        return Double(lengths.reduce(0, +)) / Double(words.count)
    }

    /// Seconds to read `words` words at ``wordsPerMinute``, rounded.
    static func readingTimeSeconds(words: Int) -> Int {
        Int((Double(words) / wordsPerMinute * 60).rounded())
    }

    /// `0 min` for nothing; otherwise whole minutes, never less than one.
    static func readingTimeText(words: Int) -> String {
        guard words > 0 else { return "0 min" }
        let minutes = max(1, Int((Double(words) / wordsPerMinute).rounded()))
        return "\(minutes) min"
    }
}
