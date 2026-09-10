//
//  TextUtilities+PadSide.swift
//  StringUtilities
//
//  Which side padding goes on.
//

import Foundation

extension TextUtilities {

    /// Where ``TextUtilities/pad(_:toLength:with:side:)`` puts the padding.
    public enum PadSide: String, CaseIterable, Sendable, Codable {

        /// Before the text, so it lines up on the right.
        case leading

        /// After the text, so it lines up on the left.
        case trailing

        /// Split evenly; an odd character goes on the right.
        case both
    }
}
