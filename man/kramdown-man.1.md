# kramdown-man 1 "April 2013" kramdown-man "User Manuals"

## NAME

kramdown-man - generates man pages from markdown files

## SYNOPSIS

`kramdown-man` [*options*] *MARKDOWN_FILE*

## DESCRIPTION

A [Kramdown][kramdown] plugin for converting Markdown files into man pages.

## ARGUMENTS

*MARKDOWN_FILE*
: The input markdown file to convert.

## OPTIONS

`-o`, `--output` *OUTPUT*
: The file to write the man page output to.

`-V`, `--version`
: Prints the `kramdown-man` version.

`-h`, `--help`
: Prints the usage for `kramdown-man`.

## EXAMPLE

Render a man page from markdown:

    $ kramdown-man -o man/myprogram.1 man/myprogram.1.md

Preview the rendered man page:

    $ kramdown-man man/myprogram.1.md

### RUBY

    require 'kramdown'
    require 'kramdown/man'

    doc = Kramdown::Document.new(File.read('man/kramdown-man.1.md'))
    File.write('man/kramdown-man.1',doc.to_man)
    system 'man', 'man/kramdown-man.1'

### RAKE TASK

Define a `man` and files tasks which render all `*.md` files within the
`man/` directory:

    require 'kramdown/man/task'
    Kramdown::Man::Task.new

## SYNTAX

### Code

    `code`

`code`

### Emphasis

    *emphasis*

*emphasis*

### Strong

    **strong**

**strong**

### Paragraph

    Normal paragraph.

Normal paragraph.

#### Usage String

    `command` [`--foo`] **FILE**

`command` [`--foo`] **FILE**

#### Argument Definitions

    *ARG*
    : Description here.

*ARG*
: Description here.

#### Option Definitions

    `-o`, `--option` *VALUE*
    : Description here.

`-o`, `--option` *VALUE*
: Description here.

### Links

    [website](http://example.com/)

[website](http://example.com/)

#### Man Pages

Link to other man pages in a project:

    [kramdown-man](kramdown-man.1.md)

[kramdown-man](kramdown-man.1.md)

Link to other system man page:

    [bash](man:bash(1))

[bash](man:bash(1))

**Note:** only works on [firefox] on Linux.

[firefox]: https://www.mozilla.org/en-US/firefox/new/

#### Email Addresses

    Email <bob@example.com>

Email <bob@example.com>

### Lists

    * one
    * two
    * three

* one
* two
* three

#### Numbered Lists

    1. one
    2. two
    3. three

1. one
2. two
3. three

#### Definition Lists

    ex·am·ple
    : a thing characteristic of its kind or illustrating a general rule.

    : a person or thing regarded in terms of their fitness to be imitated or the
      likelihood of their being imitated.

ex·am·ple
: a thing characteristic of its kind or illustrating a general rule.

: a person or thing regarded in terms of their fitness to be imitated or the
  likelihood of their being imitated.

### Blockquotes

    > Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
    >
    > --Antoine de Saint-Exupéry

> Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
>
> --Antoine de Saint-Exupéry

### Code Blocks

    Source code:

        #include <stdio.h>

        int main()
        {
            printf("hello world\n");
            return 0;
        }

Source code:

    #include <stdio.h>

    int main()
    {
	    printf("hello world\n");
	    return 0;
    }

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

[kramdown]: http://kramdown.gettalong.org/
