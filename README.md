# Swift String Utilities

Text cleaning, lists, case conversion, counting and JSON formatting — as plain functions on plain strings, on any Apple platform.

```swift
import StringUtilities

"  Hello   WORLD!!  \n\n\n  Extra   spaces  ".cleaned(options: .aggressive)
// "Hello WORLD!!\nExtra spaces"

"item10\nitem2\nitem1".sortedLines(.natural)          // "item1\nitem2\nitem10"
"HTTPServerError".transformed(to: .snakeCase)         // "http_server_error"
"e\u{301}".characterCount                             // 1
try JSONText.pretty(#"{"b":[1,2.0],"a":0.1}"#, sortedKeys: true)
// {
//   "a": 0.1,
//   "b": [
//     1,
//     2
//   ]
// }
```

## Why

Every one of these is a two-line function that people write differently each time, and half of the versions are wrong at an edge:

| Question | The wrong answer, and why it is tempting |
|---|---|
| Sort `item1`, `item2`, `item10` | `item1, item10, item2` from a string sort. `.natural` compares the numbers as numbers, the way the Finder does. |
| Is this field empty? | `isEmpty` says a string of spaces is not empty. It is, for every purpose a form has. |
| How many characters in `🇬🇧` or `é` | 2 and 2 from counting scalars, 4 and 3 from counting bytes. A person says 1 and 1. |
| Does this text contain a line break? | `contains("\n")` on a `Character` misses `\r\n`, which Swift treats as one character. Every Windows file has one on every line. |
| Strip the zero-width joiner from `c‍d` | A search for the joiner never finds it: it is glued to the `c`, and Foundation compares whole composed sequences. |
| Pretty-print `{"a":0.1}` | `0.10000000000000001`, from Foundation's own writer. The shortest text that reads back to the same number is `0.1`. |

## Installation

```swift
.package(url: "https://github.com/arraypress/swift-string-utilities.git", from: "1.2.0")
```

Foundation only. No dependencies, every Apple platform, macOS 14+.

## Cleaning text

`StringCleaner.clean(_:options:)` runs the steps you ask for, in the one order that keeps them from undoing each other:

```swift
StringCleaner.clean(messy)                                  // .standard: collapse spaces, trim
StringCleaner.clean(messy, options: .aggressive)            // + drop empty lines, normalise line breaks
StringCleaner.clean(messy, options: .all)                   // every step there is
StringCleaner.clean(messy, options: [.removeInvisible, .normalizeQuotes, .trimWhitespace])
```

The steps: `.removeExtraSpaces`, `.removeEmptyLines`, `.trimWhitespace`, `.normalizeLineBreaks`, `.fixAllCaps`, `.removeExtraLineBreaks`, `.removeInvisible`, `.normalizeQuotes`. Two worth knowing about: `.fixAllCaps` leaves words of four letters or fewer alone, because those are acronyms; `.removeInvisible` filters scalars rather than searching for them, because a zero-width joiner is invisible to a search too.

`StringCleaner.isNotEmpty(_:)` answers the form-field question — spaces, tabs, line breaks and non-breaking spaces all count as empty. `StringCleaner.normalizeQuotes(_:)` turns curly quotes and guillemets into straight ones.

## Lists held in text

```swift
ListProcessor.process("b, a ,c", separator: ",", sortOrder: .ascending)   // "a,b,c"
ListProcessor.sortLines(text, order: .natural, removeDuplicates: true)
ListProcessor.deduplicateLines(text)                                       // first occurrence kept, order kept
ListProcessor.numberList("a\nb", startIndex: 0)                            // "0. a\n1. b"
ListProcessor.bulletList("a\nb", bullet: "-")                              // "- a\n- b"
```

Six orders: `.ascending`, `.descending`, `.byLength`, `.byLengthDescending`, `.natural` and `.random`. Items are trimmed before duplicates are looked for, and duplicates are found case-insensitively unless `Options(caseSensitive: true)` says otherwise — `Apple` and `apple` are one item, and the first spelling wins. Blank items are dropped, so numbering has no gaps.

## Changing case

```swift
TextTransform.transform("hello world", to: .camelCase)      // "helloWorld"
TextTransform.transform("helloWorld", to: .kebabCase)       // "hello-world"
TextTransform.transform("HTTPServerError", to: .snakeCase)  // "http_server_error"
TextTransform.transform("hello. world", to: .sentence)      // "Hello. World"
TextTransform.transform("hello", to: .alternating)          // "hElLo"
```

Twelve styles: `uppercase`, `lowercase`, `capitalized`, `sentence`, `camelCase`, `pascalCase`, `snakeCase`, `kebabCase`, `constantCase`, `dotCase`, `pathCase`, `alternating`. The programmer cases split on anything that is not a letter or digit, and when that leaves one unbroken word, on its capitals — so `hello world`, `hello_world` and `helloWorld` all come out the same. Whatever case the words were written in, the words are still there: every style converts back to the same `snake_case`.

## Counting and editing

```swift
TextUtilities.count(of: "aa", in: "aaa")                    // 1 — no overlap
TextUtilities.wordCount(of: text)
TextUtilities.lineCount(of: "a\r\nb")                       // 2 — a Windows line break is one break
TextUtilities.characterCount(of: "🇬🇧")                      // 1
TextUtilities.extractUniqueWords(from: "The the THE")       // ["the"]
TextUtilities.truncate("hello world", to: 8)                // "hello..." — the ellipsis counts
TextUtilities.wrap(text, width: 40)                         // at spaces; a long word gets its own line
TextUtilities.reverse("e\u{301}x")                          // "xe\u{301}" — the accent stays on its letter
TextUtilities.replaceBetween(in: "Hello [name]!", start: "[", end: "]", with: "World")
TextUtilities.escapeCSV("a,b")                              // "\"a,b\"" — RFC 4180
```

