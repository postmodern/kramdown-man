# encoding: utf-8
require 'spec_helper'
require 'kramdown/converter/man'

describe Kramdown::Converter::Man do
  let(:markdown) { File.read('man/kramdown-man.1.md') }
  let(:doc)      { Kramdown::Document.new(markdown) }
  let(:root)     { doc.root }

  subject { described_class.send(:new,root,{}) }

  describe "#convert" do
  end

  describe "#convert_root" do
  end

  describe "#convert_element" do
  end

  describe "#convert_blank" do
    let(:doc)   { Kramdown::Document.new("foo\n\nbar") }
    let(:blank) { doc.root.children[0].children[1] }

    it "should convert blank elements to '.LP'" do
      subject.convert_blank(blank).should == '.LP'
    end
  end

  describe "#convert_text" do
    let(:content) { 'Foo bar' }
    let(:doc)     { Kramdown::Document.new(content) }
    let(:text)   { doc.root.children[0].children[0] }

    it "should convert text elements" do
      subject.convert_text(text).should == content
    end
  end

  describe "#convert_typographic_sym" do
    context "ndash" do
      let(:doc) { Kramdown::Document.new("-- foo")     }
      let(:sym) { doc.root.children[0].children[0] }

      it "should convert ndash symbols back into '--'" do
        subject.convert_typographic_sym(sym).should == '--'
      end
    end

    context "mdash" do
      let(:doc) { Kramdown::Document.new("--- foo") }
      let(:sym) { doc.root.children[0].children[0]  }

      it "should convert mdash symbols into '—'" do
        subject.convert_typographic_sym(sym).should == '—'
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

      it "should convert mdash symbols into '«'" do
        subject.convert_typographic_sym(sym).should == '«'
      end
    end

    context "raquo" do
      let(:doc) { Kramdown::Document.new("foo >> bar") }
      let(:sym) { doc.root.children[0].children[1]  }

      it "should convert mdash symbols into '»'" do
        subject.convert_typographic_sym(sym).should == '»'
      end
    end

    context "laquo_space" do
    end

    context "raquo_space" do
    end
  end

  describe "#convert_smart_quote" do
    context "lsquo" do
      let(:doc)   { Kramdown::Document.new("'hello world'") }
      let(:quote) { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '‘'" do
        subject.convert_smart_quote(quote).should == '‘'
      end
    end

    context "rsquo" do
      let(:doc)   { Kramdown::Document.new("'hello world'") }
      let(:quote) { doc.root.children[0].children.last }

      it "should convert rsquo quotes into '’'" do
        subject.convert_smart_quote(quote).should == '’'
      end
    end

    context "ldquo" do
      let(:doc)   { Kramdown::Document.new('"hello world"') }
      let(:quote) { doc.root.children[0].children.first }

      it "should convert lsquo quotes into '“'" do
        subject.convert_smart_quote(quote).should == '“'
      end
    end

    context "rdquo" do
      let(:doc)   { Kramdown::Document.new('"hello world"') }
      let(:quote) { doc.root.children[0].children.last }

      it "should convert lsquo quotes into '”'" do
        subject.convert_smart_quote(quote).should == '”'
      end
    end
  end

  describe "#convert_header" do
  end

  describe "#convert_hr" do
  end

  describe "#convert_ul" do
  end

  describe "#convert_ul_li" do
  end

  describe "#convert_ol" do
  end

  describe "#convert_ol_li" do
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
    let(:text)       { "Some quote." }
    let(:doc)        { Kramdown::Document.new("> #{text}") }
    let(:blockquote) { doc.root.children[0] }

    it "should convert blockquote elements into '.PP\\n.RS\\ntext...\\n.RE'" do
      subject.convert_blockquote(blockquote).should == ".PP\n.RS\n#{text}\n.RE"
    end
  end

  describe "#convert_codeblock" do
    let(:code)      { "puts 'hello world'" }
    let(:doc)       { Kramdown::Document.new("    #{code}\n") }
    let(:codeblock) { doc.root.children[0] }

    it "should convert codeblock elements into '.nf\\ntext...\\n.fi'" do
      subject.convert_codeblock(codeblock).should == ".nf\n#{code}\n.fi"
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
    let(:text) { "Hello world." }
    let(:doc)  { Kramdown::Document.new(text) }
    let(:p)    { doc.root.children[0] }

    it "should convert p elements into '.PP\\ntext'" do
      subject.convert_p(p).should == ".PP\n#{text}"
    end

    context "when the second line is indented" do
      let(:option) { '--foo' }
      let(:text)   { 'Foo bar baz' }
      let(:doc)    { Kramdown::Document.new("`#{option}`\n  #{text}") }

      it "should convert p elements into '.TP\\n\\fB\\fC--option\\fR\\ntext...'" do
        subject.convert_p(p).should == ".TP\n\\fB\\fC#{option}\\fR\n#{text}"
      end
    end
  end

  describe "#convert_em" do
    let(:text) { "hello world" }
    let(:doc)  { Kramdown::Document.new("*#{text}*") }
    let(:em)   { doc.root.children[0].children[0] }

    it "should convert em into '\\fItext\\fP'" do
      subject.convert_em(em).should == "\\fI#{text}\\fP"
    end
  end

  describe "#convert_strong" do
    let(:text)   { "hello world" }
    let(:doc)    { Kramdown::Document.new("**#{text}**") }
    let(:strong) { doc.root.children[0].children[0] }

    it "should convert strong into '\\fBtext\\fP'" do
      subject.convert_strong(strong).should == "\\fB#{text}\\fP"
    end
  end

  describe "#convert_codespan" do
    let(:code)     { "puts 'hello world'" }
    let(:doc)      { Kramdown::Document.new("`#{code}`") }
    let(:codespan) { doc.root.children[0].children[0] }

    it "should convert codespans into '\\fB\\fCcode\\fR'" do
      subject.convert_codespan(codespan).should == "\\fB\\fC#{code}\\fR"
    end
  end

  describe "#convert_a" do
    let(:text) { 'example'             }
    let(:href) { 'http://example.com/' }
    let(:doc)  { Kramdown::Document.new("[#{text}](#{href})") }
    let(:link) { doc.root.children[0].children[0] }

    it "should convert a link into 'text\\n.UR href\\n.UE'" do
      subject.convert_a(link).should == "#{text}\n.UR #{href}\n.UE"
    end

    context "when the href begins with mailto:" do
      let(:text)  { 'Bob'             }
      let(:email) { 'bob@example.com' }
      let(:doc)   { Kramdown::Document.new("[#{text}](mailto:#{email})") }

      it "should convert the link into '.MT email\\n.ME'" do
        subject.convert_a(link).should == "#{text}\n.MT #{email}\n.ME"
      end

      context "when link is <email>" do
        let(:email) { 'bob@example.com' }
        let(:doc)   { Kramdown::Document.new("<#{email}>") }

        it "should convert the link into '.MT email\\n.ME'" do
          subject.convert_a(link).should == "\n.MT #{email}\n.ME"
        end
      end
    end

    context "when the href begins with man:" do
      let(:man)  { 'bash' }
      let(:doc)  { Kramdown::Document.new("[#{man}](man:#{man})") }

      it "should convert the link into '.BR man'" do
        subject.convert_a(link).should == ".BR #{man}"
      end

      context "when a section number is specified" do
        let(:section) { '1' }
        let(:doc)     { Kramdown::Document.new("[#{man}](man:#{man}(#{section}))") }

        it "should convert the link into '.BR man (section)'" do
          subject.convert_a(link).should == ".BR #{man} (#{section})"
        end
      end
    end
  end

  describe "#escape" do
    it "should escape '\\' as '\\\\'" do
      subject.escape("hello\\ world").should == "hello\\\\ world"
    end

    it "should escape '-' as '\\-'" do
      subject.escape("foo-bar").should == "foo\\-bar"
    end
  end
end
