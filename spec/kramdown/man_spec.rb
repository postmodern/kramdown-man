require_relative '../spec_helper'
require 'kramdown/man'

describe Kramdown::Man do
  it "should have a VERSION constant" do
    expect(subject.const_get('VERSION')).not_to be_empty
  end
end
