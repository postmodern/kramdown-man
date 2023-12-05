require 'spec_helper'
require 'kramdown/man/converter'

describe Kramdown::Man::Converter do
  let(:markdown) { File.read('man/kramdown-man.1.md') }
  let(:doc)      { Kramdown::Document.new(markdown) }
  let(:root)     { doc.root }

  subject { described_class.send(:new,root,{}) }

  describe "#convert" do
    let(:markdown) do
      <<~MARKDOWN
        # Header

        Hello world.
      MARKDOWN
    end

    let(:root) { doc.root }

    it "should add the header" do
      expect(subject.convert(root)).to eq(
        <<~ROFF
          #{described_class::HEADER.chomp}
          .TH Header
          .PP
          Hello world\\.
        ROFF
      )
    end
  end

  describe "#convert_root" do
    let(:markdown) do
      <<~MARKDOWN
        # Header

        Hello world.
      MARKDOWN
    end

    let(:root) { doc.root }

    it "should convert every element" do
      expect(subject.convert_root(root)).to eq(
        <<~ROFF
          .TH Header
          .PP
          Hello world\\.
        ROFF
      )
    end
  end

  describe "#convert_element" do
    let(:markdown) { "    puts 'hello'" }
    let(:el)       { doc.root.children[0] }

    it "should convert the element based on it's type" do
      expect(subject.convert_element(el)).to eq(subject.convert_codeblock(el))
    end
  end

  describe "#convert_blank" do
    let(:markdown) do
      <<~MARKDOWN
        foo

        bar
      MARKDOWN
    end

    let(:blank) { doc.root.children[0].children[1] }

    it "must return nil" do
      expect(subject.convert_blank(blank)).to be(nil)
    end
  end

  describe "#convert_text" do
    let(:content)  { 'Foo bar' }
    let(:markdown) { content }
    let(:text)     { doc.root.children[0].children[0] }

    it "should convert text elements" do
      expect(subject.convert_text(text)).to eq(content)
    end
  end

  describe "#convert_typographic_sym" do
    context "ndash" do
      let(:markdown) { "-- foo" }
      let(:sym)      { doc.root.children[0].children[0] }

      it "should convert ndash symbols back into '\-\-'" do
        expect(subject.convert_typographic_sym(sym)).to eq("\\-\\-")
      end
    end

    context "mdash" do
      let(:markdown) { "--- foo" }
      let(:sym)      { doc.root.children[0].children[0] }

      it "should convert mdash symbols into '\[em]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[em]')
      end
    end

    context "hellip" do
      let(:markdown) { "... foo" }
      let(:sym)      { doc.root.children[0].children[0] }

      it "should convert mdash symbols into '\\.\\.\\.'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\.\.\.')
      end
    end

    context "laquo" do
      let(:markdown) { "<< foo" }
      let(:sym)      { doc.root.children[0].children[0] }

      it "should convert mdash symbols into '\[Fo]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fo]')
      end
    end

    context "raquo" do
      let(:markdown) { "foo >> bar" }
      let(:sym)      { doc.root.children[0].children[1] }

      it "should convert mdash symbols into '\[Fc]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fc]')
      end
    end

    context "laquo_space" do
      let(:markdown) { " << foo" }
      let(:sym)      { doc.root.children[0].children[0] }

      it "should convert mdash symbols into '\[Fo]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fo]')
      end
    end

    context "raquo_space" do
      let(:markdown) { "foo  >> bar" }
      let(:sym)      { doc.root.children[0].children[1] }

      it "should convert mdash symbols into '\[Fc]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fc]')
      end
    end
  end

  describe "#convert_smart_quote" do
    context "lsquo" do
      let(:markdown) { "'hello world'" }
      let(:quote)    { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '\[oq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[oq]')
      end
    end

    context "rsquo" do
      let(:markdown)   { "'hello world'" }
      let(:quote)      { doc.root.children[0].children.last }

      it "should convert rsquo quotes into '\[cq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[cq]')
      end
    end

    context "ldquo" do
      let(:markdown) { '"hello world"' }
      let(:quote)    { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '\[lq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[lq]')
      end
    end

    context "rdquo" do
      let(:markdown) { '"hello world"' }
      let(:quote)    { doc.root.children[0].children.last }

      it "should convert lsquo quotes into '\[rq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[rq]')
      end
    end
  end

  describe "#convert_header" do
    let(:title) { 'Header' }

    context "when level is 1" do
      let(:markdown) { "# #{title}" }
      let(:header)   { doc.root.children[0] }

      it "should convert level 1 headers into '.TH text'" do
        expect(subject.convert_header(header)).to eq(
          <<~ROFF
            .TH #{title}
          ROFF
        )
      end
    end

    context "when level is 2" do
      let(:markdown) { "## #{title}" }
      let(:header)   { doc.root.children[0] }

      it "should convert level 2 headers into '.SH text'" do
        expect(subject.convert_header(header)).to eq(
          <<~ROFF
            .SH #{title}
          ROFF
        )
      end
    end

    context "when level is 3" do
      let(:markdown) { "### #{title}" }
      let(:header)   { doc.root.children[0] }

      it "should convert level 2 headers into '.SS text'" do
        expect(subject.convert_header(header)).to eq(
          <<~ROFF
            .SS #{title}
          ROFF
        )
      end
    end

    context "when level is 4 or greater" do
      let(:markdown) { "#### #{title}" }
      let(:header)   { doc.root.children[0] }

      it "should convert level 2 headers into '.SS text'" do
        expect(subject.convert_header(header)).to eq(
          <<~ROFF
            .SS #{title}
          ROFF
        )
      end
    end
  end

  describe "#convert_hr" do
    let(:markdown) { '------------------------------------' }
    let(:hr)       { doc.root.children[0] }

    it "must return nil" do
      expect(subject.convert_hr(hr)).to be(nil)
    end
  end

  describe "#convert_ul" do
    let(:text1) { 'foo' }
    let(:text2) { 'bar' }
    let(:markdown) do
      <<~MARKDOWN
        * #{text1}
        * #{text2}
      MARKDOWN
    end

    let(:ul) { doc.root.children[0] }

    it "should convert ul elements into '.RS\\n...\\n.RE\\n'" do
      expect(subject.convert_ul(ul)).to eq(
        <<~ROFF
          .RS
          .IP \\(bu 2
          #{text1}
          .IP \\(bu 2
          #{text2}
          .RE
        ROFF
      )
    end
  end

  describe "#convert_ul_li" do
    let(:text)     { 'hello world' }
    let(:markdown) { "* #{text}" }

    let(:li) { doc.root.children[0].children[0] }

    it "should convert the first p element to '.IP \\\\(bu 2\\n...'" do
      expect(subject.convert_ul_li(li)).to eq(
        <<~ROFF
          .IP \\(bu 2
          #{text}
        ROFF
      )
    end

    context "with multiple multiple paragraphs" do
      let(:text1) { 'hello' }
      let(:text2) { 'world' }
      let(:markdown) do
        <<~MARKDOWN
          * #{text1}

            #{text2}
        MARKDOWN
      end

      it "should convert the other p elements to '.IP \\\\( 2\\n...'" do
        expect(subject.convert_ul_li(li)).to eq(
          <<~ROFF
            .IP \\(bu 2
            #{text1}
            .IP \\( 2
            #{text2}
          ROFF
        )
      end
    end
  end

  describe "#convert_ol" do
    let(:text1) { 'foo' }
    let(:text2) { 'bar' }
    let(:markdown) do
      <<~MARKDOWN
        1. #{text1}
        2. #{text2}
      MARKDOWN
    end

    let(:ol) { doc.root.children[0] }

    it "should convert ol elements into '.RS\\n...\\n.RE'" do
      expect(subject.convert_ol(ol)).to eq(
        <<~ROFF
          .nr step1 0 1
          .RS
          .IP \\n+[step1]
          #{text1}
          .IP \\n+[step1]
          #{text2}
          .RE
        ROFF
      )
    end
  end

  describe "#convert_ol_li" do
    let(:text)     { 'hello world' }
    let(:markdown) { "1. #{text}" }

    let(:li) { doc.root.children[0].children[0] }

    it "should convert the first p element to '.IP \\\\n+[step0]\\n...'" do
      expect(subject.convert_ol_li(li)).to eq(
        <<~ROFF
          .IP \\n+[step0]
          #{text}
        ROFF
      )
    end

    context "with multiple multiple paragraphs" do
      let(:text1) { 'hello' }
      let(:text2) { 'world' }
      let(:markdown) do
        <<~MARKDOWN
          1. #{text1}

             #{text2}
        MARKDOWN
      end

      it "should convert the other p elements to '.IP \\\\n\\n...'" do
        expect(subject.convert_ol_li(li)).to eq(
          <<~ROFF
            .IP \\n+[step0]
            #{text1}
            .IP \\n
            #{text2}
          ROFF
        )
      end
    end
  end

  describe "#convert_dl" do
    let(:term)       { "foo bar" }
    let(:definition) { "baz qux" }
    let(:markdown) do
      <<~MARKDOWN
        #{term}
        : #{definition}
      MARKDOWN
    end

    let(:dl) { doc.root.children[0] }

    it "must convert dl elements into '.TP\n...\n...'" do
      expect(subject.convert_dl(dl)).to eq(
        <<~ROFF
          .TP
          #{term}
          #{definition}
        ROFF
      )
    end

    context "when there are multiple term lines" do
      let(:term1) { "foo" }
      let(:term2) { "bar" }
      let(:markdown) do
        <<~MARKDOWN
          #{term1}
          #{term2}
          : #{definition}
        MARKDOWN
      end

      it "must convert the multi-term dl element into '.TP\\nterm1\\n.TQ\\nterm2\\n...'" do
        expect(subject.convert_dl(dl)).to eq(
          <<~ROFF
            .TP
            #{term1}
            .TQ
            #{term2}
            #{definition}
          ROFF
        )
      end
    end

    context "when there are multiple definitions for a term" do
      let(:term)        { "foo" }
      let(:definition1) { "Foo bar." }
      let(:definition2) { "Baz qux." }
      let(:markdown) do
        <<~MARKDOWN
          #{term}
          : #{definition1}

          : #{definition2}
        MARKDOWN
      end

      let(:dl) { doc.root.children[0] }

      let(:escaped_definition1) { definition1.gsub('.',"\\.") }
      let(:escaped_definition2) { definition2.gsub('.',"\\.") }

      it "must convert the following p children into '.RS\\n.PP\\n...\\n.RE'" do
        expect(subject.convert_dl(dl)).to eq(
          <<~ROFF
              .TP
              #{term}
              #{escaped_definition1}
              .RS
              .PP
              #{escaped_definition2}
              .RE
          ROFF
        )
      end
    end
  end

  describe "#convert_dt" do
    let(:word1)      { "foo" }
    let(:word2)      { "bar" }
    let(:word3)      { "baz" }
    let(:term)       { "#{word1} `#{word2}` *#{word3}*" }
    let(:definition) { "abc xyz" }
    let(:markdown) do
      <<~MARKDOWN
        #{term}
        : #{definition}
      MARKDOWN
    end

    let(:dt) { doc.root.children[0].children[0] }

    it "must convert the dt element into '.TP\n...'" do
      expect(subject.convert_dt(dt)).to eq(
        <<~ROFF
          .TP
          #{word1} \\fB#{word2}\\fR \\fI#{word3}\\fP
        ROFF
      )
    end

    context "when given the index: keyword" do
      context "and it's greater than 1" do
        it "must convert the dt element into '.TQ\n...'" do
          expect(subject.convert_dt(dt, index: 1)).to eq(
            <<~ROFF
              .TQ
              #{word1} \\fB#{word2}\\fR \\fI#{word3}\\fP
            ROFF
          )
        end
      end
    end
  end

  describe "#convert_dd" do
    let(:term)       { "abc xyz" }
    let(:word1)      { "foo" }
    let(:word2)      { "bar" }
    let(:word3)      { "baz" }
    let(:definition) { "#{word1} `#{word2}` *#{word3}*" }
    let(:markdown) do
      <<~MARKDOWN
        #{term}
        : #{definition}
      MARKDOWN
    end

    let(:dd) { doc.root.children[0].children[1] }

    it "must convert the children p element within the dd element" do
      expect(subject.convert_dd(dd)).to eq(
        <<~ROFF
          #{word1} \\fB#{word2}\\fR \\fI#{word3}\\fP
        ROFF
      )
    end

    context "when the given index: is 0" do
      context "and when the dd element contains multiple p children" do
        let(:word4)       { "qux" }
        let(:definition1) { "#{word1} #{word2}" }
        let(:definition2) { "`#{word3}` *#{word4}*" }
        let(:markdown) do
          <<~MARKDOWN
            #{term}
            : #{definition1}

              #{definition2}
          MARKDOWN
        end

        it "must convert the following p children into '.RS\\n.PP\\n...\\n.RE'" do
          expect(subject.convert_dd(dd)).to eq(
            <<~ROFF
              #{word1} #{word2}
              .RS
              .PP
              \\fB#{word3}\\fR \\fI#{word4}\\fP
              .RE
            ROFF
          )
        end
      end
    end

    context "when the given index: is greater than 0" do
      let(:word4)       { "qux" }
      let(:definition1) { "#{word1} #{word2}" }
      let(:definition2) { "`#{word3}` *#{word4}*" }
      let(:markdown) do
        <<~MARKDOWN
          #{term}
          : #{definition1}

          : #{definition2}
        MARKDOWN
      end

      let(:dd) { doc.root.children[0].children[2] }

      it "must convert the child elements into '.RS\\n...\\n.RE'" do
        expect(subject.convert_dd(dd, index: 1)).to eq(
          <<~ROFF
            .RS
            .PP
            \\fB#{word3}\\fR \\fI#{word4}\\fP
            .RE
          ROFF
        )
      end
    end
  end

  describe "#convert_abbreviation" do
    let(:acronym)      { 'HTML' }
    let(:definition)   { 'Hyper Text Markup Language' }
    let(:markdown) do
      <<~MARKDOWN
        This is an #{acronym} example.

        *[#{acronym}]: #{definition}
      MARKDOWN
    end

    let(:abbreviation) { doc.root.children[0].children[1] }

    it "should convert abbreviation elements into their text" do
      expect(subject.convert_abbreviation(abbreviation)).to eq(acronym)
    end
  end

  describe "#convert_blockquote" do
    let(:text)         { "Some quote." }
    let(:markdown) do
      <<~MARKDOWN
        > #{text}
      MARKDOWN
    end
    let(:escaped_text) { 'Some quote\.' }
    let(:blockquote)   { doc.root.children[0] }

    it "should convert blockquote elements into '.RS\\n.PP\\ntext...\\n.RE'" do
      expect(subject.convert_blockquote(blockquote)).to eq(
        <<~ROFF
          .RS
          .PP
          #{escaped_text}
          .RE
        ROFF
      )
    end
  end

  describe "#convert_codeblock" do
    let(:code)         { "puts 'hello world'" }
    let(:escaped_code) { 'puts \(aqhello world\(aq' }
    let(:markdown) do
      "    #{code}"
    end

    let(:codeblock) { doc.root.children[0] }

    it "should convert codeblock elements into '.PP\\n.EX\\ntext...\\n.EE'" do
      expect(subject.convert_codeblock(codeblock)).to eq(
        <<~ROFF
          .PP
          .RS 4
          .EX
          #{escaped_code}
          .EE
          .RE
        ROFF
      )
    end
  end

  describe "#convert_comment" do
    let(:text)    { "Copyright (c) 2013" }
    let(:markdown) do
      <<~MARKDOWN
        {::comment}
        #{text}
        {:/comment}
      MARKDOWN
    end

    let(:comment) { doc.root.children[0] }

    it "should convert comment elements into '.\\\" text...'" do
      expect(subject.convert_comment(comment)).to eq(
        <<~ROFF
          .\\\" #{text}
        ROFF
      )
    end
  end

  describe "#convert_p" do
    let(:text)         { "Hello world." }
    let(:markdown)     { text }
    let(:escaped_text) { 'Hello world\.' }

    let(:p) { doc.root.children[0] }

    it "should convert p elements into '.PP\\ntext'" do
      expect(subject.convert_p(p)).to eq(
        <<~ROFF
          .PP
          #{escaped_text}
        ROFF
      )
    end
  end

  describe "#convert_em" do
    let(:text)     { "hello world" }
    let(:markdown) { "*#{text}*" }

    let(:em) { doc.root.children[0].children[0] }

    it "should convert em elements into '\\fItext\\fP'" do
      expect(subject.convert_em(em)).to eq("\\fI#{text}\\fP")
    end
  end

  describe "#convert_strong" do
    let(:text)     { "hello world" }
    let(:markdown) { "**#{text}**" }

    let(:strong) { doc.root.children[0].children[0] }

    it "should convert strong elements into '\\fBtext\\fP'" do
      expect(subject.convert_strong(strong)).to eq("\\fB#{text}\\fP")
    end
  end

  describe "#convert_codespan" do
    let(:code)         { "puts 'hello world'" }
    let(:escaped_code) { 'puts \(aqhello world\(aq' }
    let(:markdown)     { "`#{code}`" }

    let(:codespan) { doc.root.children[0].children[0] }

    it "should convert codespan elements into '\\fBcode\\fR'" do
      expect(subject.convert_codespan(codespan)).to eq("\\fB#{escaped_code}\\fR")
    end

    context "when given a ``` codespan" do
      let(:markdown) do
        <<~MARKDOWN
        ```
        #{code}
        ```
        MARKDOWN
      end

      it "must treat the codespan element as a codeblock" do
        expect(subject.convert_codespan(codespan)).to eq(
          <<~ROFF
            .PP
            .RS 4
            .EX
            #{escaped_code}
            .EE
            .RE
          ROFF
        )
      end
    end
  end

  describe "#convert_a" do
    let(:text)         { 'example'             }
    let(:href)         { 'http://example.com/' }
    let(:markdown)     { "[#{text}](#{href})"  }
    let(:escaped_href) { 'http:\[sl]\[sl]example\.com\[sl]' }

    let(:link) { doc.root.children[0].children[0] }

    it "should convert a link elements into 'text\\n.UR href\\n.UE'" do
      expect(subject.convert_a(link)).to eq(
        <<~ROFF
          #{text}
          .UR #{escaped_href}
          .UE
        ROFF
      )
    end

    context "when the href is to another .1.md file" do
      let(:man)      { 'foo-bar' }
      let(:section)  { '1' }
      let(:markdown) { "[#{man}](#{man}.#{section}.md)" }

      let(:escaped_man) { man.gsub('-','\\-') }

      it "should convert the link elements into '.BR page (section)'" do
        expect(subject.convert_a(link)).to eq(
          <<~ROFF
            .BR #{escaped_man} (#{section})
          ROFF
        )
      end
    end

    context "when the href begins with mailto:" do
      let(:text)     { 'Bob'             }
      let(:email)    { 'bob@example.com' }
      let(:markdown) { "[#{text}](mailto:#{email})" }

      let(:escaped_email) { 'bob\[at]example\.com' }

      it "should convert the link elements into '.MT email\\n.ME'" do
        expect(subject.convert_a(link)).to eq(
          <<~ROFF
            #{text}
            .MT #{escaped_email}
            .ME
          ROFF
        )
      end

      context "when link is <email>" do
        let(:markdown) { "<#{email}>" }

        it "should convert the link elements into '.MT email\\n.ME'" do
          expect(subject.convert_a(link)).to eq(
            <<~ROFF
              .MT #{escaped_email}
              .ME
            ROFF
          )
        end
      end
    end

    context "when the href begins with man:" do
      let(:man)      { 'bash' }
      let(:markdown) { "[#{man}](man:#{man})" }

      it "should convert the link elements into '.BR man'" do
        expect(subject.convert_a(link)).to eq(
          <<~ROFF
            .BR #{man}
          ROFF
        )
      end

      context "and when the path is of the form 'page(section)'" do
        let(:section)  { '1' }
        let(:markdown) { "[#{man}](man:#{man}(#{section}))" }

        it "should convert the link elements into '.BR page (section)'" do
          expect(subject.convert_a(link)).to eq(
            <<~ROFF
              .BR #{man} (#{section})
            ROFF
          )
        end
      end

      context "and when the path is of the form 'page.section'" do
        let(:section)  { '1' }
        let(:markdown) { "[#{man}](man:#{man}.#{section})" }

        it "should convert the link elements into '.BR page (section)'" do
          expect(subject.convert_a(link)).to eq(
            <<~ROFF
              .BR #{man} (#{section})
            ROFF
          )
        end
      end

      context "when the path ends with a file extension" do
        let(:file)         { 'shard.yml' }
        let(:escaped_file) { file.gsub('.','\\.') }
        let(:markdown)     { "[#{man}](man:#{file})" }

        it "should convert the link elements into '.BR file'" do
          expect(subject.convert_a(link)).to eq(
            <<~ROFF
              .BR #{escaped_file}
            ROFF
          )
        end
      end
    end
  end

  describe "#man_page_link" do
    let(:man) { 'foo-bar' }

    let(:escaped_man) { man.gsub('-','\\-') }

    it "should convert the link elements into '.BR man'" do
      expect(subject.man_page_link(man)).to eq(
        <<~ROFF
          .BR #{escaped_man}
        ROFF
      )
    end

    context "when a section argument is given" do
      let(:section) { '1' }

      it "should convert the link elements into '.BR page (section)'" do
        expect(subject.man_page_link(man,section)).to eq(
          <<~ROFF
            .BR #{escaped_man} (#{section})
          ROFF
        )
      end
    end
  end

  describe "#convert_children_of" do
    let(:markdown) do
      <<~MARKDOWN
        A paragraph

        * a list
      MARKDOWN
    end

    let(:element) { doc.root }

    it "must convert each element and join them into a String" do
      expect(subject.convert_children_of(element)).to eq(
        [
          subject.convert_element(element.children[0]),
          subject.convert_element(element.children[2])
        ].join
      )
    end

    context "when the given elements contains an element that cannot be converted" do
      let(:markdown) do
        <<~MARKDOWN
          A paragraph

          ----------------------------------------------------------------------

          * a list
        MARKDOWN
      end

      it "must omit the non-convertable elements" do
        expect(subject.convert_children_of(element)).to eq(
          [
            subject.convert_element(element.children[0]),
            subject.convert_element(element.children[4])
          ].join
        )
      end
    end
  end

  describe "#convert_text_elements" do
    let(:markdown) do
      <<~MARKDOWN
        Word *emphasis* **strong** `code`
      MARKDOWN
    end
    let(:elements) { doc.root.children[0].children }

    it "must convert each text element and join the results together" do
      expect(subject.convert_text_elements(elements)).to eq(
        [
          subject.convert_element(elements[0]),
          subject.convert_element(elements[1]),
          subject.convert_element(elements[2]),
          subject.convert_element(elements[3]),
          subject.convert_element(elements[4]),
          subject.convert_element(elements[5])
        ].join
      )
    end

    context "when the text elements contain a 'a' type element" do
      let(:markdown) do
        <<~MARKDOWN
          Word1 [link](https://example.com) word2.
        MARKDOWN
      end

      it "must remove leading spaces from each line" do
        expect(subject.convert_text_elements(elements)).to_not match(/^ /)
      end
    end

    context "when the text elements contain consecutive 'a' elements" do
      let(:markdown) do
        <<~MARKDOWN
          [link1](link1.html) [link2](link2.html) [link3](link3.html)
        MARKDOWN
      end

      it "must avoid adding duplicate newlines" do
        expect(subject.convert_text_elements(elements)).to eq(
          [
            subject.convert_element(elements[0]),
            subject.convert_element(elements[2]),
            subject.convert_element(elements[4]),
          ].join
        )
      end
    end
  end

  describe "#escape" do
    let(:text) { "hello\nworld" }

    described_class::GLYPHS.each do |char,glyph|
      it "should convert #{char.dump} into #{glyph.dump}" do
        expect(subject.escape("#{text} #{char}")).to eq("#{text} #{glyph}")
      end
    end
  end
end
