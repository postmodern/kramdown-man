require 'spec_helper'
require 'kramdown/manpage'

describe Kramdown::Manpage do
  it "should have a VERSION constant" do
    subject.const_get('VERSION').should_not be_empty
  end
end
