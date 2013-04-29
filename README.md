# kramdown-manpage

* [Homepage](https://github.com/postmodern/kramdown-manpage#readme)
* [Issues](https://github.com/postmodern/kramdown-manpage/issues)
* [Documentation](http://rubydoc.info/gems/kramdown-manpage/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

A [Kramdown][kramdown] convert for converting Markdown files into man pages.

## Features

* Converts markdown to [roff].
  * Supports codespans, emphasis and strong fonts.
  * Supports normal and tagged paragraphs.
  * Supports bullet and dashed lists.
  * Supports multi-paragraph list items and blockquotes.
  * Supports horizontal rules.
  * Supports converting `[bash](man:bash(1))` links into man-page references.
* Provides rake tasks for converting `man/*.md` into man-pages.
* Uses the pure-Ruby [Kramdown][kramdown] markdown parser.
* Supports [Ruby] 1.8.x, 1.9.x, 2.0.x, [JRuby], [Rubinius].

## Examples

Render a manpage from a markdown file:

    require 'kramdown/manpage'

    doc = Kramdown::Document.new(File.read('man/kramdown-manpage.1.md'))
    File.write('man/kramdown-manpage.1',doc.to_manpage)

    system 'man', 'man/kramdown-manpage.1'

Define rake tasks to render all `*.md` files within the `man/` directory:

    require 'kramdown/markdown/tasks'
    Kramdown::Manpage::Tasks.new

## Requirements

* [kramdown] ~> 1.0

## Install

    $ gem install kramdown-manpage

## Alternatives

* [Redcarpet::Render::ManPage](http://rubydoc.info/gems/redcarpet/Redcarpet/Render/ManPage)
* [ronn](https://github.com/rtomayko/ronn#readme)
* [md2man](https://github.com/sunaku/md2man#readme)

## Copyright

Copyright (c) 2013 Hal Brodigan

See {file:LICENSE.txt} for details.

[kramdown]: http://kramdown.rubyforge.org/
[roff]: http://en.wikipedia.org/wiki/Roff

[Ruby]: http://www.ruby-lang.org/
[JRuby]: http://jruby.org/
[Rubinius]: http://rubini.us/
