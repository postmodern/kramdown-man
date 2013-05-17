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
      subject.convert(root).should == [
        described_class::HEADER,
        ".TH Header",
        ".LP",
        ".PP",
        'Hello world\.'
      ].join("\n")
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
      subject.convert_root(root).should == [
        ".TH Header",
        ".LP",
        ".PP",
        'Hello world\.'
      ].join("\n")
    end
  end

  describe "#convert_element" do
    let(:doc) { Kramdown::Document.new("    puts 'hello'") }
    let(:el)  { doc.root.children[0] }

    it "should convert the element based on it's type" do
      subject.convert_element(el).should == subject.convert_codeblock(el)
    end
  end

  describe "#convert_blank" do
    let(:doc)   { Kramdown::Document.new("foo\n\nbar") }
    let(:blank) { doc.root.children[0].children[1] }

    it "should convert blank elements to '.LP'" do
      subject.convert_blank(blank).should == '.LP'
    end
  end

  describe "#convert_text" do
    let(:content) { 'Foo bar'                        }
    let(:doc)     { Kramdown::Document.new(content)  }
    let(:text)    { doc.root.children[0].children[0] }

    it "should convert text elements" do
      subject.convert_text(text).should == content
    end

    context "when the text has two-space indentation" do
      let(:content) { "Foo\n  bar\n  baz" }

      it "should strip leading whitespace from each line" do
        subject.convert_text(text).should == content.gsub("\n  ","\n")
      end
    end

    context "when the text has tab indentation" do
      let(:content) { "Foo\n\tbar\n\tbaz" }

      it "should strip leading whitespace from each line" do
        subject.convert_text(text).should == content.gsub("\n\t","\n")
      end
    end
  end

  describe "#convert_typographic_sym" do
    context "ndash" do
      let(:doc) { Kramdown::Document.new("-- foo")     }
      let(:sym) { doc.root.children[0].children[0] }

      it "should convert ndash symbols back into '\-\-'" do
        subject.convert_typographic_sym(sym).should == "\\-\\-"
      end
    end

    context "mdash" do
      let(:doc) { Kramdown::Document.new("--- foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '\[em]'" do
        subject.convert_typographic_sym(sym).should == '\[em]'
      end
    end

    context "hellip" do
      let(:doc) { Kramdown::Document.new("... foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '…'" do
        subject.convert_typographic_sym(sym).should == '…'
      end
    end

    context "laquo" do
      let(:doc) { Kramdown::Document.new("<< foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '\[Fo]'" do
        subject.convert_typographic_sym(sym).should == '\[Fo]'
      end
    end

    context "raquo" do
      let(:doc) { Kramdown::Document.new("foo >> bar") }
      let(:sym) { doc.root.children[0].children[1]  }

      it "should convert mdash symbols into '\[Fc]'" do
        subject.convert_typographic_sym(sym).should == '\[Fc]'
      end
    end

    context "laquo_space" do
      let(:doc) { Kramdown::Document.new(" << foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '\[Fo]'" do
        subject.convert_typographic_sym(sym).should == '\[Fo]'
      end
    end

    context "raquo_space" do
      let(:doc) { Kramdown::Document.new("foo  >> bar") }
      let(:sym) { doc.root.children[0].children[1]  }

      it "should convert mdash symbols into '\[Fc]'" do
        subject.convert_typographic_sym(sym).should == '\[Fc]'
      end
    end
  end

  describe "#convert_smart_quote" do
    context "lsquo" do
      let(:doc)   { Kramdown::Document.new("'hello world'") }
      let(:quote) { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '\[oq]'" do
        subject.convert_smart_quote(quote).should == '\[oq]'
      end
    end

    context "rsquo" do
      let(:doc)   { Kramdown::Document.new("'hello world'") }
      let(:quote) { doc.root.children[0].children.last }

      it "should convert rsquo quotes into '\[cq]'" do
        subject.convert_smart_quote(quote).should == '\[cq]'
      end
    end

    context "ldquo" do
      let(:doc)   { Kramdown::Document.new('"hello world"') }
      let(:quote) { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '\[lq]'" do
        subject.convert_smart_quote(quote).should == '\[lq]'
      end
    end

    context "rdquo" do
      let(:doc)   { Kramdown::Document.new('"hello world"') }
      let(:quote) { doc.root.children[0].children.last }

      it "should convert lsquo quotes into '\[rq]'" do
        subject.convert_smart_quote(quote).should == '\[rq]'
      end
    end
  end

  describe "#convert_header" do
    context "when level is 1" do
      let(:doc)    { Kramdown::Document.new("# Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 1 headers into '.TH text'" do
        subject.convert_header(header).should == ".TH Header"
      end
    end

    context "when level is 2" do
      let(:doc)    { Kramdown::Document.new("## Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 2 headers into '.SH text'" do
        subject.convert_header(header).should == ".SH Header"
      end
    end

    context "when level is 3" do
      let(:doc)    { Kramdown::Document.new("### Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 2 headers into '.SS text'" do
        subject.convert_header(header).should == ".SS Header"
      end
    end

    context "when level is 4 or greater" do
      let(:doc)    { Kramdown::Document.new("#### Header") }
      let(:header) { doc.root.children[0] }

      it "should convert level 2 headers into '.SS text'" do
        subject.convert_header(header).should == ".SS Header"
      end
    end
  end

  describe "#convert_hr" do
    let(:doc) { Kramdown::Document.new('------------------------------------') }
    let(:hr)  { doc.root.children[0] }

    it "should convert hr elements into '.ti 0\\n\\\\l'\\\\n(.lu\\''" do
      subject.convert_hr(hr).should == ".ti 0\n\\l'\\n(.lu'"
    end
  end

  describe "#convert_ul" do
    let(:text1) { 'foo' }
    let(:text2) { 'bar' }
    let(:doc)   { Kramdown::Document.new("* #{text1}\n* #{text2}") }
    let(:ul)    { doc.root.children[0] }

    it "should convert ul elements into '.RS\\n...\\n.RE'" do
      subject.convert_ul(ul).should == [
        ".RS",
        ".IP \\(bu 2",
        text1,
        ".IP \\(bu 2",
        text2,
        ".RE"
      ].join("\n")
    end
  end

  describe "#convert_ul_li" do
    let(:text) { 'hello world'                       }
    let(:doc)  { Kramdown::Document.new("* #{text}") }
    let(:li)   { doc.root.children[0].children[0]    }

    it "should convert the first p element to '.IP \\\\(bu 2\\n...'" do
      subject.convert_ul_li(li).should == ".IP \\(bu 2\n#{text}"
    end

    context "with multiple multiple paragraphs" do
      let(:text1) { 'hello' }
      let(:text2) { 'world' }
      let(:doc)   { Kramdown::Document.new("* #{text1}\n\n  #{text2}") }

      it "should convert the other p elements to '.IP \\\\( 2\\n...'" do
        subject.convert_ul_li(li).should == [
          ".IP \\(bu 2",
          text1,
          ".IP \\( 2",
          text2
        ].join("\n")
      end
    end
  end

  describe "#convert_ol" do
    let(:text1) { 'foo' }
    let(:text2) { 'bar' }
    let(:doc)   { Kramdown::Document.new("1. #{text1}\n2. #{text2}") }
    let(:ol)    { doc.root.children[0] }

    it "should convert ol elements into '.RS\\n...\\n.RE'" do
      subject.convert_ol(ol).should == [
        ".nr step1 0 1",
        ".RS",
        ".IP \\n+[step1]",
        text1,
        ".IP \\n+[step1]",
        text2,
        ".RE"
      ].join("\n")
    end
  end

  describe "#convert_ol_li" do
    let(:text) { 'hello world'                        }
    let(:doc)  { Kramdown::Document.new("1. #{text}") }
    let(:li)   { doc.root.children[0].children[0]     }

    it "should convert the first p element to '.IP \\\\n+[step0]\\n...'" do
      subject.convert_ol_li(li).should == ".IP \\n+[step0]\n#{text}"
    end

    context "with multiple multiple paragraphs" do
      let(:text1) { 'hello' }
      let(:text2) { 'world' }
      let(:doc)   { Kramdown::Document.new("1. #{text1}\n\n   #{text2}") }

      it "should convert the other p elements to '.IP \\\\n\\n...'" do
        subject.convert_ol_li(li).should == [
          ".IP \\n+[step0]",
          text1,
          ".IP \\n",
          text2
        ].join("\n")
      end
    end
  end

  describe "#convert_abbreviation" do
    let(:acronym)      { 'HTML' }
    let(:definition)   { 'Hyper Text Markup Language' }
    let(:doc)          { Kramdown::Document.new("This is an #{acronym} example.\n\n*[#{acronym}]: #{definition}") }
    let(:abbreviation) { doc.root.children[0].children[1] }

    it "should convert abbreviation elements into their text" do
      subject.convert_abbreviation(abbreviation).should == acronym
    end
  end

  describe "#convert_blockquote" do
    let(:text)         { "Some quote." }
    let(:escaped_text) { 'Some quote\.' }
    let(:doc)          { Kramdown::Document.new("> #{text}") }
    let(:blockquote)   { doc.root.children[0] }

    it "should convert blockquote elements into '.PP\\n.RS\\ntext...\\n.RE'" do
      subject.convert_blockquote(blockquote).should == ".PP\n.RS\n#{escaped_text}\n.RE"
    end
  end

  describe "#convert_codeblock" do
    let(:code)         { "puts 'hello world'" }
    let(:escaped_code) { 'puts \(aqhello world\(aq' }
    let(:doc)          { Kramdown::Document.new("    #{code}\n") }
    let(:codeblock)    { doc.root.children[0] }

    it "should convert codeblock elements into '.nf\\ntext...\\n.fi'" do
      subject.convert_codeblock(codeblock).should == ".nf\n#{escaped_code}\n.fi"
    end
  end

  describe "#convert_comment" do
    let(:text)    { "Copyright (c) 2013" }
    let(:doc)     { Kramdown::Document.new("{::comment}\n#{text}\n{:/comment}") }
    let(:comment) { doc.root.children[0] }

    it "should convert comment elements into '.\\\" text...'" do
      subject.convert_comment(comment).should == ".\\\" #{text}"
    end
  end

  describe "#convert_p" do
    let(:text)         { "Hello world." }
    let(:escaped_text) { 'Hello world\.' }
    let(:doc)          { Kramdown::Document.new(text) }
    let(:p)            { doc.root.children[0] }

    it "should convert p elements into '.PP\\ntext'" do
      subject.convert_p(p).should == ".PP\n#{escaped_text}"
    end

    context "when the paragraph starts with a codespan element" do
      let(:option) { '--foo' }
      let(:text)   { 'Foo bar baz' }
      let(:doc)    { Kramdown::Document.new("`#{option}`\n\t#{text}") }

      it "should convert p elements into '.TP\\n\\fB--option\\fR\\ntext...'" do
        subject.convert_p(p).should == ".TP\n\\fB#{option}\\fR\n#{text}"
      end

      context "when there is only one codespan element" do
        let(:code) { 'code' }
        let(:doc)  { Kramdown::Document.new("`#{code}`") }

        it "should convert p elements into '.PP\\n\\fB...\\fR'" do
          subject.convert_p(p).should == ".PP\n\\fB#{code}\\fR"
        end
      end

      context "when there are more than one codespan element" do
        let(:flag)   { '-f'    }
        let(:option) { '--foo' }
        let(:text)   { 'Foo bar baz' }
        let(:doc)    { Kramdown::Document.new("`#{flag}`, `#{option}`\n\t#{text}") }

        it "should convert p elements into '.TP\\n\\fB-o\\fR, \\fB--option\\fR\\ntext...'" do
          subject.convert_p(p).should == ".TP\n\\fB#{flag}\\fR, \\fB#{option}\\fR\n#{text}"
        end

        context "when there is no newline" do
          let(:doc) { Kramdown::Document.new("`#{flag}` `#{option}`") }

          it "should convert the p element into a '.HP\\n...'" do
            subject.convert_p(p).should == ".HP\n\\fB#{flag}\\fR \\fB#{option}\\fR"
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
        subject.convert_p(p).should == ".TP\n\\fI#{escaped_option}\\fP\n#{text}"
      end

      context "when there is only one em element" do
        let(:text)   { 'foo' }
        let(:doc)    { Kramdown::Document.new("*#{text}*") }

        it "should convert p elements into '.PP\\n\\fI...\\fP'" do
          subject.convert_p(p).should == ".PP\n\\fI#{text}\\fP"
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
          subject.convert_p(p).should == ".TP\n\\fI#{escaped_flag}\\fP, \\fI#{escaped_option}\\fP\n#{text}"
        end

        context "when there is no newline" do
          let(:doc) { Kramdown::Document.new("*#{flag}* *#{option}*") }

          it "should convert the p element into a '.HP\\n...'" do
            subject.convert_p(p).should == ".HP\n\\fI#{escaped_flag}\\fP \\fI#{escaped_option}\\fP"
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
      subject.convert_em(em).should == "\\fI#{text}\\fP"
    end
  end

  describe "#convert_strong" do
    let(:text)   { "hello world" }
    let(:doc)    { Kramdown::Document.new("**#{text}**") }
    let(:strong) { doc.root.children[0].children[0] }

    it "should convert strong elements into '\\fBtext\\fP'" do
      subject.convert_strong(strong).should == "\\fB#{text}\\fP"
    end
  end

  describe "#convert_codespan" do
    let(:code)     { "puts 'hello world'" }
    let(:doc)      { Kramdown::Document.new("`#{code}`") }
    let(:codespan) { doc.root.children[0].children[0] }

    it "should convert codespan elements into '\\fBcode\\fR'" do
      subject.convert_codespan(codespan).should == "\\fB#{code}\\fR"
    end
  end

  describe "#convert_a" do
    let(:text) { 'example'             }
    let(:href) { 'http://example.com/' }
    let(:doc)  { Kramdown::Document.new("[#{text}](#{href})") }
    let(:link) { doc.root.children[0].children[0] }

    it "should convert a link elements into 'text\\n.UR href\\n.UE'" do
      subject.convert_a(link).should == "#{text}\n.UR #{href}\n.UE"
    end

    context "when the href begins with mailto:" do
      let(:text)  { 'Bob'             }
      let(:email) { 'bob@example.com' }
      let(:doc)   { Kramdown::Document.new("[#{text}](mailto:#{email})") }

      it "should convert the link elements into '.MT email\\n.ME'" do
        subject.convert_a(link).should == "#{text}\n.MT #{email}\n.ME"
      end

      context "when link is <email>" do
        let(:email)         { 'bob@example.com' }
        let(:escaped_email) { 'bob\[at]example\.com' }
        let(:doc)           { Kramdown::Document.new("<#{email}>") }

        it "should convert the link elements into '.MT email\\n.ME'" do
          subject.convert_a(link).should == "\n.MT #{escaped_email}\n.ME"
        end
      end
    end

    context "when the href begins with man:" do
      let(:man)  { 'bash' }
      let(:doc)  { Kramdown::Document.new("[#{man}](man:#{man})") }

      it "should convert the link elements into '.BR man'" do
        subject.convert_a(link).should == "\n.BR #{man}"
      end

      context "when a section number is specified" do
        let(:section) { '1' }
        let(:doc)     { Kramdown::Document.new("[#{man}](man:#{man}(#{section}))") }

        it "should convert the link elements into '.BR man (section)'" do
          subject.convert_a(link).should == "\n.BR #{man} (#{section})"
        end
      end
    end
  end

  describe "#escape" do
    let(:text) { "hello\nworld" }

    described_class::GLYPHS.each do |char,glyph|
      it "should convert #{char.dump} into #{glyph.dump}" do
        subject.escape("#{text} #{char}").should == "#{text} #{glyph}"
      end
    end
  end
end
