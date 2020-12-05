require "html"
require "colorize"

module Chivi::SeedUtils
  extend self

  LOCATION = Time::Location.fixed(3600 * 8) # chinese timezone
  DEF_TIME = Time.utc(2000, 1, 1)

  TIME_FMT = {
    "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T",
    "%F %T", "%F %R", "%F",
  }

  # parse remote info update times
  def parse_time(input : String) : Time
    TIME_FMT.each do |format|
      return Time.parse(input, format, LOCATION)
    rescue
      next
    end

    puts "[ERROR parsing time`#{input}`: unknown format!]".colorize.red
    DEF_TIME
  end

  def split_html(input : String, fix_br : Bool = true)
    input = HTML.unescape(input)
    input = fix_spaces(input)
    input = replace_br(input) if fix_br
    split_text(input)
  end

  def replace_br(input : String)
    input.gsub(/<br\s*\/?>|\s{2,}/i, "\n")
  end

  def split_text(input : String)
    input.split("\n").map(&.strip).reject(&.empty?)
  end

  SPACES = "\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000"

  def fix_spaces(input : String)
    input.tr(SPACES, " ")
  end

  # capitalize all words
  def titleize(input : String)
    input.split(' ').map { |x| capitalize(x) }.join(' ')
  end

  # smart capitalize:
  # - don't downcase extra characters
  # - treat unicode alphanumeric chars as upcase-able
  def capitalize(input : String) : String
    # TODO: handle punctuation?

    String.build do |io|
      uncap = true

      input.each_char do |char|
        if uncap && char.alphanumeric?
          io << char.upcase
          uncap = false
        else
          io << char
        end
      end
    end
  end

  # split input to words
  def tokenize(input : String, keep_accent : Bool = false)
    input = unaccent(input) unless keep_accent
    split_words(input.downcase)
  end

  # make url friendly string
  def slugify(input : String, keep_accent : Bool = false)
    tokenize(input, keep_accent).join("-")
  end

  # strip vietnamese accents
  def unaccent(input : String)
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
  def split_words(input : String)
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

  FIX_RE_0 = /^(第[#{NUMS}\d]+[集卷].*?)(第?[#{NUMS}\d]+[#{TAGS}].*)$/
  FIX_RE_1 = /^(第[#{NUMS}\d]+[集卷].*?)(（\p{N}+）.*)$/
  FIX_RE_2 = /^【?(第[#{NUMS}\d]+[集卷])】?\s*(.+)$/

  def fix_title(title : String, label = "正文")
    if match = FIX_RE_0.match(title) || FIX_RE_1.match(title) || FIX_RE_2.match(title)
      _, label, title = match
      label = fix_spaces(label)
    end

    "#{label}  #{format_title(title)}"
  end

  FORMAT_RE_0 = /^第?([#{NUMS}\d]+)([#{TAGS}])[#{SEPS}]*(.*)$/
  FORMAT_RE_1 = /^\d+\.\s*第(.+)([#{TAGS}])[#{SEPS}]*(.+)/ # 69shu 1
  FORMAT_RE_2 = /^第(.+)([#{TAGS}])\s\d+\.\s*(.+)/         # 69shu 2
  FORMAT_RE_3 = /^([#{NUMS}\d]+)[#{SEPS}]+(.*)$/
  FORMAT_RE_4 = /^\（(\p{N}+)\）[#{SEPS}]*(.*)$/

  def format_title(title : String)
    if match = FORMAT_RE_0.match(title)
      _, idx, tag, title = match
      return "第#{idx}#{tag} #{fix_spaces(title)}"
    end

    if match = FORMAT_RE_1.match(title) || FORMAT_RE_2.match(title)
      _, idx, tag, title = match
      return "第#{idx}#{tag} #{title}"
    end

    if match = FORMAT_RE_3.match(title) || FORMAT_RE_4.match(title)
      _, idx, title = match
      return "#{idx}. #{fix_spaces(title)}"
    end

    fix_spaces(title)
  end
end

# puts Chivi::SeedUtils.parse_time("5/14/2020 7:00:48 AM")
# puts Chivi::SeedUtils.parse_time("2020-09-08 10:00")
