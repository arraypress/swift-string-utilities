# SwiftStringUtilities

A comprehensive Swift package for string manipulation, text cleaning, list processing, and case transformations. Zero dependencies, pure Swift implementation.

## Features

- 🧹 **Text Cleaning** - Remove extra spaces, fix formatting, normalize line breaks, smart quotes
- 📝 **List Operations** - Sort, deduplicate, format with numbers/bullets
- 🔤 **Case Transformations** - Convert between camelCase, snake_case, PascalCase, and more
- 📊 **Text Analysis** - Extract words, count occurrences, analyze content
- 🛠 **Text Utilities** - Word counting, text wrapping, truncation, CSV escaping
- 🔄 **Template Processing** - Replace content between delimiters
- 🚀 **Type-Safe API** - Leverage Swift's type system with enums and option sets
- 📦 **Zero Dependencies** - Pure Swift implementation, no external dependencies

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-string-utilities.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version requirements

## Usage

### Text Cleaning

Clean messy text with various options:

```swift
import SwiftStringUtilities

let messyText = "Hello    World!\n\n\n\nThis   has  extra   spaces."

// Standard cleaning (remove extra spaces + trim)
let cleaned = messyText.cleaned()

// Normalize smart quotes
let quoted = ""Hello" and 'world'"
let normalized = quoted.quotesNormalized  // "Hello" and 'world'

// Custom cleaning options
let aggressive = messyText.cleaned(options: [
    .removeExtraSpaces,
    .removeEmptyLines,
    .normalizeLineBreaks,
    .normalizeQuotes,
    .trimWhitespace
])

// Using the static method
let result = StringCleaner.clean(messyText, options: .aggressive)

// Check if string is not empty after trimming
if messyText.isNotEmpty {
    // Process the text
}
```

### List Processing & Formatting

Sort, manipulate, and format lists:

```swift
let list = """
apple
Banana
apple
cherry
Date
"""

// Sort alphabetically
let sorted = list.sortedLines(.ascending)
// Result: apple, apple, Banana, cherry, Date

// Remove duplicates
let unique = list.deduplicatedLines()
// Result: apple, Banana, cherry, Date

// Add numbers to list items
let numbered = list.numberedList()
// Result:
// 1. apple
// 2. Banana
// 3. cherry
// 4. Date

// Add bullets to list items
let bulleted = list.bulletedList()
// Result:
// • apple
// • Banana
// • cherry
// • Date

// Custom bullet style
let custom = list.bulletedList(bullet: "→")
// Result:
// → apple
// → Banana
// → cherry
// → Date

// Natural sort (handles numbers properly)
let items = "item10\nitem2\nitem1"
let natural = items.sortedLines(.natural)
// Result: item1, item2, item10
```

### Case Transformations

Transform text between different case styles:

```swift
let text = "hello world example"

// Basic transformations
text.transformed(to: .uppercase)      // "HELLO WORLD EXAMPLE"
text.transformed(to: .lowercase)      // "hello world example"
text.transformed(to: .capitalized)    // "Hello World Example"
text.transformed(to: .sentence)       // "Hello world example"

// Programming case styles
text.transformed(to: .camelCase)      // "helloWorldExample"
text.transformed(to: .pascalCase)     // "HelloWorldExample"
text.transformed(to: .snakeCase)      // "hello_world_example"
text.transformed(to: .kebabCase)      // "hello-world-example"
text.transformed(to: .constantCase)   // "HELLO_WORLD_EXAMPLE"
text.transformed(to: .dotCase)        // "hello.world.example"
text.transformed(to: .pathCase)       // "hello/world/example"

// Fun transformation
text.transformed(to: .alternating)    // "hElLo WoRlD eXaMpLe"
```

### Text Analysis

Extract and analyze text content:

```swift
let text = "The quick brown fox jumps over the lazy fox."

// Extract unique words
let unique = text.uniqueWords
// Result: ["brown", "fox", "jumps", "lazy", "over", "quick", "the"]

// Extract all words (including duplicates)
let allWords = text.words
// Result: ["the", "quick", "brown", "fox", "jumps", "over", "the", "lazy", "fox"]

// Count specific occurrences
let count = TextUtilities.count(of: "fox", in: text)  // 2

// Word, line, and character counts
text.wordCount        // 9
text.lineCount        // 1
text.characterCount   // 44
```

### Template Processing

Replace content between delimiters:

```swift
let template = "Hello [NAME], welcome to [PLACE]!"

// Replace placeholders
if let result = template.replacingBetween(start: "[", end: "]", with: "David") {
    print(result)  // "Hello [David], welcome to [PLACE]!"
}

// More complex example
let html = "<title>Old Title</title>"
if let updated = html.replacingBetween(start: "<title>", end: "</title>", with: "New Title") {
    print(updated)  // "<title>New Title</title>"
}
```

