# kramdown-man

* [Homepage](https://github.com/postmodern/kramdown-man#readme)
* [Issues](https://github.com/postmodern/kramdown-man/issues)
* [Documentation](http://rubydoc.info/gems/kramdown-man/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

A [Kramdown][kramdown] convert for converting Markdown files into man pages.

## Features

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

## Synopsis

Render a man page from markdown:

    $ kramdown-man <man/myprog.1.md >man/myprog.1

## Examples

Render a man page from a markdown file:

    require 'kramdown/man'

    doc = Kramdown::Document.new(File.read('man/kramdown-man.1.md'))
    File.write('man/kramdown-man.1',doc.to_man)

    system 'man', 'man/kramdown-man.1'

Define a `man` and file tasks which render all `*.md` files within the
`man/` directory:

    require 'kramdown/man/tasks'
    Kramdown::Man::Tasks.new

## Requirements

* [kramdown] ~> 1.0

## Install

    $ gem install kramdown-man

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
