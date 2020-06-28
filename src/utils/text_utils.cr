module Utils
  def self.split_lines(input : String)
    input.split("\n").map(&.strip).reject(&.empty?)
  end

  def self.split_words(input : String)
    input = slugify(input)

    output = [] of String
    acc = ""

    input.each_char do |char|
      if char.ascii_alphanumeric?
        acc += char
        next
      end

      unless acc.empty?
        output << acc
        acc = ""
      end

      word = char.to_s
      output << word if word =~ /[\p{Han}\p{Hiragana}\p{Katakana}\p{L}]/
    end

    output << acc unless acc.empty?
    output.uniq
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
