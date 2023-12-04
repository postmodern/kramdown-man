### 1.0.0 / 2023-12-03

* Ignore `kd:blank` elements to reduce size of generated man pages.
* No longer output `.HP` paragraphs due to cross-platform compatibility issues
  with `groff`, `nroff`, `troff`.
* Renamed `Kramdown::Converters::Man` to {Kramdown::Man::Converter}.
* Override {Kramdown::Document#to_man} to use our {Kramdown::Man::Converter}.

#### Syntax

* Added support for definition lists.
* Switched to using definition lists for documenting options and arguments.

  ```markdown
  ## ARGUMENTS

  *ARG*
  : Description goes here.

  ...
  ```

  ```markdown
  ## OPTIONS

  `-o`, `--option` *VALUE
  : Description goes here.

  ...
  ```
* Added support for rendering relative links to other markdown man pages
  as `SEE ALSO` man page references.

  Example:

  ```markdown
  [foo-bar](foo-bar.1.md)
  ```

  Will be converted into:

  ```
  foo-bar(1)
  ```
* Ignore horizontal rule elements due to cross-platform compatibility issues
  with `groff`, `nroff`, `troff`.

#### CLI

* Added the `-V`, `--version` option.

### 0.1.9 / 2023-12-01

* Allow markdown `man:file.ext` style links, since man pages can be named after
  file names (ex: `shard.yml`).
* Use the `.PP` roff macro instead of the deprecated `.HP` macro.

### 0.1.8 / 2020-12-26

* Upgrade to kramdown 2.x.

### 0.1.7 / 2020-07-22

* Fixed a bug where kramdown's version of `kramdown/converter/man` was being
  loaded instead of kramdown-man's version.

### 0.1.6 / 2015-12-25

* Commented out duplicate Hash entries that were causing warnings.

### 0.1.5 / 2013-05-19

* Translate unicode symbols into roff glyphs.
* Convert typographic symbols and smart quotes into glyphs.
* Simplify `\fB\fC` as `\fC` (Colin Watson).
* Use `\fB` for codespans (Colin Watson).
* Escape `--` as `\-\-` (Colin Watson).
* Escape `\` as `\e` (Colin Watson).
* Emit `.TP` or `.HP` if the paragraph begins with a strong element.

### 0.1.4 / 2013-05-05

* Improve detection of tagged paragraphs.
* Support emitted a hanging paragraph (`.HP`) for command synopsis lines.
* Strip leading whitespace from each line of emitted text.

### 0.1.3 / 2013-05-05

* Initial release:
  * Converts markdown to [roff]:
    * Supports codespans, emphasis and strong fonts.
    * Supports normal and tagged paragraphs.
    * Supports bullet lists.
    * Supports multi-paragraph list items and blockquotes.
    * Supports horizontal rules.
    * Supports converting `[bash](man:bash(1))` links into man page references.
  * Provides Rake task for converting `man/*.md` into man pages.
  * Uses the pure-Ruby [Kramdown][kramdown] markdown parser.
  * Supports [Ruby] 1.8.x, 1.9.x, 2.0.x, [JRuby], [Rubinius].

[kramdown]: http://kramdown.rubyforge.org/
[roff]: http://en.wikipedia.org/wiki/Roff

[Ruby]: http://www.ruby-lang.org/
[JRuby]: http://jruby.org/
[Rubinius]: http://rubini.us/
