//
//  StringUtilities.swift
//  SwiftStringUtilities
//
//  Core string manipulation utilities for cleaning, sorting, and transforming text
//
//  Created by David Sherlock on 9/18/25.
//

import Foundation

// MARK: - String Cleaning

/// Provides text cleaning and normalization functionality
public struct StringCleaner {
    
    /// Options for text cleaning operations
    public struct Options: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Remove multiple consecutive spaces and tabs
        public static let removeExtraSpaces     = Options(rawValue: 1 << 0)
        
        /// Remove lines that contain only whitespace
        public static let removeEmptyLines      = Options(rawValue: 1 << 1)
        
        /// Remove leading and trailing whitespace
        public static let trimWhitespace        = Options(rawValue: 1 << 2)
        
        /// Normalize different line break styles to \n
        public static let normalizeLineBreaks   = Options(rawValue: 1 << 3)
        
        /// Convert ALL CAPS words to Capitalized Case
        public static let fixAllCaps            = Options(rawValue: 1 << 4)
        
        /// Replace multiple line breaks with double line break
        public static let removeExtraLineBreaks = Options(rawValue: 1 << 5)
        
        /// Remove zero-width and non-printable characters
        public static let removeInvisible       = Options(rawValue: 1 << 6)
        
        /// Standard cleaning: remove extra spaces and trim
        public static let standard: Options = [.removeExtraSpaces, .trimWhitespace]
        
        /// Aggressive cleaning: most common cleaning operations
        public static let aggressive: Options = [.removeExtraSpaces, .removeEmptyLines,
                                                 .trimWhitespace, .normalizeLineBreaks]
        
