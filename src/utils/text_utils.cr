require "html"

module Utils
  def self.fix_genre(genre : String)
    return genre if genre.empty? || genre == "轻小说"
    genre.sub(/小说$/, "")
  end

  def self.split_text(text : String, split : String | Regex = /\s{2,}|\n+/)
    text = Utils.clean_text(text)
    Utils.split_lines(text, split)
  end

  def self.clean_text(text : String)
    text = HTML.unescape(text)
    text.gsub(/\p{Z}/, " ").gsub("【】", "").strip
  end

  def self.split_lines(text : String, split : String | Regex = "\n")
    text.gsub(/<br\s*\/?>/i, "\n").split(split).map(&.strip).reject(&.empty?)
  end

  def self.split_words(text : String)
    text = slugify(text)

    res = [] of String
    acc = ""

    text.each_char do |char|
      if char.ascii_alphanumeric?
        acc += char
        next
      end

      unless acc.empty?
        res << acc
        acc = ""
      end

      word = char.to_s
      res << word if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}\p{L}]/
    end

    res << acc unless acc.empty?
    res.uniq
  end

  # capitalize all words
  def self.titleize(input : String)
    input.split(" ").map { |x| capitalize(x) }.join(" ")
  end

  # don't downcase extra characters
  def self.capitalize(str : String) : String
    return str if str.empty?
    str[0].upcase + str[1..]
  end

  def self.slugify(input : String, no_accent = true)
    input = unaccent(input) if no_accent

    input.downcase
      .gsub(/[^\p{L}\p{N}_]/, "-")
      .split("-")
      .reject(&.empty?)
      .join("-")
  end

  def self.unaccent(input : String)
    input
      .tr("áàãạảAÁÀÃẠẢăắằẵặẳĂẮẰẴẶẲâầấẫậẩÂẤẦẪẬẨ", "a")
      .tr("éèẽẹẻEÉÈẼẸẺêếềễệểÊẾỀỄỆỂ", "e")
      .tr("íìĩịỉIÍÌĨỊỈ", "i")
      .tr("óòõọỏOÓÒÕỌỎôốồỗộổÔỐỒỖỘỔơớờỡợởƠỚỜỠỢỞ", "o")
      .tr("úùũụủUÚÙŨỤỦưứừữựửƯỨỪỮỰỬ", "u")
      .tr("ýỳỹỵỷYÝỲỸỴỶ", "y")
      .tr("đĐD", "d")
  end
end

# puts Utils.split_words("abc")
# puts Utils.split_words("重返2008年")
# puts Utils.split_words("Trọng phản 2008 niên")
