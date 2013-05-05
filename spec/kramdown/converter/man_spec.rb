require 'spec_helper'
require 'kramdown/converter/man'

describe Kramdown::Converter::Man do
  let(:markdown) { File.read('man/kramdown-man.1.md') }
  let(:doc)      { Kramdown::Document.new(markdown) }
  let(:root)     { doc.root }

  subject { described_class.send(:new,root,{}) }

  describe "#escape" do
    it "should escape '\\' as '\\\\'" do
      subject.escape("hello\\ world").should == "hello\\\\ world"
    end

    it "should escape '-' as '\\-'" do
      subject.escape("foo-bar").should == "foo\\-bar"
    end
  end
end