        /// Complete cleaning: all available operations
        public static let all: Options = [.removeExtraSpaces, .removeEmptyLines, .trimWhitespace,
                                          .normalizeLineBreaks, .fixAllCaps, .removeExtraLineBreaks,
                                          .removeInvisible]
    }
    
    /// Clean text with specified options
    /// - Parameters:
    ///   - text: The text to clean
    ///   - options: Cleaning options to apply (defaults to .standard)
    /// - Returns: Cleaned text
    public static func clean(_ text: String, options: Options = .standard) -> String {
        var result = text
        
        // Remove invisible characters first
        if options.contains(.removeInvisible) {
            result = result.replacingOccurrences(of: "\u{200B}", with: "") // Zero-width space
            result = result.replacingOccurrences(of: "\u{200C}", with: "") // Zero-width non-joiner
            result = result.replacingOccurrences(of: "\u{200D}", with: "") // Zero-width joiner
            result = result.replacingOccurrences(of: "\u{FEFF}", with: "") // Zero-width no-break space
        }
        
        // Normalize line breaks
        if options.contains(.normalizeLineBreaks) {
            result = result.replacingOccurrences(of: "\r\n", with: "\n")
            result = result.replacingOccurrences(of: "\r", with: "\n")
        }
        
        // Remove extra spaces (including tabs)
        if options.contains(.removeExtraSpaces) {
            result = result.replacingOccurrences(
                of: #"[ \t]+"#,
                with: " ",
                options: .regularExpression
            )
        }
        
        // Fix ALL CAPS words
        if options.contains(.fixAllCaps) {
            let words = result.components(separatedBy: .whitespaces)
            result = words.map { word in
                // Only fix if entire word is caps and it's longer than typical acronyms (>4 letters)
                // and consists only of letters (no punctuation/numbers)
                if word.uppercased() == word && word.count > 4 && word.filter({ $0.isLetter }).count == word.count {
                    return word.capitalized
                }
                return word
            }.joined(separator: " ")
        }
        
        // Remove empty lines
        if options.contains(.removeEmptyLines) {
            let lines = result.components(separatedBy: .newlines)
            result = lines
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                .joined(separator: "\n")
        }
        
        // Remove extra line breaks (multiple consecutive)
        if options.contains(.removeExtraLineBreaks) {
            result = result.replacingOccurrences(
                of: #"\n{3,}"#,
                with: "\n\n",
                options: .regularExpression
            )
        }
        
        // Trim whitespace
        if options.contains(.trimWhitespace) {
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return result
    }
    
    /// Check if a string is not empty after trimming whitespace
    /// - Parameter text: The text to check
    /// - Returns: true if the string contains non-whitespace characters
    public static func isNotEmpty(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - List Operations

/// Provides list processing, sorting, and manipulation functionality
public struct ListProcessor {
    
    /// Sort order options for lists
    public enum SortOrder {
        /// Alphabetical ascending order (A-Z)
        case ascending
        /// Alphabetical descending order (Z-A)
        case descending
        /// Sort by string length (shortest first)
        case byLength
        /// Sort by string length (longest first)
        case byLengthDescending
        /// Natural sort (handles numbers properly: item1, item2, item10)
        case natural
        /// Random shuffle
        case random
    }
    
    /// Options for list processing
    public struct Options {
        /// Remove duplicate items from the list
        public let removeDuplicates: Bool
        
        /// Remove empty items from the list
        public let removeEmpty: Bool
        
        /// Trim whitespace from each item
        public let trimItems: Bool
        
        /// Use case-sensitive comparison
        public let caseSensitive: Bool
        
        /// Initialize list processing options
        /// - Parameters:
        ///   - removeDuplicates: Whether to remove duplicate items
        ///   - removeEmpty: Whether to remove empty items
        ///   - trimItems: Whether to trim whitespace from items
        ///   - caseSensitive: Whether comparisons should be case-sensitive
        public init(
            removeDuplicates: Bool = false,
            removeEmpty: Bool = true,
            trimItems: Bool = true,
            caseSensitive: Bool = false
        ) {
            self.removeDuplicates = removeDuplicates
            self.removeEmpty = removeEmpty
            self.trimItems = trimItems
            self.caseSensitive = caseSensitive
        }
    }
    
    /// Process and optionally sort a list
    /// - Parameters:
    ///   - text: The text containing the list
    ///   - separator: The separator between list items
    ///   - sortOrder: Optional sort order to apply
    ///   - options: Processing options
    /// - Returns: Processed list as a string
    public static func process(
        _ text: String,
        separator: String = "\n",
        sortOrder: SortOrder? = nil,
        options: Options = Options()
    ) -> String {
        var items = text.components(separatedBy: separator)
        
        // Trim items if requested
        if options.trimItems {
            items = items.map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        // Remove empty items
        if options.removeEmpty {
            items = items.filter { !$0.isEmpty }
        }
        
        // Remove duplicates while preserving order
        if options.removeDuplicates {
            var seen = Set<String>()
            items = items.filter { item in
                let key = options.caseSensitive ? item : item.lowercased()
                return seen.insert(key).inserted
            }
        }
        
        // Sort if requested
        if let order = sortOrder {
            items = sort(items, order: order, caseSensitive: options.caseSensitive)
        }
        
        return items.joined(separator: separator)
    }
    
    private static func sort(_ items: [String], order: SortOrder, caseSensitive: Bool) -> [String] {
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
    
    /// Sort lines in text
    /// - Parameters:
    ///   - text: Text containing lines to sort
    ///   - order: Sort order to apply
    ///   - removeDuplicates: Whether to remove duplicate lines
    /// - Returns: Text with sorted lines
    public static func sortLines(_ text: String, order: SortOrder, removeDuplicates: Bool = false) -> String {
        process(text, separator: "\n", sortOrder: order,
                options: Options(removeDuplicates: removeDuplicates))
    }
    
    /// Remove duplicate lines from text
    /// - Parameter text: Text containing lines
    /// - Returns: Text with duplicate lines removed
    public static func deduplicateLines(_ text: String) -> String {
        process(text, separator: "\n", options: Options(removeDuplicates: true))
    }
}

// MARK: - Text Case Transformations

/// Provides text case transformation functionality
public struct TextTransform {
    
    /// Available case transformation styles
    public enum CaseStyle {
        /// UPPERCASE
        case uppercase
        /// lowercase
        case lowercase
        /// Capitalize Every Word
        case capitalized
        /// First word of sentence capitalized.
        case sentence
        /// camelCaseStyle
        case camelCase
        /// PascalCaseStyle
        case pascalCase
        /// snake_case_style
        case snakeCase
        /// kebab-case-style
        case kebabCase
        /// CONSTANT_CASE_STYLE
        case constantCase
        /// dot.case.style
        case dotCase
        /// path/case/style
        case pathCase
        /// aLtErNaTiNg CaSe
        case alternating
    }
    
    /// Transform text to specified case style
    /// - Parameters:
    ///   - text: The text to transform
    ///   - style: The case style to apply
    /// - Returns: Transformed text
    public static func transform(_ text: String, to style: CaseStyle) -> String {
        switch style {
        case .uppercase:
            return text.uppercased()
            
        case .lowercase:
            return text.lowercased()
            
        case .capitalized:
            return text.capitalized
            
        case .sentence:
            return toSentenceCase(text)
            
        case .camelCase:
            return toCamelCase(text)
            
        case .pascalCase:
            return toPascalCase(text)
            
        case .snakeCase:
            return toSnakeCase(text)
            
        case .kebabCase:
            return toKebabCase(text)
            
        case .constantCase:
            return toConstantCase(text)
            
        case .dotCase:
            return toDotCase(text)
            
        case .pathCase:
            return toPathCase(text)
            
        case .alternating:
            return toAlternatingCase(text)
        }
    }
    
    private static func toSentenceCase(_ text: String) -> String {
        let sentences = text.components(separatedBy: ". ")
        return sentences.map { sentence in
            guard !sentence.isEmpty else { return sentence }
            return sentence.prefix(1).uppercased() + sentence.dropFirst().lowercased()
        }.joined(separator: ". ")
    }
    
    private static func toCamelCase(_ text: String) -> String {
        // First split on non-alphanumeric to get words
        var words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        
        // If we have no words from that split, try splitting camelCase/PascalCase
        if words.count == 1 && words[0] == text {
            words = splitCamelCase(text)
        }
        
        guard !words.isEmpty else { return text }
        
        return words[0].lowercased() + words.dropFirst().map { $0.capitalized }.joined()
    }
    
    private static func toPascalCase(_ text: String) -> String {
        // First split on non-alphanumeric to get words
        var words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        
        // If we have no words from that split, try splitting camelCase/PascalCase
        if words.count == 1 && words[0] == text {
            words = splitCamelCase(text)
        }
        
        return words.map { $0.capitalized }.joined()
    }
    
    private static func toSnakeCase(_ text: String) -> String {
        // First split on non-alphanumeric to get words
        var words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        
        // If we have no words from that split, try splitting camelCase/PascalCase
        if words.count == 1 && words[0] == text {
            words = splitCamelCase(text)
        }
        
        return words.map { $0.lowercased() }.joined(separator: "_")
    }
    
    private static func toKebabCase(_ text: String) -> String {
        // First split on non-alphanumeric to get words
        var words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        
        // If we have no words from that split, try splitting camelCase/PascalCase
        if words.count == 1 && words[0] == text {
            words = splitCamelCase(text)
        }
        
        return words.map { $0.lowercased() }.joined(separator: "-")
    }
    
    private static func toConstantCase(_ text: String) -> String {
        // First split on non-alphanumeric to get words
        var words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        
        // If we have no words from that split, try splitting camelCase/PascalCase
        if words.count == 1 && words[0] == text {
            words = splitCamelCase(text)
        }
        
        return words.map { $0.uppercased() }.joined(separator: "_")
    }
    
    private static func toDotCase(_ text: String) -> String {
        // First split on non-alphanumeric to get words
        var words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        
        // If we have no words from that split, try splitting camelCase/PascalCase
        if words.count == 1 && words[0] == text {
            words = splitCamelCase(text)
        }
        
        return words.map { $0.lowercased() }.joined(separator: ".")
    }
    
    private static func toPathCase(_ text: String) -> String {
        // First split on non-alphanumeric to get words
        var words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        
        // If we have no words from that split, try splitting camelCase/PascalCase
        if words.count == 1 && words[0] == text {
            words = splitCamelCase(text)
        }
        
        return words.map { $0.lowercased() }.joined(separator: "/")
    }
    
    /// Helper to split camelCase/PascalCase strings into words
    private static func splitCamelCase(_ text: String) -> [String] {
        // Insert spaces before uppercase letters, then split
        let pattern = "(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])"
        let modifiedText = text.replacingOccurrences(
            of: pattern,
            with: " ",
            options: .regularExpression
        )
        return modifiedText.components(separatedBy: " ").filter { !$0.isEmpty }
    }
    
    private static func toAlternatingCase(_ text: String) -> String {
        var shouldUppercase = false
        return String(text.map { char in
            if char.isLetter {
                let result = shouldUppercase ? Character(char.uppercased()) : Character(char.lowercased())
                shouldUppercase.toggle()
                return result
            }
            return char
        })
    }
}

// MARK: - Text Utilities

/// Provides various text utility functions
public struct TextUtilities {
    
    /// Count occurrences of a substring in text
    /// - Parameters:
    ///   - substring: The substring to search for
    ///   - text: The text to search in
    ///   - caseSensitive: Whether the search should be case-sensitive
    /// - Returns: Number of occurrences
    public static func count(of substring: String, in text: String, caseSensitive: Bool = true) -> Int {
        if caseSensitive {
            return text.components(separatedBy: substring).count - 1
        } else {
            return text.lowercased().components(separatedBy: substring.lowercased()).count - 1
        }
    }
    
    /// Count words in text
    /// - Parameter text: The text to analyze
    /// - Returns: Number of words
    public static func wordCount(of text: String) -> Int {
        text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    /// Count lines in text
    /// - Parameter text: The text to analyze
    /// - Returns: Number of lines
    public static func lineCount(of text: String) -> Int {
        text.components(separatedBy: .newlines).count
    }
    
    /// Count characters in text
    /// - Parameter text: The text to analyze
    /// - Returns: Number of characters
    public static func characterCount(of text: String) -> Int {
        text.count
    }
    
    /// Reverse text
    /// - Parameter text: The text to reverse
    /// - Returns: Reversed text
    public static func reverse(_ text: String) -> String {
        String(text.reversed())
    }
    
    /// Remove all whitespace from text
    /// - Parameter text: The text to process
    /// - Returns: Text with all whitespace removed
    public static func removeAllWhitespace(from text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    /// Truncate text with ellipsis
    /// - Parameters:
    ///   - text: The text to truncate
    ///   - length: Maximum length
    ///   - ellipsis: String to append when truncated
    /// - Returns: Truncated text
    public static func truncate(_ text: String, to length: Int, ellipsis: String = "...") -> String {
        guard text.count > length else { return text }
        return String(text.prefix(length - ellipsis.count)) + ellipsis
    }
    
    /// Wrap text at specified width
    /// - Parameters:
    ///   - text: The text to wrap
    ///   - width: Maximum line width
    /// - Returns: Wrapped text
    public static func wrap(_ text: String, width: Int) -> String {
        var result = ""
        var currentLine = ""
        
        for word in text.components(separatedBy: .whitespaces) {
            if currentLine.isEmpty {
                currentLine = word
            } else if currentLine.count + 1 + word.count <= width {
                currentLine += " " + word
            } else {
                result += currentLine + "\n"
                currentLine = word
            }
        }
        
        if !currentLine.isEmpty {
            result += currentLine
        }
        
        return result
    }
    
    /// Escape text for CSV field
    /// - Parameter text: The text to escape
    /// - Returns: CSV-safe text
    public static func escapeCSV(_ text: String) -> String {
        if text.contains(",") || text.contains("\"") || text.contains("\n") {
            return "\"\(text.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return text
    }
}

// MARK: - Convenience String Extension

public extension String {
    
    /// Clean text with default options
    /// - Parameter options: Cleaning options to apply
    /// - Returns: Cleaned text
    func cleaned(options: StringCleaner.Options = .standard) -> String {
        StringCleaner.clean(self, options: options)
    }
    
    /// Sort lines in text
    /// - Parameter order: Sort order to apply
    /// - Returns: Text with sorted lines
    func sortedLines(_ order: ListProcessor.SortOrder = .ascending) -> String {
        ListProcessor.sortLines(self, order: order)
    }
    
    /// Remove duplicate lines
    /// - Returns: Text with duplicate lines removed
    func deduplicatedLines() -> String {
        ListProcessor.deduplicateLines(self)
    }
    
    /// Transform text case
    /// - Parameter style: Case style to apply
    /// - Returns: Transformed text
    func transformed(to style: TextTransform.CaseStyle) -> String {
        TextTransform.transform(self, to: style)
    }
    
    /// Get word count
    var wordCount: Int {
        TextUtilities.wordCount(of: self)
    }
    
    /// Get line count
    var lineCount: Int {
        TextUtilities.lineCount(of: self)
    }
    
    /// Get character count
    var characterCount: Int {
        TextUtilities.characterCount(of: self)
    }
    
    /// Reverse the string
    var reversed: String {
        TextUtilities.reverse(self)
    }
    
    /// Check if string is not empty after trimming
    var isNotEmpty: Bool {
        StringCleaner.isNotEmpty(self)
    }
    
    /// Truncate string
    /// - Parameter length: Maximum length
    /// - Returns: Truncated string
    func truncated(to length: Int) -> String {
        TextUtilities.truncate(self, to: length)
    }
    
    /// Wrap text at width
    /// - Parameter width: Line width
    /// - Returns: Wrapped text
    func wrapped(at width: Int) -> String {
        TextUtilities.wrap(self, width: width)
    }
    
    /// Escape for CSV
    var csvEscaped: String {
        TextUtilities.escapeCSV(self)
    }
    
}
