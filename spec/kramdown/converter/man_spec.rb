require 'spec_helper'
require 'kramdown/converter/man'

describe Kramdown::Converter::Man do
  let(:markdown) { File.read('man/kramdown-man.1.md') }
  let(:doc)      { Kramdown::Document.new(markdown) }
  let(:root)     { doc.root }

  subject { described_class.send(:new,root,{}) }

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
