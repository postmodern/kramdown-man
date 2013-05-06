### 0.1.2 / 2013-05-05

* Added {Kramdown::Man::Tasks} for backwards compatibility with 0.1.0.

### 0.1.1 / 2013-05-05

* Renamed `Kramdown::Man::Tasks` to {Kramdown::Man::Task}.

### 0.1.0 / 2013-05-05

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
