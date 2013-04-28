# kramdown-manpage

* [Homepage](https://github.com/postmodern/kramdown-manpage#readme)
* [Issues](https://github.com/postmodern/kramdown-manpage/issues)
* [Documentation](http://rubydoc.info/gems/kramdown-manpage/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

## Description

A [Kramdown][kramdown] convert for converting Markdown files into man pages.

## Features

* Converts markdown to [roff].

## Examples

Render a manpage from a markdown file:

    require 'kramdown/manpage'

    doc = Kramdown::Document.new(File.read('man/kramdown-manpage.1.md'))
    File.write('man/kramdown-manpage.1',doc.to_manpage)

    system 'man', 'man/kramdown-manpage.1'

Define rake tasks to render all `*.md` files within the `man/` directory:

    require 'kramdown/markdown/tasks'
    Kramdown::Markdown::Tasks.new

## Requirements

* [kramdown] ~> 1.0.0

## Install

    $ gem install kramdown-manpage

## Copyright

Copyright (c) 2013 Postmodern

See {file:LICENSE.txt} for details.

[kramdown]: http://kramdown.rubyforge.org/
[roff]: http://en.wikipedia.org/wiki/Roff
