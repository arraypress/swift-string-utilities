//
//  TextTransform+CaseStyle.swift
//  StringUtilities
//

import Foundation

extension TextTransform {

    /// The cases text can be written in.
    public enum CaseStyle: Sendable {

        /// UPPERCASE
        case uppercase

        /// lowercase
        case lowercase

        /// Capitalize Every Word
        case capitalized

        /// First word of each sentence capitalized.
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
}