## Slugs for URLs

```swift
TextTransform.slugify("Zürich & Co. — 2026!")                 // "zurich-co-2026"
TextTransform.slugify("Straße Ærø Łódź")                       // "strasse-aero-lodz"
TextTransform.slugify("the quick brown fox", maxLength: 11)   // "the-quick" — never mid-word
TextTransform.slugify("Москва 2026")                          // "2026"
TextTransform.slugify("Москва 2026", transliterate: true)     // "moskva-2026"
TextTransform.slugify("東京", allowUnicode: true)              // "東京"
"Hello, World!".slugified()                                   // "hello-world"
```

Not kebab-case. Kebab is a case style for identifiers and keeps every letter it is
given; a slug is what goes after the last `/` in an address, so accents fold to plain
letters — including the ones Foundation cannot decompose, `ß`, `æ`, `ø`, `ł`, `þ` —
everything that is not a letter or digit becomes one separator, runs collapse, and
the ends are trimmed. Other scripts are dropped unless `allowUnicode` keeps them or
`transliterate` romanises them first.

## Padding and joined lines

```swift
TextUtilities.pad("7", toLength: 3, with: "0", side: .leading)   // "007"
TextUtilities.pad("ab", toLength: 6, side: .both)                // "  ab  "
TextUtilities.pad("hello world", toLength: 5)                    // "hello world" — never truncates
TextUtilities.joinLines("a\r\nb\n\nc")                          // "a b c"
TextUtilities.joinLines("a\n\nb", with: "|", skippingEmpty: false) // "a||b"
```

Padding counts characters, so a flag emoji is one. Joining treats Windows and classic
Mac line breaks as one break each, and a line of nothing but whitespace as empty.

## Hashtags and mentions

```swift
TextUtilities.hashtags(in: "Try #swift, #SwiftUI! (#macos)")   // ["swift", "SwiftUI", "macos"]
TextUtilities.hashtags(in: "#Swift #swift #ios", unique: true) // ["Swift", "ios"]
TextUtilities.mentions(in: "cc @alice — write to me@example.com") // ["alice"]
```

A marker counts only at the start of the text or after whitespace, an opening bracket
or a quote, which is what keeps `a#b`, `site.com/#anchor` and `me@example.com` out.
The token runs over letters of any script, digits and underscores, so trailing
punctuation never sticks. A hashtag needs a letter (`#2024` is a number, as the
networks rule); a mention does not (`@2pac` is a name). `unique` keeps the first
spelling, compared without case.

## Statistics

```swift
let stats = TextUtilities.statistics(of: article)
stats.words                 // 1,204
stats.sentences             // 58 — "e.g.", "Dr." and "J." do not close one
stats.paragraphs            // 9, separated by blank lines
stats.readingTimeText       // "5 min", at 238 words a minute
```

Characters as a person counts them, characters without whitespace, words, sentences,
paragraphs, lines, the average word length with punctuation stripped, and the reading
time at 238 words a minute — the adult silent-reading rate from Brysbaert's 2019
meta-analysis of 190 studies. Any text at all reads as at least a minute; only empty
text is `0 min`.

## JSON as text

```swift
try JSONText.pretty(text)                       // two-space indent, "key": value
try JSONText.pretty(text, sortedKeys: true)     // stable across runs, diffs cleanly
try JSONText.minify(text)                       // no whitespace outside strings
JSONText.isValid(text)                          // the question
try JSONText.validate(text)                     // the reason, with line and column
```

Parsing is Foundation's, which is strict about the grammar in every way but one: it accepts a trailing comma. That is checked separately and refused, because the API the text was written for will refuse it too. Writing is this package's own, because Foundation prints `0.1` as `0.10000000000000001` and puts a space before every colon.

Three things about the output, stated plainly. Keys come back in a different order unless you ask for `sortedKeys`. Numbers are re-rendered, not copied: `1.0` becomes `1`, `1e10` becomes `10000000000`, and a fraction takes the shortest text that reads back to the same double. Duplicate keys keep the first value. Any JSON value is accepted at the top level — `42`, `"text"`, `null` — as RFC 8259 allows.

## On the string itself

Everything above is also a method or property on `String`: `.cleaned()`, `.quotesNormalized`, `.isNotEmpty`, `.sortedLines()`, `.deduplicatedLines()`, `.numberedList()`, `.bulletedList()`, `.transformed(to:)`, `.wordCount`, `.lineCount`, `.characterCount`, `.uniqueWords`, `.words`, `.reversed`, `.truncated(to:)`, `.wrapped(at:)`, `.csvEscaped` and `.replacingBetween(start:end:with:)`.

## Tested

201 tests. Every public function at its edges — empty and whitespace-only text, combining marks, flag emoji, Windows line breaks, non-breaking spaces, a megabyte of input — plus every cleaning option alone and combined, every sort order, every case style round-tripped, truncation at zero and at the exact length, wrapping at width one, and for JSON: bare scalars, nested empty containers, escaped and raw unicode, `1.0`, `1e10` and `-0`, duplicate keys, trailing commas, sorted keys at every level, idempotence, and a 1.3 MB document; and for the text tools: every letter Foundation cannot fold, Cyrillic dropped, kept and romanised, a cut on a word boundary, padding by character, every line-break style, the boundary rules that keep an email out of the mentions, abbreviations and initials that do not end a sentence, and reading time at its edges.

## Licence

MIT.
