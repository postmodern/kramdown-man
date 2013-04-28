# example 1 "April 2013" Example "User Manuals"

## SYNOPSIS

    require 'kramdown'
    require 'kramdown/manpage'

    doc = Kramdown::Document.new(File.read('man/kramdown-manpage.1.md'))
    File.write('man/kramdown-manpage.1',doc.to_manpage)
    system 'man', 'man/kramdown-manpage.1'

## DESCRIPTION

A [Kramdown][kramdown] convert for converting Markdown files into man pages.

## Syntax

### Lists

* one
* two
* three

  extra paragraph

1. one
2. two
3. three

   extra paragraph

### Blockquotes

### Code blocks

    #include <stdio.h>

    int main()
    {
	    printf("hello world\n");
	    return 0;
    }

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

[kramdown]: http://kramdown.rubyforge.org/
