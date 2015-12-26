# encoding: utf-8
require 'spec_helper'
require 'kramdown/converter/man'

describe Kramdown::Converter::Man do
  let(:markdown) { File.read('man/kramdown-man.1.md') }
  let(:doc)      { Kramdown::Document.new(markdown) }
  let(:root)     { doc.root }

  subject { described_class.send(:new,root,{}) }

  describe "#convert" do
    let(:doc) do
      Kramdown::Document.new(%{
# Header

Hello world.
      }.strip)
    end
    let(:root) { doc.root }

    it "should add the header" do
      expect(subject.convert(root)).to eq([
        described_class::HEADER,
        ".TH Header",
        ".LP",
        ".PP",
        'Hello world\.'
      ].join("\n"))
    end
  end

  describe "#convert_root" do
    let(:doc) do
      Kramdown::Document.new(%{
# Header

Hello world.
      }.strip)
    end

    let(:root) { doc.root }

    it "should convert every element" do
      expect(subject.convert_root(root)).to eq([
        ".TH Header",
        ".LP",
        ".PP",
        'Hello world\.'
      ].join("\n"))
    end
  end

  describe "#convert_element" do
    let(:doc) { Kramdown::Document.new("    puts 'hello'") }
    let(:el)  { doc.root.children[0] }

    it "should convert the element based on it's type" do
      expect(subject.convert_element(el)).to eq(subject.convert_codeblock(el))
    end
  end

  describe "#convert_blank" do
    let(:doc)   { Kramdown::Document.new("foo\n\nbar") }
    let(:blank) { doc.root.children[0].children[1] }

    it "should convert blank elements to '.LP'" do
      expect(subject.convert_blank(blank)).to eq('.LP')
    end
  end

  describe "#convert_text" do
    let(:content) { 'Foo bar'                        }
    let(:doc)     { Kramdown::Document.new(content)  }
    let(:text)    { doc.root.children[0].children[0] }

    it "should convert text elements" do
      expect(subject.convert_text(text)).to eq(content)
    end

    context "when the text has two-space indentation" do
      let(:content) { "Foo\n  bar\n  baz" }

      it "should strip leading whitespace from each line" do
        expect(subject.convert_text(text)).to eq(content.gsub("\n  ","\n"))
      end
    end

    context "when the text has tab indentation" do
      let(:content) { "Foo\n\tbar\n\tbaz" }

      it "should strip leading whitespace from each line" do
        expect(subject.convert_text(text)).to eq(content.gsub("\n\t","\n"))
      end
    end
  end

  describe "#convert_typographic_sym" do
    context "ndash" do
      let(:doc) { Kramdown::Document.new("-- foo")     }
      let(:sym) { doc.root.children[0].children[0] }

      it "should convert ndash symbols back into '\-\-'" do
        expect(subject.convert_typographic_sym(sym)).to eq("\\-\\-")
      end
    end

    context "mdash" do
      let(:doc) { Kramdown::Document.new("--- foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '\[em]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[em]')
      end
    end

    context "hellip" do
      let(:doc) { Kramdown::Document.new("... foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '\\.\\.\\.'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\.\.\.')
      end
    end

    context "laquo" do
      let(:doc) { Kramdown::Document.new("<< foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '\[Fo]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fo]')
      end
    end

    context "raquo" do
      let(:doc) { Kramdown::Document.new("foo >> bar") }
      let(:sym) { doc.root.children[0].children[1]  }

      it "should convert mdash symbols into '\[Fc]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fc]')
      end
    end

    context "laquo_space" do
      let(:doc) { Kramdown::Document.new(" << foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '\[Fo]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fo]')
      end
    end

    context "raquo_space" do
      let(:doc) { Kramdown::Document.new("foo  >> bar") }
      let(:sym) { doc.root.children[0].children[1]  }

      it "should convert mdash symbols into '\[Fc]'" do
        expect(subject.convert_typographic_sym(sym)).to eq('\[Fc]')
      end
    end
  end

  describe "#convert_smart_quote" do
    context "lsquo" do
      let(:doc)   { Kramdown::Document.new("'hello world'") }
      let(:quote) { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '\[oq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[oq]')
      end
    end

    context "rsquo" do
      let(:doc)   { Kramdown::Document.new("'hello world'") }
      let(:quote) { doc.root.children[0].children.last }

      it "should convert rsquo quotes into '\[cq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[cq]')
      end
    end

    context "ldquo" do
      let(:doc)   { Kramdown::Document.new('"hello world"') }
      let(:quote) { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '\[lq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[lq]')
      end
    end

    context "rdquo" do
      let(:doc)   { Kramdown::Document.new('"hello world"') }
      let(:quote) { doc.root.children[0].children.last }

      it "should convert lsquo quotes into '\[rq]'" do
        expect(subject.convert_smart_quote(quote)).to eq('\[rq]')
      end
    end
  end

  describe "#convert_header" do
    context "when level is 1" do
      let(:doc)    { Kramdown::Document.new("# Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 1 headers into '.TH text'" do
        expect(subject.convert_header(header)).to eq(".TH Header")
      end
    end

    context "when level is 2" do
      let(:doc)    { Kramdown::Document.new("## Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 2 headers into '.SH text'" do
        expect(subject.convert_header(header)).to eq(".SH Header")
      end
    end

    context "when level is 3" do
      let(:doc)    { Kramdown::Document.new("### Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 2 headers into '.SS text'" do
        expect(subject.convert_header(header)).to eq(".SS Header")
      end
    end

    context "when level is 4 or greater" do
      let(:doc)    { Kramdown::Document.new("#### Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 2 headers into '.SS text'" do
        expect(subject.convert_header(header)).to eq(".SS Header")
      end
    end
  end

  describe "#convert_hr" do
    let(:doc) { Kramdown::Document.new('------------------------------------') }
    let(:hr)  { doc.root.children[0] }

    it "should convert hr elements into '.ti 0\\n\\\\l'\\\\n(.lu\\''" do
      expect(subject.convert_hr(hr)).to eq(".ti 0\n\\l'\\n(.lu'")
    end
  end

  describe "#convert_ul" do
    let(:text1) { 'foo' }
    let(:text2) { 'bar' }
    let(:doc)   { Kramdown::Document.new("* #{text1}\n* #{text2}") }
    let(:ul)    { doc.root.children[0] }

    it "should convert ul elements into '.RS\\n...\\n.RE'" do
      expect(subject.convert_ul(ul)).to eq([
        ".RS",
        ".IP \\(bu 2",
        text1,
        ".IP \\(bu 2",
        text2,
        ".RE"
      ].join("\n"))
    end
  end

  describe "#convert_ul_li" do
    let(:text) { 'hello world'                       }
    let(:doc)  { Kramdown::Document.new("* #{text}") }
    let(:li)   { doc.root.children[0].children[0]    }

    it "should convert the first p element to '.IP \\\\(bu 2\\n...'" do
      expect(subject.convert_ul_li(li)).to eq(".IP \\(bu 2\n#{text}")
    end

    context "with multiple multiple paragraphs" do
      let(:text1) { 'hello' }
      let(:text2) { 'world' }
      let(:doc)   { Kramdown::Document.new("* #{text1}\n\n  #{text2}") }

      it "should convert the other p elements to '.IP \\\\( 2\\n...'" do
        expect(subject.convert_ul_li(li)).to eq([
          ".IP \\(bu 2",
          text1,
          ".IP \\( 2",
          text2
        ].join("\n"))
      end
    end
  end

  describe "#convert_ol" do
    let(:text1) { 'foo' }
    let(:text2) { 'bar' }
    let(:doc)   { Kramdown::Document.new("1. #{text1}\n2. #{text2}") }
    let(:ol)    { doc.root.children[0] }

    it "should convert ol elements into '.RS\\n...\\n.RE'" do
      expect(subject.convert_ol(ol)).to eq([
        ".nr step1 0 1",
        ".RS",
        ".IP \\n+[step1]",
        text1,
        ".IP \\n+[step1]",
        text2,
        ".RE"
      ].join("\n"))
    end
  end

  describe "#convert_ol_li" do
    let(:text) { 'hello world'                        }
    let(:doc)  { Kramdown::Document.new("1. #{text}") }
    let(:li)   { doc.root.children[0].children[0]     }

    it "should convert the first p element to '.IP \\\\n+[step0]\\n...'" do
      expect(subject.convert_ol_li(li)).to eq(".IP \\n+[step0]\n#{text}")
    end

    context "with multiple multiple paragraphs" do
      let(:text1) { 'hello' }
      let(:text2) { 'world' }
      let(:doc)   { Kramdown::Document.new("1. #{text1}\n\n   #{text2}") }

      it "should convert the other p elements to '.IP \\\\n\\n...'" do
        expect(subject.convert_ol_li(li)).to eq([
          ".IP \\n+[step0]",
          text1,
          ".IP \\n",
          text2
        ].join("\n"))
      end
    end
  end

  describe "#convert_abbreviation" do
    let(:acronym)      { 'HTML' }
    let(:definition)   { 'Hyper Text Markup Language' }
    let(:doc)          { Kramdown::Document.new("This is an #{acronym} example.\n\n*[#{acronym}]: #{definition}") }
    let(:abbreviation) { doc.root.children[0].children[1] }

    it "should convert abbreviation elements into their text" do
      expect(subject.convert_abbreviation(abbreviation)).to eq(acronym)
    end
  end

  describe "#convert_blockquote" do
    let(:text)         { "Some quote." }
    let(:escaped_text) { 'Some quote\.' }
    let(:doc)          { Kramdown::Document.new("> #{text}") }
    let(:blockquote)   { doc.root.children[0] }

    it "should convert blockquote elements into '.PP\\n.RS\\ntext...\\n.RE'" do
      expect(subject.convert_blockquote(blockquote)).to eq(".PP\n.RS\n#{escaped_text}\n.RE")
    end
  end

  describe "#convert_codeblock" do
    let(:code)         { "puts 'hello world'" }
    let(:escaped_code) { 'puts \(aqhello world\(aq' }
    let(:doc)          { Kramdown::Document.new("    #{code}\n") }
    let(:codeblock)    { doc.root.children[0] }

    it "should convert codeblock elements into '.nf\\ntext...\\n.fi'" do
      expect(subject.convert_codeblock(codeblock)).to eq(".nf\n#{escaped_code}\n.fi")
    end
  end

  describe "#convert_comment" do
    let(:text)    { "Copyright (c) 2013" }
    let(:doc)     { Kramdown::Document.new("{::comment}\n#{text}\n{:/comment}") }
    let(:comment) { doc.root.children[0] }

    it "should convert comment elements into '.\\\" text...'" do
      expect(subject.convert_comment(comment)).to eq(".\\\" #{text}")
    end
  end

  describe "#convert_p" do
    let(:text)         { "Hello world." }
    let(:escaped_text) { 'Hello world\.' }
    let(:doc)          { Kramdown::Document.new(text) }
    let(:p)            { doc.root.children[0] }

    it "should convert p elements into '.PP\\ntext'" do
      expect(subject.convert_p(p)).to eq(".PP\n#{escaped_text}")
    end

    context "when the paragraph starts with a codespan element" do
      let(:option) { '--foo' }
      let(:text)   { 'Foo bar baz' }
      let(:doc)    { Kramdown::Document.new("`#{option}`\n\t#{text}") }

      it "should convert p elements into '.TP\\n\\fB--option\\fR\\ntext...'" do
        expect(subject.convert_p(p)).to eq(".TP\n\\fB#{option}\\fR\n#{text}")
      end

      context "when there is only one codespan element" do
        let(:code) { 'code' }
        let(:doc)  { Kramdown::Document.new("`#{code}`") }

        it "should convert p elements into '.PP\\n\\fB...\\fR'" do
          expect(subject.convert_p(p)).to eq(".PP\n\\fB#{code}\\fR")
        end
      end

      context "when there are more than one codespan element" do
        let(:flag)   { '-f'    }
        let(:option) { '--foo' }
        let(:text)   { 'Foo bar baz' }
        let(:doc)    { Kramdown::Document.new("`#{flag}`, `#{option}`\n\t#{text}") }

        it "should convert p elements into '.TP\\n\\fB-o\\fR, \\fB--option\\fR\\ntext...'" do
          expect(subject.convert_p(p)).to eq(".TP\n\\fB#{flag}\\fR, \\fB#{option}\\fR\n#{text}")
        end

        context "when there is no newline" do
          let(:doc) { Kramdown::Document.new("`#{flag}` `#{option}`") }

          it "should convert the p element into a '.HP\\n...'" do
            expect(subject.convert_p(p)).to eq(".HP\n\\fB#{flag}\\fR \\fB#{option}\\fR")
          end
        end
      end
    end

    context "when the paragraph starts with a em element" do
      let(:option)         { '--foo'       }
      let(:escaped_option) { "\\-\\-foo"   }
      let(:text)           { 'Foo bar baz' }

      let(:doc) do
        Kramdown::Document.new("*#{option}*\n\t#{text}")
      end

      it "should convert p elements into '.TP\\n\\fI--option\\fP\\ntext...'" do
        expect(subject.convert_p(p)).to eq(".TP\n\\fI#{escaped_option}\\fP\n#{text}")
      end

      context "when there is only one em element" do
        let(:text)   { 'foo' }
        let(:doc)    { Kramdown::Document.new("*#{text}*") }

        it "should convert p elements into '.PP\\n\\fI...\\fP'" do
          expect(subject.convert_p(p)).to eq(".PP\n\\fI#{text}\\fP")
        end
      end

      context "when there are more than one em element" do
        let(:flag)           { '-f'          }
        let(:escaped_flag)   { "\\-f"        }
        let(:text)           { 'Foo bar baz' }

        let(:doc) do
          Kramdown::Document.new("*#{flag}*, *#{option}*\n\t#{text}")
        end

        it "should convert p elements into '.TP\\n\\fI-o\\fP, \\fI\\-\\-option\\fP\\ntext...'" do
          expect(subject.convert_p(p)).to eq(".TP\n\\fI#{escaped_flag}\\fP, \\fI#{escaped_option}\\fP\n#{text}")
        end

        context "when there is no newline" do
          let(:doc) { Kramdown::Document.new("*#{flag}* *#{option}*") }

          it "should convert the p element into a '.HP\\n...'" do
            expect(subject.convert_p(p)).to eq(".HP\n\\fI#{escaped_flag}\\fP \\fI#{escaped_option}\\fP")
          end
        end
      end
    end
  end

  describe "#convert_em" do
    let(:text) { "hello world" }
    let(:doc)  { Kramdown::Document.new("*#{text}*") }
    let(:em)   { doc.root.children[0].children[0] }

    it "should convert em elements into '\\fItext\\fP'" do
      expect(subject.convert_em(em)).to eq("\\fI#{text}\\fP")
    end
  end

  describe "#convert_strong" do
    let(:text)   { "hello world" }
    let(:doc)    { Kramdown::Document.new("**#{text}**") }
    let(:strong) { doc.root.children[0].children[0] }

    it "should convert strong elements into '\\fBtext\\fP'" do
      expect(subject.convert_strong(strong)).to eq("\\fB#{text}\\fP")
    end
  end

  describe "#convert_codespan" do
    let(:code)     { "puts 'hello world'" }
    let(:doc)      { Kramdown::Document.new("`#{code}`") }
    let(:codespan) { doc.root.children[0].children[0] }

    it "should convert codespan elements into '\\fBcode\\fR'" do
      expect(subject.convert_codespan(codespan)).to eq("\\fB#{code}\\fR")
    end
  end

  describe "#convert_a" do
    let(:text)         { 'example'             }
    let(:href)         { 'http://example.com/' }
    let(:escaped_href) { 'http:\[sl]\[sl]example\.com\[sl]' }
    let(:doc)          { Kramdown::Document.new("[#{text}](#{href})") }
    let(:link)         { doc.root.children[0].children[0] }

    it "should convert a link elements into 'text\\n.UR href\\n.UE'" do
      expect(subject.convert_a(link)).to eq("#{text}\n.UR #{escaped_href}\n.UE")
    end

    context "when the href begins with mailto:" do
      let(:text)          { 'Bob'             }
      let(:email)         { 'bob@example.com' }
      let(:escaped_email) { 'bob\[at]example\.com' }
      let(:doc)           { Kramdown::Document.new("[#{text}](mailto:#{email})") }

      it "should convert the link elements into '.MT email\\n.ME'" do
        expect(subject.convert_a(link)).to eq("#{text}\n.MT #{escaped_email}\n.ME")
      end

      context "when link is <email>" do
        let(:doc) { Kramdown::Document.new("<#{email}>") }

        it "should convert the link elements into '.MT email\\n.ME'" do
          expect(subject.convert_a(link)).to eq("\n.MT #{escaped_email}\n.ME")
        end
      end
    end

    context "when the href begins with man:" do
      let(:man)  { 'bash' }
      let(:doc)  { Kramdown::Document.new("[#{man}](man:#{man})") }

      it "should convert the link elements into '.BR man'" do
        expect(subject.convert_a(link)).to eq("\n.BR #{man}")
      end

      context "when a section number is specified" do
        let(:section) { '1' }
        let(:doc)     { Kramdown::Document.new("[#{man}](man:#{man}(#{section}))") }

        it "should convert the link elements into '.BR man (section)'" do
          expect(subject.convert_a(link)).to eq("\n.BR #{man} (#{section})")
        end
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
