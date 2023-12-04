require 'kramdown'
require 'kramdown/man'

require 'optparse'

module Kramdown
  module Man
    #
    # Represents the `kramdown-man` command's logic.
    #
    # @api private
    #
    # @since 1.0.0
    #
    class CLI

      # The program name.
      PROGRAM_NAME = "kramdown-man"

      # The URL to report bugs to.
      BUG_REPORT_URL = "https://github.com/postmodern/kramdown-man/issues/new"

      # The path to the man/ directory.
      MAN_PAGE = File.join(__dir__,'..','..','..','man','kramdown-man.1')

      # The command's option parser.
      #
      # @return [OptionParser]
      attr_reader :option_parser

      # The optional output file to write to.
      #
      # @return [String, nil]
      attr_reader :output

      #
      # Initializes the command.
      #
      def initialize
        @option_parser = option_parser

        @output = nil
      end

      #
      # Initializes and runs the command.
      #
      # @param [Array<String>] argv
      #   Command-line arguments.
      #
      # @return [Integer]
      #   The exit status of the command.
      #
      def self.run(argv)
        new().run(argv)
      rescue Interrupt
        # https://tldp.org/LDP/abs/html/exitcodes.html
        return 130
      rescue Errno::EPIPE
        # STDOUT pipe broken
        return 0
      end

      #
      # Runs the command.
      #
      # @param [Array<String>] argv
      #   Command-line arguments.
      #
      # @return [Integer]
      #   The return status code.
      #
      def run(argv=ARGV)
        argv = begin
                 @option_parser.parse(argv)
               rescue OptionParser::ParseError => error
                 print_error(error.message)
                 return -1
               end

        markdown = case argv.length
                   when 1
                     path = argv[0]

                     unless File.file?(path)
                       print_error "no such file or directory: #{path}"
                       return -1
                     end

                     File.read(path)
                   when 0
                     print_error "a MARKDOWN_FILE argument is required"
                     return -1
                   else
                     print_error "too many arguments given"
                     return -1
                   end

        doc = Kramdown::Document.new(markdown)
        man_page = doc.to_man

        if @output
          File.write(@output,man_page)
        elsif $stdout.tty?
          view_man_page(man_page)
        else
          puts man_page
        end

        return 0
      rescue => error
        print_backtrace(error)
        return -1
      end

      #
      # Displays the man page using the `man` command.
      #
      # @param [String] man_page
      #   The man page output.
      #
      def view_man_page(man_page)
        io  = IO.popen(%w[man -l -],'w')
        pid = io.pid

        begin
          io.puts man_page
        rescue Errno::EPIPE
        ensure
          io.close

          begin
            Process.waitpid(pid)
          rescue Errno::EPIPE, Errno::ECHILD
          end
        end
      end

      #
      # The option parser.
      #
      # @return [OptionParser]
      #
      def option_parser
        OptionParser.new do |opts|
          opts.banner = "usage: #{PROGRAM_NAME} [options] MARKDOWN_FILE"

          opts.on('-o','--output FILE','Write man page output to the file') do |file|
            @output = file
          end

          opts.on('-V','--version','Print the version') do
            puts "#{PROGRAM_NAME} #{VERSION}"
            exit
          end

          opts.on('-h','--help','Print the help output') do
            if $stdout.tty?
              system('man',MAN_PAGE)
            else
              puts opts
            end

            exit
          end

          opts.separator ""
          opts.separator "Examples:"
          opts.separator "    #{PROGRAM_NAME} -o man/myprogram.1 man/myprogram.1.md"
          opts.separator "    #{PROGRAM_NAME} man/myprogram.1.md"
          opts.separator ""
        end
      end

      #
      # Prints an error message to stderr.
      #
      # @param [String] error
      #   The error message.
      #
      def print_error(error)
        $stderr.puts "#{PROGRAM_NAME}: #{error}"
      end

      #
      # Prints a backtrace to stderr.
      #
      # @param [Exception] exception
      #   The exception.
      #
      def print_backtrace(exception)
        $stderr.puts "Oops! Looks like you've found a bug!"
        $stderr.puts "Please report the following text to: #{BUG_REPORT_URL}"
        $stderr.puts
        $stderr.puts "```"
        $stderr.puts "#{exception.full_message}"
        $stderr.puts "```"
      end

    end
  end
end
