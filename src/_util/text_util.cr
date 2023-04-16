require "html"
require "colorize"

require "./char_util"

module TextUtil
  extend self

  BR_RE = /\<br\s*\/?\>|\s{4,+}/i

  def split_html(input : String, fix_br : Bool = true) : Array(String)
    input = HTML.unescape(input)

    input = fix_spaces(input)
    input = input.gsub(BR_RE, "\n") if fix_br

    split_text(input, spaces_as_newline: true)
  end

  def split_text(input : String, spaces_as_newline = true) : Array(String)
    input = input.gsub(/\s{2,}/, "\n") if spaces_as_newline
    input.split(/\r\n?|\n/).map(&.strip).reject(&.empty?)
  end

  SPACES = "\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000\t"

  def fix_spaces(input : String) : String
    input.tr(SPACES, " ").tr("", "")
  end

  def trim_spaces(input : String) : String
    input.tr("\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000\t\n", " ").strip
  end

  # capitalize all words
  def titleize(input : String) : String
    input.split(' ').map { |x| capitalize(x) }.join(' ')
  end

  # smart capitalize:
  # - don't downcase extra characters
  # - treat unicode alphanumeric chars as upcase-able
  def capitalize(input : String) : String
    # TODO: handle punctuations?
    res = String::Builder.new(input.size)
    uncap = true

    input.each_char do |char|
      if uncap && char.alphanumeric?
        res << char.upcase
        uncap = false
      else
        res << char
      end
    end

    res.to_s
  end

  # make url friendly string
  def slugify(input : String, tones = false) : String
    input = unaccent(input) unless tones

    tokenize(input, tones).join("-")
  end

  # split input to words
  def tokenize(input : String, tones = false) : Array(String)
    input = unaccent(input) unless tones
    split_words(input.downcase)
  end

  # strip vietnamese accents
  def unaccent(input : String) : String
    String.build do |str|
      input.unicode_normalize(:nfd).each_char do |char|
        case char
        when 'A'..'Z'               then str << (char.ord &+ 32).unsafe_chr
        when 'đ', 'Đ'               then str << 'd'
        when '\u{0300}'..'\u{036f}' then next # skip tone marks
        else                             str << char
        end
      end
    end
  end

  # :nodoc:
  def split_words(input : String) : Array(String)
    res = [] of String
    acc = String::Builder.new

    input.each_char do |char|
      if char.alphanumeric?
        acc << char
        next
      end

      unless acc.empty?
        res << acc.to_s
        acc = String::Builder.new
      end

      word = char.to_s
      res << word if word =~ /\p{L}/
    end

    acc = acc.to_s
    res << acc unless acc.empty?
    res
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  TAGS = "章节幕回折"
  # SEPS = ".，,、：: "

  LABEL_RE = {
    /^(第[#{NUMS}\d]+[集卷季].*?)(第?[#{NUMS}\d]+[#{TAGS}].*)$/,
    /^(第[#{NUMS}\d]+[集卷季].*?)(（\p{N}+）.*)$/,
    /^【?(第[#{NUMS}\d]+[集卷季])】?\s*(.+)$/,
  }

  def format_title(title : String, chvol = "", trim = false) : Tuple(String, String)
    title = trim_spaces(title)

    unless chvol.empty?
      chvol = trim_spaces(chvol)
      return {title, chvol}
    end

    LABEL_RE.each do |regex|
      next unless match = regex.match(title)
      return {match[2].lstrip, match[1].rstrip}
    end

    {title, chvol}
  end

  # FIX_RE_0 = {
  #   /^第?([#{NUMS}\d]+)([#{TAGS}])[#{SEPS}]*(.*)$/, # generic
  #   /^\d+\.\s*第(.+)([#{TAGS}])[#{SEPS}]*(.*)/,     # 69shu 1
  #   /^第(.+)([#{TAGS}])\s\d+\.\s*(.*)/,             # 69shu 2
  # }

  # FIX_RE_1 = {
  #   /^([#{NUMS}\d]+)[#{SEPS}]+(.*)$/,
  #   /^\（(\p{N}+)\）[#{SEPS}]*(.*)$/,
  # }

  # private def fix_title(title : String, trim = false) : String
  #   FIX_RE_0.each do |regex|
  #     next unless match = regex.match(title)
  #     _, idx, tag, title = match
  #     return title.empty? ? "第#{idx}#{tag}" : "第#{idx}#{tag} #{title}"
  #   end

  #   FIX_RE_1.each do |regex|
  #     next unless match = regex.match(title)
  #     _, idx, title = match
  #     return title.empty? ? "#{idx}." : trim ? title : "#{idx}. #{title}"
  #   end

  #   title
  # end

  def split_spaces(input : String)
    chars = input.chars

    output = [] of String
    buffer = String::Builder.new

    while chars.size > 0
      while char = chars.shift?
        if char == ' '
          output << buffer.to_s
          buffer = String::Builder.new(char.to_s)
        else
          buffer << char
        end
      end

      while char = chars.shift?
        if char != ' '
          output << buffer.to_s
          buffer = String::Builder.new(char.to_s)
        else
          buffer << char
        end
      end
    end

    output << buffer.to_s
    output
  end

  def clean_spaces(input : String)
    input.tr("\t\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000", " ").strip
  end

  # Convert chinese punctuations to english punctuations
  # and full width characters to ascii characters
  def normalize(input : String) : String
    normalize(input.chars).join
  end

  # :ditto:
  def normalize(input : Array(Char)) : Array(Char)
    input.map { |char| CharUtil.normalize(char) }
  end

  FIX_MARKS = {
    "òa" => "oà",
    "óa" => "oá",
    "ỏa" => "oả",
    "õa" => "oã",
    "ọa" => "oạ",

    "òe" => "oè",
    "óe" => "oé",
    "ỏe" => "oẻ",
    "õe" => "oẽ",
    "ọe" => "oẹ",

    "ùy" => "uỳ",
    "úy" => "uý",
    "ủy" => "uỷ",
    "ũy" => "uỹ",
    "ụy" => "uỵ",
  }

  MARK_RE = Regex.new(FIX_MARKS.keys.join('|'))

  def fix_viet(str : String)
    str.unicode_normalize(:nfkc).gsub(MARK_RE) { |key| FIX_MARKS[key] }
  end

  def truncate(input : String, limit = 100)
    String.build do |io|
      count = 0

      input.split(/\s+/).each do |word|
        io << ' ' if count > 0
        io << word

        count &+= word.size
        break if count > limit
      end

      io << '…' if count > limit
    end
  end
end

# pp TextUtil.format_title("第二十集 红粉骷髅 第八章")
# pp TextUtil.format_title("9205.第9205章")
# pp TextUtil.format_title("340.番外：林薇实习（1）", trim: false)
# pp TextUtil.format_title("【第006章】我的美女死党")
