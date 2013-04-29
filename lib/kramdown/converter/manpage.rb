require 'kramdown/manpage/version'

require 'kramdown/converter/base'

module Kramdown
  module Converter
    class Manpage < Base

      HEADER = [
        ".\\\" Generated by kramdown-manpage #{::Kramdown::Manpage::VERSION}",
        ".\\\" https://github.com/postmodern/kramdown-roff#readme"
      ].join("\n")

      def initialize(root,options)
        super(root,options)

        @ol_index = 0
      end

      def convert(root)
        "#{HEADER}\n#{convert_elements(root)}"
      end

      def convert_elements(el)
        el.children.map { |child|
          convert_element(child)
        }.compact.join("\n")
      end

      def convert_element(el)
        method = "convert_#{el.type}"
        send(method,el) if respond_to?(method)
      end

      def convert_blank(el)
        '.LP'
      end

      def convert_text(el)
        escape(el.value)
      end

      def convert_header(el)
        text = el.options[:raw_text]

        case el.options[:level]
        when 1 then ".TH #{text}"
        when 2 then ".SH #{text}"
        else        ".SS #{text}"
        end
      end

      def convert_hr(hr)
        "\n.ti 0\n\\l'\\n(.lu'\n"
      end

      def convert_ul(ul)
        content = ul.children.map { |li| convert_ul_li(li) }.join("\n")

        return ".RS\n#{content}\n.RE"
      end

      def convert_ol(ol)
        @ol_index += 1

        header  = ".nr step#{@ol_index} 0 1"
        content = ol.children.map { |li| convert_ol_li(li) }.join("\n")

        return "#{header}\n.RS\n#{content}\n.RE"
      end

      def convert_ul_li(li)
        li.children.each_with_index.map { |child,index|
          content = convert_children(child.children)

          if index == 0 then ".IP \\(bu 2\n#{content}"
          else               ".IP \\( 2\n#{content}"
          end
        }.join("\n")
      end

      def convert_ol_li(li)
        li.children.each_with_index.map { |child,index|
          content = convert_children(child.children)

          if index == 0 then ".IP \\n+[step#{@ol_index}]\n#{content}"
          else               ".IP \\n\n#{content}"
          end
        }.join("\n")
      end

      def convert_blockquote(blockquote)
        content = blockquote.children.map { |child|
          case child.type
          when :p then convert_children(child.children)
          else         convert_element(child)
          end
        }.join("\n")

        return ".PP\n.RS\n#{content}\n.RE"
      end

      def convert_codeblock(codeblock)
        ".nf\n#{escape(codeblock.value)}\n.fi"
      end

      def convert_p(p)
        children = p.children

        if (children.length >= 2) &&
           (children[0].type == :em   || children[0].type == :codespan) &&
           (children[1].type == :text && children[1].value =~ /^(  |\t)/)
          [
            '.TP',
            convert_element(children[0]),
            convert_text(children[1]).lstrip,
            convert_children(children[2..-1])
          ].join("\n").rstrip
        else
          ".PP\n#{convert_children(children)}"
        end
      end

      def convert_em(em)
        "\\fI#{convert_children(em.children)}\\fP"
      end

      def convert_strong(strong)
        "\\fB#{convert_children(strong.children)}\\fP"
      end

      def convert_codespan(codespan)
        "\\fB\\fC#{codespan.value}\\fR"
      end

      def convert_a(a)
        href = a.attr['href']
        text = convert_children(a.children)

        case href
        when /^mailto:/
          "\n.MT #{href[7..-1]}\n.ME"
        when /^man:/
          match = href.match(/man:([A-Za-z0-9_-]+)(?:\((\d[a-z]?)\))/)

          if match[2] then "\n.BR #{match[1]} (#{match[2]})"
          else             "\n.BR #{match[1]}"
          end
        else
          "#{text}\n.UR #{href}\n.UE"
        end
      end

      def convert_children(children)
        children.map { |child| convert_element(child) }.join.strip
      end

      def escape(text)
        text.gsub('\\','\&\&').gsub('-','\\-')
      end

    end
  end
end
