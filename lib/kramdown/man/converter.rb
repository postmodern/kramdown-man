# frozen_string_literal: true

require 'kramdown/man/version'

require 'kramdown/converter/base'

module Kramdown
  module Man
    #
    # Converts markdown into a roff man-page.
    #
    # @since 1.0.0
    #
    # @api private
    #
    class Converter < Kramdown::Converter::Base

      # Comment header
      HEADER = <<~ROFF
                 .\\\" Generated by kramdown-man #{VERSION}
                 .\\\" https://github.com/postmodern/kramdown-man#readme
               ROFF

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
        "#{HEADER}#{convert_root(root)}"
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
        convert_children_of(root)
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
      # @return [nil]
      #
      def convert_blank(blank)
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
        escape(text.value)
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
        when 1
          <<~ROFF
            .TH #{text}
          ROFF
        when 2
          <<~ROFF
            .SH #{text}
          ROFF
        else
          <<~ROFF
            .SS #{text}
          ROFF
        end
      end

      #
      # Ignore `kd:hr` elements.
      #
      # @param [Kramdown::Element] hr
      #   A `kd:hr` element.
      #
      # @return [nil]
      #
      def convert_hr(hr)
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
        contents = String.new(encoding: Encoding::UTF_8)

        ul.children.each do |li|
          contents << convert_ul_li(li)
        end

        return <<~ROFF
          .RS
          #{contents.chomp}
          .RE
        ROFF
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
        roff = String.new(encoding: Encoding::UTF_8)

        li.children.each_with_index do |child,index|
          if child.type == :p
            contents = convert_children_of(child)

            roff << if index == 0
                      <<~ROFF
                        .IP \\(bu 2
                        #{contents.chomp}
                      ROFF
                    else
                      <<~ROFF
                       .IP \\( 2
                       #{contents.chomp}
                      ROFF
                    end
          end
        end

        return roff
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

        contents = String.new(encoding: Encoding::UTF_8)

        ol.children.each do |li|
          contents << convert_ol_li(li)
        end

        return <<~ROFF
          .nr step#{@ol_index} 0 1
          .RS
          #{contents.chomp}
          .RE
        ROFF
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
        roff = String.new(encoding: Encoding::UTF_8)

        li.children.each_with_index do |child,index|
          if child.type == :p
            contents = convert_children_of(child)

            roff << if index == 0
                      <<~ROFF
                        .IP \\n+[step#{@ol_index}]
                        #{contents.chomp}
                      ROFF
                    else
                      <<~ROFF
                        .IP \\n
                        #{contents.chomp}
                      ROFF
                    end
          end
        end

        return roff
      end

      #
      # Converts a `kd:dl` element.
      #
      # @param [Kramdown::Element] dl
      #   A `kd:dl` element.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_dl(dl)
        roff = String.new(encoding: Encoding::UTF_8)

        dt_index = 0
        dd_index = 0

        dl.children.each do |element|
          case element.type
          when :dt
            roff << convert_dt(element, index: dt_index)

            dt_index += 1 # increment the dt count
            dd_index  = 0 # reset the dd count
          when :dd
            roff << convert_dd(element, index: dd_index)

            dd_index += 1 # increment the dd count
            dt_index  = 0 # reset the dt count
          else
            roff << convert(element)

            # reset both the dt_index and dd_index counters
            dt_index = 0
            dd_index = 0
          end
        end

        return roff
      end

      #
      # Converts a `kd:dt` element within a `kd:dl`.
      #
      # @param [Kramdown::Element] dt
      #   A `kd:dt` element.
      #
      # @param [Integer] index
      #   The index of the `kd:dt` element. Used to indicate whether this is the
      #   first `kd:dt` element or additional `kd:dt` elements.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_dt(dt, index: 0)
        text = convert_text_elements(dt.children)

        if index == 0
          <<~ROFF
            .TP
            #{text}
          ROFF
        else
          <<~ROFF
            .TQ
            #{text}
          ROFF
        end
      end

      #
      # Converts a `kd:dd` element within a `kd:dd`.
      #
      # @param [Kramdown::Element] dd
      #   A `kd:dd` element.
      #
      # @param [Integer] index
      #   The index of the `kd:dd` element. Used to indicate whether this is the
      #   first `kd:dd` element following a `kd;dt` element or additional
      #   `kd:dt` elements.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_dd(dd, index: 0)
        roff = String.new(encoding: Encoding::UTF_8)

        dd.children.each_with_index do |child,child_index|
          if index == 0 && child_index == 0 && child.type == :p
            contents = convert_children_of(child)

            # omit the .PP macro for the first paragraph
            roff << "#{contents.chomp}\n"
          else
            if (contents = convert_element(child))
              # indent all other following paragraphs or other elements
              roff << <<~ROFF
                        .RS
                        #{contents.chomp}
                        .RE
                      ROFF
            end
          end
        end

        return roff
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
        contents = convert_children_of(blockquote)

        return <<~ROFF
          .RS
          #{contents.chomp}
          .RE
        ROFF
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
        contents = escape(codeblock.value)

        return <<~ROFF
          .PP
          .EX
          #{contents.chomp}
          .EE
        ROFF
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
        roff = String.new(encoding: Encoding::UTF_8)

        comment.value.lines.each do |line|
          roff << <<~ROFF
                    .\\" #{line}
                  ROFF
        end

        return roff
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
        contents = convert_text_elements(p.children)

        return <<~ROFF
          .PP
          #{contents.chomp}
        ROFF
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
        "\\fI#{convert_text_elements(em.children)}\\fP"
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
        "\\fB#{convert_text_elements(strong.children)}\\fP"
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

        text = convert_text_elements(a.children)

        case scheme
        when 'mailto'
          email = path

          unless text == email
            <<~ROFF
              #{text.chomp}
              .MT #{email}
              .ME
            ROFF
          else
            <<~ROFF
              .MT #{email}\n.ME
            ROFF
          end
        when 'man'
          if (match = path.match(/\A(?<page>[A-Za-z0-9_-]+)(?:\((?<section>\d[a-z]?)\)|\\\.(?<section>\d[a-z]?))\z/))
            page    = match[:page]
            section = match[:section]

            <<~ROFF
              .BR #{page} (#{section})
            ROFF
          else
            <<~ROFF
              .BR #{path}
            ROFF
          end
        else
          <<~ROFF
            #{text.chomp}
            .UR #{href}
            .UE
          ROFF
        end
      end

      #
      # Converts the children of an element.
      #
      # @param [Array<Kramdown::Element>] elements
      #   The elements to convert.
      #
      # @return [String]
      #   The combined roff output.
      #
      def convert_children_of(element)
        roff = String.new(encoding: Encoding::UTF_8)

        element.children.each do |child|
          if (contents = convert_element(child))
            roff << contents
          end
        end

        return roff
      end

      #
      # Converts the children of an element.
      #
      # @param [Array<Kramdown::Element>] elements
      #   The text elements to convert.
      #
      # @return [String]
      #   The roff output.
      #
      def convert_text_elements(elements)
        roff = String.new(encoding: Encoding::UTF_8)

        elements.each do |element|
          if (contents = convert_element(element))
            if contents.start_with?('.') && !roff.empty? && !roff.end_with?("\n")
              # roff macross must exist on their own line
              roff << "\n#{contents}"
            elsif contents.start_with?(' ') && roff.end_with?("\n")
              # remove leadning whitespace following a newline
              roff << contents.lstrip
            else
              roff << contents
            end
          end
        end

        return roff
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
        text.gsub(GLYPH_REGEXP,GLYPHS)
      end

    end
  end
end
