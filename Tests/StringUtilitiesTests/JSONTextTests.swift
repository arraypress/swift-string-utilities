//
//  JSONTextTests.swift
//  StringUtilities
//
//  Each test pins one thing JSONText promises — or one thing the README
//  admits Foundation does, so a change in either shows up here first.
//

import XCTest
@testable import StringUtilities

final class JSONTextTests: XCTestCase {

    func testPrettyIndentsTwoSpacesPerLevel() throws {
        let pretty = try JSONText.pretty(#"{"a":{"b":1}}"#)
        XCTAssertEqual(pretty, "{\n  \"a\": {\n    \"b\": 1\n  }\n}")
    }

    func testPrettySortsKeysWhenAsked() throws {
        let pretty = try JSONText.pretty(#"{"zebra":1,"apple":2,"mango":3}"#, sortedKeys: true)
        let apple = try XCTUnwrap(pretty.range(of: "apple"))
        let mango = try XCTUnwrap(pretty.range(of: "mango"))
        let zebra = try XCTUnwrap(pretty.range(of: "zebra"))
        XCTAssertLessThan(apple.lowerBound, mango.lowerBound)
        XCTAssertLessThan(mango.lowerBound, zebra.lowerBound)
    }

    func testMinifyRemovesWhitespaceOutsideStringsOnly() throws {
        let minified = try JSONText.minify("{ \"a\" : [ 1 , 2 , \"x y\" ] }\n")
        XCTAssertEqual(minified, #"{"a":[1,2,"x y"]}"#)
    }

    func testPrettyAndMinifyRoundTripToTheSameValue() throws {
        let original = #"{"name":"café","tags":["a","b"],"count":3,"nested":{"ok":true,"none":null}}"#
        let there = try JSONText.pretty(original)
        let back = try JSONText.minify(there)
        let a = try JSONSerialization.jsonObject(with: Data(original.utf8)) as? NSDictionary
        let b = try JSONSerialization.jsonObject(with: Data(back.utf8)) as? NSDictionary
        XCTAssertEqual(a, b)
    }

    func testInvalidTextThrowsWithTheParsersReason() {
        XCTAssertThrowsError(try JSONText.pretty(#"{"a":x}"#)) { error in
            guard case JSONTextError.invalid(let reason) = error else {
                return XCTFail("wrong error: \(error)")
            }
            XCTAssertTrue(reason.contains("line 1"), reason)
            XCTAssertEqual(error.localizedDescription, "not valid JSON: \(reason)")
        }
    }

    func testEmptyTextIsNotJSON() {
        XCTAssertFalse(JSONText.isValid(""))
        XCTAssertThrowsError(try JSONText.validate(""))
    }

    func testIsValidAgreesWithValidate() {
        XCTAssertTrue(JSONText.isValid(#"{"a":[1,2,3]}"#))
        XCTAssertNoThrow(try JSONText.validate(#"{"a":[1,2,3]}"#))
        XCTAssertFalse(JSONText.isValid("{'single': 'quotes'}"))
        XCTAssertThrowsError(try JSONText.validate("{'single': 'quotes'}"))
    }

    func testAScalarIsValidAtTheTopLevel() throws {
        // RFC 8259 allows any value at the top level, not only an object or array.
        XCTAssertTrue(JSONText.isValid("42"))
        XCTAssertTrue(JSONText.isValid("null"))
        XCTAssertTrue(JSONText.isValid("\"text\""))
        XCTAssertEqual(try JSONText.minify("  42 "), "42")
    }

    func testUnicodeIsWrittenAsItselfNotEscaped() throws {
        let pretty = try JSONText.pretty(#"{"a":"café 日本 🙂"}"#)
        XCTAssertTrue(pretty.contains("café 日本 🙂"))
        XCTAssertFalse(pretty.contains("\\u"))
    }

    func testSlashesAreNotEscaped() throws {
        let minified = try JSONText.minify(#"{"url":"https://example.com/a/b"}"#)
        XCTAssertEqual(minified, #"{"url":"https://example.com/a/b"}"#)
    }

    func testNumbersAreReRenderedAsTheDocsAdmit() throws {
        // 1.0 comes back as 1. Pinned so the README stays honest if Foundation changes.
        XCTAssertEqual(try JSONText.minify(#"{"a":1.0}"#), #"{"a":1}"#)
        XCTAssertEqual(try JSONText.minify("12345678901234567890"), "12345678901234567890")
    }
}
