# kramdown-man

* [Homepage](https://github.com/postmodern/kramdown-man#readme)
* [Issues](https://github.com/postmodern/kramdown-man/issues)
* [Documentation](http://rubydoc.info/gems/kramdown-man/frames)
* [Email](mailto:postmodern.mod3 at gmail.com)

[![Build Status](https://secure.travis-ci.org/postmodern/kramdown-man.png?branch=master)](https://travis-ci.org/postmodern/kramdown-man)

## Description

A [Kramdown][kramdown] convert for converting Markdown files into man pages.

## Features

* Converts markdown to [roff]:
  * Supports codespans, emphasis and strong fonts.
  * Supports normal, hanging and tagged paragraphs.
  * Supports bullet lists.
  * Supports multi-paragraph list items and blockquotes.
  * Supports horizontal rules.
  * Supports converting `[bash](man:bash(1))` links into man page references.
* Provides Rake task for converting `man/*.md` into man pages.
* Uses the pure-Ruby [Kramdown][kramdown] markdown parser.
* Supports [Ruby] 1.9.x, 2.0.x, 2.1.x, 2.2.x, [JRuby], [Rubinius].

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

    require 'kramdown/man/task'
    Kramdown::Man::Task.new

## Syntax

### Formatting

    `code`

`code`

    *emphasis*

*emphasis*

    **strong**

**strong**

### Paragraphs

    Normal paragraph.

Normal paragraph.

    `command` [`--foo`] *FILE*

`command` [`--foo`] *FILE*

    `--tagged`
      Text here.

`--tagged`
  Text here.

### Links

    [website](http://example.com/)

[website](http://example.com/)

    [bash](man:bash(1))

[bash](man:bash(1))

    Email <bob@example.com>

Email <bob@example.com>

### Lists

    * one
    * two
    * three
    
      extra paragraph
    

* one
* two
* three

  extra paragraph

    1. one
    2. two
    3. three
    
       extra paragraph
    
1. one
2. two
3. three

   extra paragraph

### Horizontal Rule

    -------------------------------------------------------------------------------

-------------------------------------------------------------------------------

### Blockquotes

    > Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
    >
    > --Antoine de Saint-Exupéry

> Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
>
> --Antoine de Saint-Exupéry

### Code Blocks

        #include <stdio.h>
    
        int main()
        {
    	    printf("hello world\n");
    	    return 0;
        }

    #include <stdio.h>

    int main()
    {
	    printf("hello world\n");
	    return 0;
    }

## Requirements

* [kramdown] ~> 1.0

## Install

    $ gem install kramdown-man

## Alternatives

* [Redcarpet::Render::ManPage](http://rubydoc.info/gems/redcarpet/Redcarpet/Render/ManPage)
* [ronn](https://github.com/rtomayko/ronn#readme)
* [md2man](https://github.com/sunaku/md2man#readme)

## Copyright

Copyright (c) 2013-2020 Hal Brodigan

See {file:LICENSE.txt} for details.

[kramdown]: http://kramdown.gettalong.org/
[roff]: http://en.wikipedia.org/wiki/Roff

[Ruby]: http://www.ruby-lang.org/
[JRuby]: http://jruby.org/
[Rubinius]: http://rubini.us/
