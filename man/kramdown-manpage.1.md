# example 1 "April 2013" Example "User Manuals"

## DESCRIPTION

A [Kramdown][kramdown] convert for converting Markdown files into man pages.

## EXAMPLE

    require 'kramdown'
    require 'kramdown/manpage'

    doc = Kramdown::Document.new(File.read('man/kramdown-manpage.1.md'))
    File.write('man/kramdown-manpage.1',doc.to_manpage)
    system 'man', 'man/kramdown-manpage.1'

## SYNTAX

### PARAGRAPHS

Normal paragraph.

`--tagged`
  Paragraph

### LINKS

[website](http://example.com/)

[bash](man:bash(1))

Email <bob@example.com>

### LISTS

* one
* two
* three

  extra paragraph

1. one
2. two
3. three

   extra paragraph

### HORIZONTAL RULE

-------------------------------------------------------------------------------

### BLOCKQUOTES

> Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
>
> --Antoine de Saint-Exupéry

### CODE BLOCKS

    #include <stdio.h>

    int main()
    {
	    printf("hello world\n");
	    return 0;
    }

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

[kramdown]: http://kramdown.rubyforge.org/
