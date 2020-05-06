require "./cv_util/*"

module CvUtil
  def split_lines(input : String)
    input.split("\n").map(&.strip).reject(&.empty?)
  end

  # capitalize all words
  def titleize(input : String)
    input.split(" ").map { |x| capitalize(x) }.join(" ")
  end

  # don't downcase extra characters
  def capitalize(str : String) : String
    return str if str.empty?
    str[0].upcase + str[1..]
  end

  def slugify(input : String, no_accent = true)
    input = unaccent(input) if no_accent

    input.downcase
      .gsub(/[^\p{L}\p{N}_]/, "-")
      .split("-")
      .reject(&.empty?)
      .join("-")
  end

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

  # Convert chinese punctuations to english punctuations
  # and full width characters to ascii characters
  def normalize(char : Char) : Char
    NORMALIZE.fetch(char, char)
  end

  def normalize(input : Array(Char)) : Array(Char)
    input.map { |char| normalize(char) }
  end

  def normalize(input : String) : Array(Char)
    input.chars.map { |char| normalize(char) }
  end

  # convert chinese numbers to latin numbers
  # TODO: Handle bigger numbers
  def hanzi_int(input : String)
    return input.to_i64 unless input =~ /\D/
    # raise "Type mismatch [#{input}]" if input =~ /\d/

    res = 0_i64
    mod = 1_i64
    acc = 0_i64

    input.chars.reverse_each do |char|
      int = char_to_num(char)
      case char
      when '万', '千', '百', '十'
        res += acc
        mod = int if mod < int
        acc = int
      else
        res += int * mod
        mod *= 10
        acc = 0
      end
    end

    res + acc
  end

  private def char_to_num(char : Char)
    case char
    when '零' then 0
    when '〇' then 0
    when '一' then 1
    when '两' then 2
    when '二' then 2
    when '三' then 3
    when '四' then 4
    when '五' then 5
    when '六' then 6
    when '七' then 7
    when '八' then 8
    when '九' then 9
    when '十' then 10
    when '百' then 100
    when '千' then 1000
    when '万' then 10000
    when .ascii_number?
      char.to_i
    else
      raise ArgumentError.new("Unknown char: #{char}")
    end
  end

  extend self
end