### Text Utilities

Various utility functions for text manipulation:

```swift
let text = "The quick brown fox jumps over the lazy dog."

// Text manipulation
text.reversed         // ".god yzal eht revo spmuj xof nworb kciuq ehT"
text.truncated(to: 20) // "The quick brown f..."

// Text wrapping
let longText = "This is a very long line that needs to be wrapped at a specific width."
let wrapped = longText.wrapped(at: 20)
// Result:
// "This is a very long
//  line that needs to
//  be wrapped at a
//  specific width."

// CSV escaping
let csvField = "Hello, \"World\""
let escaped = csvField.csvEscaped  // "\"Hello, \"\"World\"\"\""
```

## API Reference

### StringCleaner

#### Cleaning Options
- `.removeExtraSpaces` - Remove multiple consecutive spaces and tabs
- `.removeEmptyLines` - Remove lines containing only whitespace
- `.trimWhitespace` - Remove leading and trailing whitespace
- `.normalizeLineBreaks` - Convert all line breaks to \n
- `.fixAllCaps` - Convert ALL CAPS to Capitalized Case
- `.removeExtraLineBreaks` - Replace multiple line breaks with double line break
- `.removeInvisible` - Remove zero-width and non-printable characters
- `.normalizeQuotes` - Convert smart quotes to straight quotes

#### Preset Options
- `.standard` - Basic cleaning (extra spaces + trim)
- `.aggressive` - Common cleaning operations
- `.all` - Apply all cleaning operations

### ListProcessor

#### Sort Orders
- `.ascending` - A to Z
- `.descending` - Z to A
- `.byLength` - Shortest to longest
- `.byLengthDescending` - Longest to shortest
- `.natural` - Natural sort (handles numbers properly)
- `.random` - Random shuffle

#### List Formatting
- `numberList(_:separator:startIndex:)` - Add numbers to list items
- `bulletList(_:bullet:separator:)` - Add bullets to list items

#### Processing Options
- `removeDuplicates` - Remove duplicate items
- `removeEmpty` - Remove empty items
- `trimItems` - Trim whitespace from items
- `caseSensitive` - Use case-sensitive comparisons

### TextTransform

#### Case Styles
| Style | Example |
|-------|---------|
| `.uppercase` | HELLO WORLD |
| `.lowercase` | hello world |
| `.capitalized` | Hello World |
| `.sentence` | Hello world. |
| `.camelCase` | helloWorld |
| `.pascalCase` | HelloWorld |
| `.snakeCase` | hello_world |
| `.kebabCase` | hello-world |
| `.constantCase` | HELLO_WORLD |
| `.dotCase` | hello.world |
| `.pathCase` | hello/world |
| `.alternating` | hElLo WoRlD |

### TextUtilities

Static utility methods for text analysis and manipulation:
- `count(of:in:caseSensitive:)` - Count substring occurrences
- `extractUniqueWords(from:caseSensitive:)` - Get unique words from text
- `extractWords(from:caseSensitive:)` - Get all words from text
- `replaceBetween(in:start:end:with:)` - Replace text between delimiters
- `wordCount(of:)` - Count words
- `lineCount(of:)` - Count lines
- `characterCount(of:)` - Count characters
- `reverse(_:)` - Reverse text
- `removeAllWhitespace(from:)` - Remove all whitespace
- `truncate(_:to:ellipsis:)` - Truncate with ellipsis
- `wrap(_:width:)` - Wrap text at width
- `escapeCSV(_:)` - Escape for CSV format

## String Extensions

All major functionality is available as convenient String extensions:

```swift
// Cleaning
text.cleaned(options: .standard)
text.quotesNormalized

// List operations
text.sortedLines(.natural)
text.deduplicatedLines()
text.numberedList()
text.bulletedList()

// Transformations
text.transformed(to: .camelCase)

// Text analysis
text.uniqueWords
text.words

// Properties
text.wordCount
text.lineCount
text.characterCount
text.reversed
text.isNotEmpty

// Methods
text.truncated(to: 100)
text.wrapped(at: 80)
text.csvEscaped
text.replacingBetween(start: "[", end: "]", with: "content")
```

## Performance

All operations are optimized for performance:
- Efficient string processing using Foundation APIs
- Minimal memory allocations
- Support for large text processing
- Thread-safe implementations

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ / visionOS 1.0+
- Swift 5.9+

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create your feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Author

Created by David Sherlock

## Acknowledgments

Built with pure Swift and Foundation framework.
