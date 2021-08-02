require "html"
require "colorize"

module CV::TextUtils
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

  SPACES = "\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000"

  def fix_spaces(input : String) : String
    input.tr(SPACES, " ")
  end

  # capitalize all words
  def titleize(input : String) : String
    input.split(' ').map { |x| capitalize(x) }.join(' ')
  end

  # smart capitalize:
  # - don't downcase extra characters
  # - treat unicode alphanumeric chars as upcase-able
  def capitalize(input : String) : String
    # TODO: handle punctuation?
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

  # split input to words
  def tokenize(input : String, tones = false) : Array(String)
    input = unaccent(input) unless tones
    split_words(input.downcase)
  end

  # make url friendly string
  def slugify(input : String, tones = false) : String
    tokenize(input, tones).join("-")
  end

  # strip vietnamese accents
  def unaccent(input : String) : String
    input
      .tr("áàãạảAÁÀÃẠẢăắằẵặẳĂẮẰẴẶẲâầấẫậẩÂẤẦẪẬẨ", "a")
      .tr("éèẽẹẻEÉÈẼẸẺêếềễệểÊẾỀỄỆỂ", "e")
      .tr("íìĩịỉIÍÌĨỊỈ", "i")
      .tr("óòõọỏOÓÒÕỌỎôốồỗộổÔỐỒỖỘỔơớờỡợởƠỚỜỠỢỞ", "o")
      .tr("úùũụủUÚÙŨỤỦưứừữựửƯỨỪỮỰỬ", "u")
      .tr("ýỳỹỵỷYÝỲỸỴỶ", "y")
      .tr("đĐD", "d")
  end

  # :nodoc:
  def split_words(input : String) : Array(String)
    res = [] of String
    acc = ""

    input.each_char do |char|
      if char.alphanumeric?
        acc += char
        next
      end

      unless acc.empty?
        res << acc
        acc = ""
      end

      word = char.to_s
      res << word if word =~ /\p{L}/
    end

    res << acc unless acc.empty?
    res
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  TAGS = "章节幕回折"
  SEPS = ".，,、：: "

  LABEL_RE = {
    /^(第[#{NUMS}\d]+[集卷].*?)(第?[#{NUMS}\d]+[#{TAGS}].*)$/,
    /^(第[#{NUMS}\d]+[集卷].*?)(（\p{N}+）.*)$/,
    /^【?(第[#{NUMS}\d]+[集卷])】?\s*(.+)$/,
  }

  def format_title(title : String, label = "正文", trim = false) : Tuple(String, String)
    title = fix_spaces(title).gsub("\n", "  ").strip

    LABEL_RE.each do |regex|
      next unless match = regex.match(title)

      _, label, title = match
      label = fix_spaces(label).strip

      break
    end

    title = fix_title(title, trim: false).gsub(/\s{2,}/, " ")
    {title, label == "正文" ? "" : label}
  end

  FIX_RE_0 = {
    /^第?([#{NUMS}\d]+)([#{TAGS}])[#{SEPS}]*(.*)$/, # generic
    /^\d+\.\s*第(.+)([#{TAGS}])[#{SEPS}]*(.*)/,     # 69shu 1
    /^第(.+)([#{TAGS}])\s\d+\.\s*(.*)/,             # 69shu 2
  }

  FIX_RE_1 = {
    /^([#{NUMS}\d]+)[#{SEPS}]+(.*)$/,
    /^\（(\p{N}+)\）[#{SEPS}]*(.*)$/,
  }

  private def fix_title(title : String, trim = false) : String
    FIX_RE_0.each do |regex|
      next unless match = regex.match(title)
      _, idx, tag, title = match
      return title.empty? ? "第#{idx}#{tag}" : "第#{idx}#{tag} #{title}"
    end

    FIX_RE_1.each do |regex|
      next unless match = regex.match(title)
      _, idx, title = match
      return title.empty? ? "#{idx}." : trim ? title : "#{idx}. #{title}"
    end

    title
  end
end

# pp CV::TextUtils.format_title("第二十集 红粉骷髅 第八章")
# pp CV::TextUtils.format_title("9205.第9205章")
# pp CV::TextUtils.format_title("340.番外：林薇实习（1）", trim: false)
# pp CV::TextUtils.format_title("【第006章】我的美女死党")
