# frozen_string_literal: true

require 'kramdown'

require 'kramdown/man/version'
require 'kramdown/man/converter'

module Kramdown
  class Document
    #
    # Converts the parsed markdown document to a man page.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @return [String]
    #   The converted man page contents.
    #
    # @since 1.0.0
    #
    def to_man(options={})
      output, warnings = Kramdown::Man::Converter.convert(@root,options)

      @warnings.concat(warnings)
      return output
    end
  end
end
