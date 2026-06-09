# Swift String Utilities

A comprehensive Swift package for string manipulation — text cleaning, list processing, case transformations, and text analysis — with ergonomic `String` extensions. Pure Swift, zero dependencies.

## Features

- 🧹 **Text cleaning** — `StringCleaner` collapses extra spaces, trims whitespace, normalizes line breaks and smart quotes, strips invisible characters, and fixes ALL-CAPS words via composable `OptionSet` flags
- 📋 **List processing** — `ListProcessor` splits, trims, deduplicates, and sorts lists (ascending, descending, by length, natural, random)
- 🔢 **List formatting** — number or bullet any list with one call
- 🔤 **Case transforms** — `TextTransform` converts to camelCase, PascalCase, snake_case, kebab-case, CONSTANT_CASE, dot.case, path/case, sentence, and aLtErNaTiNg case
- 📊 **Text analysis** — word/line/character counts, unique-word extraction, and substring counting
- ✂️ **Text manipulation** — truncate with ellipsis, word-wrap at a width, reverse, strip all whitespace, and replace text between delimiters
- 📄 **CSV-safe escaping** — quote and escape fields for CSV output
- 🍏 **String extensions** — call everything fluently: `.cleaned()`, `.sortedLines()`, `.transformed(to:)`, `.wordCount`, `.truncated(to:)`, and more
- 🪶 **Zero dependencies** — Foundation only
- 🍎 **Cross-platform** — iOS, macOS, tvOS, watchOS, visionOS

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ / visionOS 1.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-string-utilities.git", from: "1.0.0")
]
```

## Usage

### Cleaning Text

```swift
import StringUtilities

let messy = "  Hello   WORLD!!  \n\n\n  Extra   spaces  "
let clean = StringCleaner.clean(messy, options: .aggressive)

// Or fluently, with the default .standard options
let trimmed = messy.cleaned()

// Compose your own flags
let custom = messy.cleaned(options: [.removeExtraSpaces, .normalizeQuotes, .trimWhitespace])
```

Available presets: `.standard`, `.aggressive`, `.all` — or build from individual flags like `.removeExtraSpaces`, `.removeEmptyLines`, `.trimWhitespace`, `.normalizeLineBreaks`, `.fixAllCaps`, `.removeExtraLineBreaks`, `.removeInvisible`, `.normalizeQuotes`.

### Processing Lists

```swift
import StringUtilities

let list = "Banana\nApple\napple\nCherry"

// Sort, dedupe (case-insensitive), trim — in one call
let sorted = ListProcessor.process(
    list,
    sortOrder: .ascending,
    options: .init(removeDuplicates: true)
)

// Convenience helpers
let deduped = list.deduplicatedLines()
let numbered = "First\nSecond\nThird".numberedList()      // "1. First\n2. Second\n..."
let bulleted = "First\nSecond".bulletedList(bullet: "-")  // "- First\n- Second"
let natural  = "item10\nitem2\nitem1".sortedLines(.natural)
```

### Transforming Case

```swift
import StringUtilities

TextTransform.transform("hello world", to: .snakeCase)     // "hello_world"
TextTransform.transform("hello world", to: .camelCase)     // "helloWorld"
TextTransform.transform("HelloWorld",  to: .kebabCase)     // "hello-world"

// Fluently
"my variable name".transformed(to: .pascalCase)            // "MyVariableName"
"some_constant".transformed(to: .constantCase)             // "SOME_CONSTANT"
```

### Analyzing Text

```swift
import StringUtilities

let text = "The quick brown fox. The lazy dog."

text.wordCount                                    // 8
text.lineCount                                    // 1
text.characterCount                               // 34
text.uniqueWords                                  // sorted, lowercased
TextUtilities.count(of: "the", in: text, caseSensitive: false)  // 2
```

### Manipulating Text

```swift
import StringUtilities

"A long sentence here".truncated(to: 10)          // "A long..."
"one two three four five".wrapped(at: 12)         // wraps to 12-col lines
"hello".reversed                                  // "olleh"
"name,with,commas".csvEscaped                     // "\"name,with,commas\""

// Replace content between delimiters
"Hello [name]!".replacingBetween(start: "[", end: "]", with: "World")  // "Hello [World]!"
```

## Models

| Type | Purpose |
|------|---------|
| `StringCleaner` | Text cleaning and normalization (`clean`, `normalizeQuotes`, `isNotEmpty`) with `StringCleaner.Options` flags |
| `ListProcessor` | List splitting, dedup, sorting, numbering, and bulleting; `SortOrder` and `Options` |
| `TextTransform` | Case transformations via `CaseStyle` |
| `TextUtilities` | Counting, extraction, truncation, wrapping, CSV escaping, delimiter replacement |
| `String` extension | Fluent wrappers for all of the above |

## Testing

```bash
swift test
```

Tests cover cleaning options, list processing and sorting, every case transformation, and the text-analysis and manipulation helpers.

## License

MIT License — see LICENSE file for details.

## Author

Created by David Sherlock ([ArrayPress](https://github.com/arraypress)) in 2026.
