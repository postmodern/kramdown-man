require 'kramdown'
require 'kramdown/converter/man'

require 'rake/tasklib'

module Kramdown
  module Man
    #
    # Defines a `man` rake task that generates man-pages within the `man/`
    # directory from `.md` files.
    #
    class Task < Rake::TaskLib

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
        @options   = options
        @markdown  = FileList[FILES]
        @man_pages = @markdown.pathmap('%X')

        define
      end

      protected

      #
      # Defines the `man` tasks.
      #
      def define
        desc 'Build UNIX manual pages from Markdown files in man/'
        task 'man' => @man_pages

        @markdown.zip(@man_pages).each do |markdown,man_page|
          file(man_page => markdown) do
            render(markdown,man_page)
          end
        end
      end

      #
      # Renders a man_page from a markdown file.
      #
      # @param [String] markdown
      #   The path to the input markdown file.
      #
      # @param [String] man_page
      #   The path to the output man_page file.
      #
      def render(markdown,man_page)
        doc = Kramdown::Document.new(File.read(markdown),@options)

        File.open(man_page,'w') do |output|
          output.write doc.to_man
        end
      end
    end
  end
end
