# kramdown-man.1 "April 2013" kramdown-man "User Manuals"

## DESCRIPTION

A [Kramdown][kramdown] plugin for converting Markdown files into man pages.

## EXAMPLE

    require 'kramdown'
    require 'kramdown/man'

    doc = Kramdown::Document.new(File.read('man/kramdown-man.1.md'))
    File.write('man/kramdown-man.1',doc.to_man)
    system 'man', 'man/kramdown-man.1'

## SYNTAX

### FORMATTING

    `code`

`code`

    *emphasis*

*emphasis*

    **strong**

**strong**

### PARAGRAPHS

    Normal paragraph.

Normal paragraph.

    `command` [`--foo`] _FILE_

`command` [`--foo`] _FILE_

    `--tagged`
      Text here.

`--tagged`
  Text here.

### LINKS

    [website](http://example.com/)

[website](http://example.com/)

    [bash](man:bash(1))

[bash](man:bash(1))

    Email <bob@example.com>

Email <bob@example.com>

### LISTS

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

### HORIZONTAL RULE

    -------------------------------------------------------------------------------

-------------------------------------------------------------------------------

### BLOCKQUOTES

    > Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
    >
    > --Antoine de Saint-Exupéry

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

    #include <stdio.h>

    int main()
    {
	    printf("hello world\n");
	    return 0;
    }

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

[kramdown]: http://kramdown.gettalong.org/
