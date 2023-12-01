require_relative '../man/version'

require 'kramdown/converter/base'

module Kramdown
  module Converter
    #
    # Converts markdown into a roff man-page.
    #
    class Man < ::Kramdown::Converter::Base

      # Comment header
      HEADER = [
        ".\\\" Generated by kramdown-man #{::Kramdown::Man::VERSION}",
        ".\\\" https://github.com/postmodern/kramdown-man#readme"
      ].join("\n")

      # Typographic Symbols and their UTF8 chars
      TYPOGRAPHIC_SYMS = {
        :ndash       => '\-\-',
        :mdash       => '\[em]',
        :hellip      => '\.\.\.',
        :laquo       => '\[Fo]',
        :raquo       => '\[Fc]',
        :laquo_space => '\[Fo]',
        :raquo_space => '\[Fc]'
      }

      # Smart Quotes and their UTF8 chars
      SMART_QUOTES = {
        :lsquo => '\[oq]',
        :rsquo => '\[cq]',
        :ldquo => '\[lq]',
        :rdquo => '\[rq]'
      }

      GLYPHS = {
        'Ð' => '\[-D]',
        'ð' => '\[Sd]',
        'Þ' => '\[TP]',
        'þ' => '\[Tp]',
        'ß' => '\[ss]',
        # Ligatures and Other Latin Glyphs
        'ﬀ' => '\[ff]',
        'ﬁ' => '\[fi]',
        'ﬂ' => '\[fl]',
        'ﬃ' => '\[Fi]',
        'ﬄ' => '\[Fl]',
        'Ł' => '\[/L]',
        'ł' => '\[/l]',
        'Ø' => '\[/O]',
        'ø' => '\[/o]',
        'Æ' => '\[AE]',
        'æ' => '\[ae]',
        'Œ' => '\[OE]',
        'œ' => '\[oe]',
        'Ĳ' => '\[IJ]',
        'ĳ' => '\[ij]',
        'ı' => '\[.i]',
        'ȷ' => '\[.j]',
        # Accented Characters
        'Á' => '\[\'A]',
        'Ć' => '\[\'C]',
        'É' => '\[\'E]',
        'Í' => '\[\'I]',
        'Ó' => '\[\'O]',
        'Ú' => '\[\'U]',
        'Ý' => '\[\'Y]',
        'á' => '\[\'a]',
        'ć' => '\[\'c]',
        'é' => '\[\'e]',
        'í' => '\[\'i]',
        'ó' => '\[\'o]',
        'ú' => '\[\'u]',
        'ý' => '\[\'y]',
        'Ä' => '\[:A]',
        'Ë' => '\[:E]',
        'Ï' => '\[:I]',
        'Ö' => '\[:O]',
        'Ü' => '\[:U]',
        'Ÿ' => '\[:Y]',
        'ä' => '\[:a]',
        'ë' => '\[:e]',
        'ï' => '\[:i]',
        'ö' => '\[:o]',
        'ü' => '\[:u]',
        'ÿ' => '\[:y]',
        'Â' => '\[^A]',
        'Ê' => '\[^E]',
        'Î' => '\[^I]',
        'Ô' => '\[^O]',
        'Û' => '\[^U]',
        'â' => '\[^a]',
        'ê' => '\[^e]',
        'î' => '\[^i]',
        'ô' => '\[^o]',
        'û' => '\[^u]',
        'À' => '\[`A]',
        'È' => '\[`E]',
        'Ì' => '\[`I]',
        'Ò' => '\[`O]',
        'Ù' => '\[`U]',
        'à' => '\[`a]',
        'è' => '\[`e]',
        'ì' => '\[`i]',
        'ò' => '\[`o]',
        'ù' => '\[`u]',
        'Ã' => '\[~A]',
        'Ñ' => '\[~N]',
        'Õ' => '\[~O]',
        'ã' => '\[~a]',
        'ñ' => '\[~n]',
        'õ' => '\[~o]',
        'Š' => '\[vS]',
        'š' => '\[vs]',
        'Ž' => '\[vZ]',
        'ž' => '\[vz]',
        'Ç' => '\[,C]',
        'ç' => '\[,c]',
        'Å' => '\[oA]',
        'å' => '\[oa]',
        # Accents
        '˝' => '\[a"]',
        '¯' => '\[a-]',
        '˙' => '\[a.]',
        # '^' => '\[a^]',
        '´' => "\\´",
        '`' => '\`',
        '˘' => '\[ab]',
        '¸' => '\[ac]',
        '¨' => '\[ad]',
        'ˇ' => '\[ah]',
        '˚' => '\[ao]',
        # '~' => '\(ti',
        '˛' => '\[ho]',
        '^' => '\(ha',
        '~' => '\[ti]',
        # Quotes
        '„' => '\[Bq]',
        '‚' => '\[bq]',
        '“' => '\[lq]',
        '”' => '\[rq]',
        '‘' => '\[oq]',
        '’' => '\[cq]',
        "'" => '\(aq',
        '"' => '\[dq]',
        '«' => '\[Fo]',
        '»' => '\[Fc]',
        '‹' => '\[fo]',
        '›' => '\[fc]',
        # Punctuation
        '.' => '\.',
        '¡' => '\[r!]',
        '¿' => '\[r?]',
        '—' => '\[em]',
        '–' => '\[en]',
        '‐' => '\[hy]',
        # Brackets
        '[' => '\[lB]',
        ']' => '\[rB]',
        '{' => '\[lC]',
        '}' => '\[rC]',
        '⟨' => '\[la]',
        '⟩' => '\[ra]',
        # '⎪' => '\[bv]',
        # '⎪' => '\[braceex]',
        '⎡' => '\[bracketlefttp]',
        '⎣' => '\[bracketleftbt]',
        '⎢' => '\[bracketleftex]',
        '⎤' => '\[bracketrighttp]',
        '⎦' => '\[bracketrightbt]',
        '⎥' => '\[bracketrightex]',
        '╭' => '\[lt]',
        '⎧' => '\[bracelefttp]',
        '┥' => '\[lk]',
        '⎨' => '\[braceleftmid]',
        '╰' => '\[lb]',
        '⎩' => '\[braceleftbt]',
        # '⎪' => '\[braceleftex]',
        '╮' => '\[rt]',
        '⎫' => '\[bracerighttp]',
        '┝' => '\[rk]',
        '⎬' => '\[bracerightmid]',
        '╯' => '\[rb]',
        '⎭' => '\[bracerightbt]',
        '⎪' => '\[bracerightex]',
        '⎛' => '\[parenlefttp]',
        '⎝' => '\[parenleftbt]',
        '⎜' => '\[parenleftex]',
        '⎞' => '\[parenrighttp]',
        '⎠' => '\[parenrightbt]',
        '⎟' => '\[parenrightex]',
        # Arrows
        '←' => '\[<-]',
        '→' => '\[->]',
        '↔' => '\[<>]',
        '↓' => '\[da]',
        '↑' => '\[ua]',
        '↕' => '\[va]',
        '⇐' => '\[lA]',
        '⇒' => '\[rA]',
        '⇔' => '\[hA]',
        '⇓' => '\[dA]',
        '⇑' => '\[uA]',
        '⇕' => '\[vA]',
        '⎯' => '\[an]',
        # Lines
        # '|' => '\[ba]',
        '│' => '\[br]',
        # '_' => '\[ul]',
        '‾' => '\[rn]',
        '_' => '\[ru]',
        '¦' => '\[bb]',
        '/' => '\[sl]',
        '\\' => '\e',
        # Text markers
        '○' => '\[ci]',
        # '·' => '\[bu]',
        '‡' => '\[dd]',
        '†' => '\[dg]',
        '◊' => '\[lz]',
        '□' => '\[sq]',
        '¶' => '\[ps]',
        '§' => '\[sc]',
        '☜' => '\[lh]',
        '☞' => '\[rh]',
        '@' => '\[at]',
        '#' => '\[sh]',
        '↵' => '\[CR]',
        '✓' => '\[OK]',
        # Legal Symbols
        '©' => '\[co]',
        '®' => '\[rg]',
        '™' => '\[tm]',
        # Currency symbols
        '$' => '\[Do]',
        '¢' => '\[ct]',
        # '€' => '\[eu]',
        '€' => '\[Eu]',
        '¥' => '\[Ye]',
        '£' => '\[Po]',
        '¤' => '\[Cs]',
        'ƒ' => '\[Fn]',
        # Units
        '°' => '\[de]',
        '‰' => '\[%0]',
        '′' => '\[fm]',
        '″' => '\[sd]',
        'µ' => '\[mc]',
        'ª' => '\[Of]',
        'º' => '\[Om]',
        # Logical Symbols
        '∧' => '\[AN]',
        '∨' => '\[OR]',
        # '¬' => '\[no]',
        '¬' => '\[tno]',
        '∃' => '\[te]',
        '∀' => '\[fa]',
        '∋' => '\[st]',
        # '∴' => '\[3d]',
        '∴' => '\[tf]',
        '|' => '\[or]',
        # Mathematical Symbols
        '½' => '\[12]',
        '¼' => '\[14]',
        '¾' => '\[34]',
        '⅛' => '\[18]',
        '⅜' => '\[38]',
        '⅝' => '\[58]',
        '⅞' => '\[78]',
        '¹' => '\[S1]',
        '²' => '\[S2]',
        '³' => '\[S3]',
        '+' => '\[pl]',
        '-' => '\-',
        '−' => '\[mi]',
        '∓' => '\[-+]',
        # '±' => '\[+-]',
        '±' => '\[t+-]',
        '·' => '\[pc]',
        '⋅' => '\[md]',
        # '×' => '\[mu]',
        '×' => '\[tmu]',
        '⊗' => '\[c*]',
        '⊕' => '\[c+]',
        # '÷' => '\[di]',
        '÷' => '\[tdi]',
        '⁄' => '\[f/]',
        '∗' => '\[**]',
        '≤' => '\[<=]',
        '≥' => '\[>=]',
        '≪' => '\[<<]',
        '≫' => '\[>>]',
        '=' => '\[eq]',
        '≠' => '\[!=]',
        '≡' => '\[==]',
        '≢' => '\[ne]',
        '≅' => '\[=~]',
        '≃' => '\[|=]',
        '∼' => '\[ap]',
        # '≈' => '\[~~]',
        '≈' => '\[~=]',
        '∝' => '\[pt]',
        '∅' => '\[es]',
        '∈' => '\[mo]',
        '∉' => '\[nm]',
        '⊂' => '\[sb]',
        '⊄' => '\[nb]',
        '⊃' => '\[sp]',
        '⊅' => '\[nc]',
        '⊆' => '\[ib]',
        '⊇' => '\[ip]',
        '∩' => '\[ca]',
        '∪' => '\[cu]',
        '∠' => '\[/_]',
        '⊥' => '\[pp]',
        # '∫' => '\[is]',
        '∫' => '\[integral]',
        '∑' => '\[sum]',
        '∏' => '\[product]',
        '∐' => '\[coproduct]',
        '∇' => '\[gr]',
        # '√' => '\[sr]',
        '√' => '\[sqrt]',
        '⌈' => '\[lc]',
        '⌉' => '\[rc]',
        '⌊' => '\[lf]',
        '⌋' => '\[rf]',
        '∞' => '\[if]',
        'ℵ' => '\[Ah]',
        'ℑ' => '\[Im]',
        'ℜ' => '\[Re]',
        '℘' => '\[wp]',
        '∂' => '\[pd]',
        # 'ℏ' => '\[-h]',
        'ℏ' => '\[hbar]',
        # Greek glyphs
        'Α' => '\[*A]',
        'Β' => '\[*B]',
        'Γ' => '\[*G]',
        'Δ' => '\[*D]',
        'Ε' => '\[*E]',
        'Ζ' => '\[*Z]',
        'Η' => '\[*Y]',
        'Θ' => '\[*H]',
        'Ι' => '\[*I]',
        'Κ' => '\[*K]',
        'Λ' => '\[*L]',
        'Μ' => '\[*M]',
        'Ν' => '\[*N]',
        'Ξ' => '\[*C]',
        'Ο' => '\[*O]',
        'Π' => '\[*P]',
        'Ρ' => '\[*R]',
        'Σ' => '\[*S]',
        'Τ' => '\[*T]',
        'Υ' => '\[*U]',
        'Φ' => '\[*F]',
        'Χ' => '\[*X]',
        'Ψ' => '\[*Q]',
        'Ω' => '\[*W]',
        'α' => '\[*a]',
        'β' => '\[*b]',
        'γ' => '\[*g]',
        'δ' => '\[*d]',
        'ε' => '\[*e]',
        'ζ' => '\[*z]',
        'η' => '\[*y]',
        'θ' => '\[*h]',
        'ι' => '\[*i]',
        'κ' => '\[*k]',
        'λ' => '\[*l]',
        'μ' => '\[*m]',
        'ν' => '\[*n]',
        'ξ' => '\[*c]',
        'ο' => '\[*o]',
        'π' => '\[*p]',
        'ρ' => '\[*r]',
        'ς' => '\[ts]',
        'σ' => '\[*s]',
        'τ' => '\[*t]',
        'υ' => '\[*u]',
        'ϕ' => '\[*f]',
        'χ' => '\[*x]',
        'ψ' => '\[*q]',
        'ω' => '\[*w]',
        'ϑ' => '\[+h]',
        'φ' => '\[+f]',
        'ϖ' => '\[+p]',
        'ϵ' => '\[+e]',
        # Card symbols
        '♣' => '\[CL]',
        '♠' => '\[SP]',
        '♥' => '\[HE]',
        '♡' => '\[u2661]',
        '♦' => '\[DI]',
        '♢' => '\[u2662]'
      }

      # Regular expression to convert unicode characters into glyphs
      GLYPH_REGEXP = Regexp.union(GLYPHS.keys)

      #
      # Initializes the converter.
      #
      # @param [Kramdown::Element] root
      #   The root of the markdown document.
      #
      # @param [Hash] options
      #   Markdown options.
      #
      def initialize(root,options)
        super(root,options)

        @ol_index = 0
      end

      #
      # Converts the markdown document into a man-page.
      #
      # @param [Kramdown::Element] root
      #   The root of a markdown document.
      #
      # @return [String]
      #   The roff output.
      #
      def convert(root)
        "#{HEADER}\n#{convert_root(root)}"
      end

      #
      # Converts the root of a markdown document.
      #
      # @param [Kramdown::Element] root
      #   The root of the markdown document.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_root(root)
        root.children.map { |child|
          convert_element(child)
        }.compact.join("\n")
      end

      #
      # Converts an element.
      #
      # @param [Kramdown::Element] element
      #   An arbitrary element within the markdown document.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_element(element)
        method = "convert_#{element.type}"
        send(method,element) if respond_to?(method)
      end

      #
      # Converts a `kd:blank` element.
      #
      # @param [Kramdown::Element] blank
      #   A `kd:blank` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_blank(blank)
        '.LP'
      end

      #
      # Converts a `kd:text` element.
      #
      # @param [Kramdown::Element] text
      #   A `kd:text` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_text(text)
        escape(text.value.gsub(/^(  +|\t)/,''))
      end

      #
      # Converts a `kd:typographic_sym` element.
      #
      # @param [Kramdown::Element] sym
      #   A `kd:typographic_sym` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_typographic_sym(sym)
        TYPOGRAPHIC_SYMS[sym.value]
      end

      #
      # Converts a `kd:smart_quote` element.
      #
      # @param [Kramdown::Element] quote
      #   A `kd:smart_quote` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_smart_quote(quote)
        SMART_QUOTES[quote.value]
      end

      #
      # Converts a `kd:header` element.
      #
      # @param [Kramdown::Element] header
      #   A `kd:header` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_header(header)
        text = header.options[:raw_text]

        case header.options[:level]
        when 1 then ".TH #{text}"
        when 2 then ".SH #{text}"
        else        ".SS #{text}"
        end
      end

      #
      # Converts a `kd:hr` element.
      #
      # @param [Kramdown::Element] hr
      #   A `kd:hr` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_hr(hr)
        ".ti 0\n\\l'\\n(.lu'"
      end

      #
      # Converts a `kd:ul` element.
      #
      # @param [Kramdown::Element] ul
      #   A `kd:ul` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_ul(ul)
        content = ul.children.map { |li| convert_ul_li(li) }.join("\n")

        return ".RS\n#{content}\n.RE"
      end

      #
      # Converts a `kd:li` element within a `kd:ul` list.
      #
      # @param [Kramdown::Element] li
      #   A `kd:li` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_ul_li(li)
        li.children.each_with_index.map { |child,index|
          if child.type == :p
            content = convert_children(child.children)

            if index == 0 then ".IP \\(bu 2\n#{content}"
            else               ".IP \\( 2\n#{content}"
            end
          end
        }.compact.join("\n")
      end

      #
      # Converts a `kd:ol` element.
      #
      # @param [Kramdown::Element] ol
      #   A `kd:ol` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_ol(ol)
        @ol_index += 1

        header  = ".nr step#{@ol_index} 0 1"
        content = ol.children.map { |li| convert_ol_li(li) }.join("\n")

        return "#{header}\n.RS\n#{content}\n.RE"
      end

      #
      # Converts a `kd:li` element within a `kd:ol` list.
      #
      # @param [Kramdown::Element] li
      #   A `kd:li` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_ol_li(li)
        li.children.each_with_index.map { |child,index|
          if child.type == :p
            content = convert_children(child.children)

            if index == 0 then ".IP \\n+[step#{@ol_index}]\n#{content}"
            else               ".IP \\n\n#{content}"
            end
          end
        }.compact.join("\n")
      end

      #
      # Converts a `kd:abbreviation` element.
      #
      # @param [Kramdown::Element] abbr
      #   A `kd:abbreviation` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_abbreviation(abbr)
        escape(abbr.value)
      end

      #
      # Converts a `kd:blockquote` element.
      #
      # @param [Kramdown::Element] blockquote
      #   A `kd:blockquote` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_blockquote(blockquote)
        content = blockquote.children.map { |child|
          case child.type
          when :p then convert_children(child.children)
          else         convert_element(child)
          end
        }.join("\n")

        return ".PP\n.RS\n#{content}\n.RE"
      end

      #
      # Converts a `kd:codeblock` element.
      #
      # @param [Kramdown::Element] codeblock
      #   A `kd:codeblock` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_codeblock(codeblock)
        ".nf\n#{escape(codeblock.value).rstrip}\n.fi"
      end

      #
      # Converts a `kd:comment` element.
      #
      # @param [Kramdown::Element] comment
      #   A `kd:comment` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_comment(comment)
        comment.value.lines.map { |line|
          ".\\\" #{line}"
        }.join("\n")
      end

      #
      # Converts a `kd:p` element.
      #
      # @param [Kramdown::Element] p
      #   A `kd:p` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_p(p)
        children = p.children

        if ((children.length >= 2) && (children.first.type == :codespan ||
                                       children.first.type == :em       ||
                                       children.first.type == :strong))
          newline = children.find_index { |el|
            el.type == :text && el.value.start_with?("\n")
          }

          if newline
            first_line = convert_children(children[0...newline])
            rest       = convert_children(children[newline..-1]).strip

            ".TP\n#{first_line}\n#{rest}"
          else
            ".HP\n#{convert_children(children)}"
          end
        else
          ".PP\n#{convert_children(children)}"
        end
      end

      #
      # Converts a `kd:em` element.
      #
      # @param [Kramdown::Element] em
      #   A `kd:em` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_em(em)
        "\\fI#{convert_children(em.children)}\\fP"
      end

      #
      # Converts a `kd:strong` element.
      #
      # @param [Kramdown::Element] strong
      #   A `kd:strong` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_strong(strong)
        "\\fB#{convert_children(strong.children)}\\fP"
      end

      #
      # Converts a `kd:codespan` element.
      #
      # @param [Kramdown::Element] codespan
      #   A `kd:codespan` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_codespan(codespan)
        "\\fB#{codespan.value}\\fR"
      end

      #
      # Converts a `kd:a` element.
      #
      # @param [Kramdown::Element] a
      #   A `kd:a` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_a(a)
        href = escape(a.attr['href'])
        scheme, path = href.split(':',2)

        text = convert_children(a.children)

        case scheme
        when 'mailto'
          email = path

          unless text == email
            "#{text}\n.MT #{email}\n.ME"
          else
            "\n.MT #{email}\n.ME"
          end
        when 'man'
          if (match = path.match(/\A([A-Za-z0-9_-]+)(?:\((\d[a-z]?)\))\z/))
            "\n.BR #{match[1]} (#{match[2]})"
          else
            "\n.BR #{path}"
          end
        else
          "#{text}\n.UR #{href}\n.UE"
        end
      end

      #
      # Converts the children of an element.
      #
      # @param [Array<Kramdown::Element>] children
      #   The children of an element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_children(children)
        children.map { |child| convert_element(child) }.join.strip
      end

      #
      # Escapes text for roff.
      #
      # @param [String] text
      #   The unescaped text.
      #
      # @return [String]
      #   The escaped text.
      #
      def escape(text)
        text.gsub(GLYPH_REGEXP) { |char| GLYPHS[char] }
      end

    end
  end
end
