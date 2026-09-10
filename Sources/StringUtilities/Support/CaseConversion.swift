//
//  CaseConversion.swift
//  StringUtilities
//
//  Word splitting and the case conversions built on it.
//

import Foundation

/// The case conversions as pure functions, sharing one word splitter.
enum CaseConversion {

    /// Runs the conversion for a style.
    static func convert(_ text: String, to style: TextTransform.CaseStyle) -> String {
        switch style {
        case .uppercase:    return text.uppercased()
        case .lowercase:    return text.lowercased()
        case .capitalized:  return text.capitalized
        case .sentence:     return sentence(text)
        case .camelCase:    return camel(text)
        case .pascalCase:   return pascal(text)
        case .snakeCase:    return snake(text)
        case .kebabCase:    return kebab(text)
        case .constantCase: return constant(text)
        case .dotCase:      return dot(text)
        case .pathCase:     return path(text)
        case .alternating:  return alternating(text)
        }
    }

    /// The words of `text`, for the programmer cases.
    ///
    /// Splits on anything that is not a letter or digit. When that leaves
    /// the text in one piece, it is already a `camelCase` or `PascalCase`
    /// identifier, and it is split on its capitals instead.
    static func words(in text: String) -> [String] {
        let words = text.components(separatedBy: .alphanumerics.inverted).filter { !$0.isEmpty }
        if words.count == 1 && words[0] == text {
            return splitCamelCase(text)
        }
        return words
    }

    /// Splits an identifier on its capitals: `helloWorld` → `hello`, `World`;
    /// `HTTPServer` → `HTTP`, `Server`. A run of capitals stays together
    /// until the letter that starts the next word.
    static func splitCamelCase(_ text: String) -> [String] {
        let pattern = "(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])"
        return text.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
    }

    /// Capitalises the first letter after each `. ` and lowercases the rest.
    static func sentence(_ text: String) -> String {
        text.components(separatedBy: ". ").map { sentence in
            guard !sentence.isEmpty else { return sentence }
            return sentence.prefix(1).uppercased() + sentence.dropFirst().lowercased()
        }.joined(separator: ". ")
    }

    /// `helloWorld`. Text with no words at all comes back unchanged.
    static func camel(_ text: String) -> String {
        let words = words(in: text)
        guard !words.isEmpty else { return text }
        return words[0].lowercased() + words.dropFirst().map { $0.capitalized }.joined()
    }

    /// `HelloWorld`.
    static func pascal(_ text: String) -> String {
        words(in: text).map { $0.capitalized }.joined()
    }

    /// `hello_world`.
    static func snake(_ text: String) -> String {
        joined(text, lowercased: true, separator: "_")
    }

    /// `hello-world`.
    static func kebab(_ text: String) -> String {
        joined(text, lowercased: true, separator: "-")
    }

    /// `HELLO_WORLD`.
    static func constant(_ text: String) -> String {
        joined(text, lowercased: false, separator: "_")
    }

    /// `hello.world`.
    static func dot(_ text: String) -> String {
        joined(text, lowercased: true, separator: ".")
    }

    /// `hello/world`.
    static func path(_ text: String) -> String {
        joined(text, lowercased: true, separator: "/")
    }

    /// `aLtErNaTiNg`: every letter flips, starting lower, and characters that
    /// are not letters do not advance the pattern.
    ///
    /// Built by appending strings rather than characters, because a letter's
    /// uppercase form can be more than one character — `ß` is `SS` — and
    /// `Character("SS")` is a crash.
    static func alternating(_ text: String) -> String {
        var shouldUppercase = false
        var result = ""
        for char in text {
            if char.isLetter {
                result += shouldUppercase ? char.uppercased() : char.lowercased()
                shouldUppercase.toggle()
            } else {
                result.append(char)
            }
        }
        return result
    }

    /// The words, each lowercased or uppercased, joined by `separator`.
    private static func joined(_ text: String, lowercased: Bool, separator: String) -> String {
        words(in: text).map { lowercased ? $0.lowercased() : $0.uppercased() }.joined(separator: separator)
    }
}
