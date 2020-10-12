require "html"

module TextUtil
  extend self

  def split_html(input : String, split : String | Regex = /\s{2,}|\n+/)
    split_text(clean_html(input), split)
  end

  def clean_html(input : String)
    HTML.unescape(input)
      .gsub(/<br\s*\/?>/i, "\n")
      .gsub("【】", "")
      .gsub("...", "…")
  end

  def split_text(input : String, split : String | Regex = "\n")
    fix_spaces(input).split(split).map(&.strip).reject(&.empty?)
  end

  # replace unicode whitespaces with " "
  def fix_spaces(input : String)
    input.tr("\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000", " ")
  end

  # capitalize all words
  def titleize(input : String)
    input.split(" ").map { |x| capitalize(x) }.join(" ")
  end

  # don't downcase extra characters
  def capitalize(input : String) : String
    # TODO: handle punctuation?
    return input if input.blank?

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
end

# puts TextUtil.tokenize("Diablo Chi Hủy Diệt")
# puts TextUtil.split_words("abc")
# puts TextUtil.split_words("重返2008年")
# puts TextUtil.split_words("Trọng phản 2008 niên")
# puts TextUtil.slugify("Trọng phản 2008 niên", keep_accent: true)
# puts TextUtil.slugify("Trọng phản 2008 niên 重返2008年")

# pp '\u00A0'
