require_relative '../spec_helper'

require 'kramdown/man'

describe Kramdown::Document, :integration do
  let(:man_dir)       { File.expand_path('../../../man',__FILE__) }
  let(:markdown_path) { File.join(man_dir,'kramdown-man.1.md')    }
  let(:markdown)      { File.read(markdown_path)                  }

  subject { described_class.new(markdown) }

  describe "#to_man" do
    it "must return the same output as Kramdown::Converter::Man" do
      output, warnings = Kramdown::Converter::Man.convert(subject.root)

      expect(subject.to_man).to be == output
    end
  end
end
