require 'kramdown'
require 'kramdown/converter/manpage'

require 'rake/tasklib'

module Kramdown
  module Manpage
    class Tasks < Rake::TaskLib

      # Markdown file glob pattern
      FILES = 'man/{**/}*.{markdown,mkd,md}'

      # Additional options
      #
      # @return [Hash]
      attr_reader :options

      #
      # Initializes the tasks.
      #
      # @param [Hash] options
      #   Additional options.
      #
      def initialize(options={})
        @options  = options
        @markdown = FileList[FILES]
        @manpages = @markdown.pathmap('%X')

        define
      end

      protected

      #
      # Defines the `man` tasks.
      #
      def define
        desc 'Build UNIX manual pages from Markdown files in man/'
        task 'man' => @manpages

        @markdown.zip(@manpages).each do |markdown,manpage|
          file(manpage => markdown) do
            render(markdown,manpage)
          end
        end
      end

      #
      # Renders a manpage from a markdown file.
      #
      # @param [String] markdown
      #   The path to the input markdown file.
      #
      # @param [String] manpage
      #   The path to the output manpage file.
      #
      def render(markdown,manpage)
        doc = Kramdown::Document.new(File.read(markdown),@options)
        File.write(manpage,doc.to_manpage)
      end
    end
  end
end
