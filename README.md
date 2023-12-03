# kramdown-man

* [Homepage](https://github.com/postmodern/kramdown-man#readme)
* [Issues](https://github.com/postmodern/kramdown-man/issues)
* [Documentation](http://rubydoc.info/gems/kramdown-man/frames)

## Description

A [Kramdown][kramdown] convert for converting Markdown files into man pages.

## Features

* Converts markdown to [roff]:
  * Supports codespans, emphasis and strong fonts.
  * Supports normal and tagged paragraphs.
  * Supports bullet lists.
  * Supports multi-paragraph list items and blockquotes.
  * Supports converting `[bash](man:bash(1))` and `[bash](man:bash.1)` links
    into man page references.
* Provides Rake task for converting `man/*.md` into man pages.
* Uses the pure-Ruby [Kramdown][kramdown] markdown parser.
* Supports [Ruby] 3.x, [JRuby], and [TruffleRuby].

## Synopsis

Render a man page from markdown:

```shell
kramdown-man <man/myprog.1.md >man/myprog.1
```

## Examples

Render a man page from a markdown file:

```ruby
require 'kramdown/man'

doc = Kramdown::Document.new(File.read('man/kramdown-man.1.md'))
File.write('man/kramdown-man.1',doc.to_man)

system 'man', 'man/kramdown-man.1'
```

Define a `man` and file tasks which render all `*.md` files within the
`man/` directory:

```ruby
require 'kramdown/man/task'
Kramdown::Man::Task.new
```

## Syntax

### Code

```markdown
`code`
```

`code`

### Emphasis

```markdown
*emphasis*
```

*emphasis*

### Strong

```markdown
**strong**
```

**strong**

### Paragraph

```markdown
Normal paragraph.
```

Normal paragraph.

#### Usage String

```markdown
`command` [`--foo`] **FILE**
```

`command` [`--foo`] **FILE**

#### Argument Definitions

```markdown
*ARG*
: Description here.
```

*ARG*
: Description here.

#### Option Definitions

```markdown
`-o`, `--option` *VALUE*
: Description here.
```

`-o`, `--option` *VALUE*
: Description here.

### Links

```markdown
[website](http://example.com/)
```

[website](http://example.com/)

#### Man Pages

Link to other man pages in a project:

```markdown
[kramdown-man](kramdown-man.md)
```

[kramdown-man](man/kramdown-man.md)

Link to other system man page:

```markdown
[bash](man:bash(1))
```

[bash](man:bash(1))

**Note:** only works on [firefox].

[firefox]: https://www.mozilla.org/en-US/firefox/new/

#### Email Addresses

```markdown
Email <bob@example.com>
```

Email <bob@example.com>

### Lists

```markdown
* one
* two
* three
```

* one
* two
* three

#### Numbered Lists

```markdown
1. one
2. two
3. three
```
    
1. one
2. two
3. three

#### Definition Lists

```mardkwon
ex·am·ple
: a thing characteristic of its kind or illustrating a general rule.

: a person or thing regarded in terms of their fitness to be imitated or the likelihood of their being imitated.
```

ex·am·ple
: a thing characteristic of its kind or illustrating a general rule.

: a person or thing regarded in terms of their fitness to be imitated or the likelihood of their being imitated.

### Blockquotes

```markdown
> Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
>
> --Antoine de Saint-Exupéry
```

> Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away.
>
> --Antoine de Saint-Exupéry

### Code Blocks

```markdown
Source code:

    #include <stdio.h>

    int main()
    {
        printf("hello world\n");
        return 0;
    }

```

Source code:

    #include <stdio.h>

    int main()
    {
	    printf("hello world\n");
	    return 0;
    }

## Requirements

* [kramdown] ~> 2.0

## Install

```shell
gem install kramdown-man
```

## Alternatives

* [Redcarpet::Render::ManPage](http://rubydoc.info/gems/redcarpet/Redcarpet/Render/ManPage)
* [ronn](https://github.com/rtomayko/ronn#readme)
* [md2man](https://github.com/sunaku/md2man#readme)

## Copyright

Copyright (c) 2013-2023 Hal Brodigan

See {file:LICENSE.txt} for details.

[kramdown]: http://kramdown.gettalong.org/
[roff]: http://en.wikipedia.org/wiki/Roff

[Ruby]: http://www.ruby-lang.org/
[JRuby]: http://jruby.org/
[TruffleRuby]: https://github.com/oracle/truffleruby#readme
