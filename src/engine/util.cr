require "./util/*"

module Engine::Util
  extend self

  # capitalize all words
  def titlecase(input : String)
    input.split(" ").map { |x| capitalize(x) }.join(" ")
  end

  # don't downcase extra characters
  def capitalize(str : String) : String
    return str if str.empty?
    str[0].upcase + str[1..]
  end

  def slugify(input : String, no_accent = false)
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

  # read chinese text file and strip whitespaces
  def read_lines(input : String) : Array(String)
    split_lines(File.read(input))
  end

  # Split text to lines, strip empty whitespaces
  def split_lines(input : String) : Array(String)
    input.split("\n").map(&.tr("　", " ").strip).reject(&.empty?)
  end

  # convert chinese numbers to latin numbers
  # def hanzi_int(input)
  #   HANZI_INT.fetch(input, input)
  # end

  def hanzi_int(input : String)
    # TODO: Handle bigger numbers

    res = 0
    mod = 1
    acc = 0

    chars = input.chars
    (chars.size - 1).downto(0) do |idx|
      char = chars[idx]

      case char
      when '千'
        res += acc
        acc = 1000
        mod = acc if mod < acc
      when '百'
        res += acc
        acc = 100
        mod = acc if mod < acc
      when '十'
        acc = 10
      else
        res += char_to_num(char) * mod
        acc = 0
        mod *= 10
      end
    end

    res + acc
  end

  def char_to_num(char : Char)
    case char
    when '零' then 0
    when '〇' then 0
    when '一' then 1
    when '二' then 2
    when '三' then 3
    when '四' then 4
    when '五' then 5
    when '六' then 6
    when '七' then 7
    when '八' then 8
    when '九' then 9
    when .ascii_number?
      char.to_i
    else
      raise ArgumentError.new("Unknown char: #{char}")
    end
  end
end

# puts Engine::Util.hanzi_int("1203")
# puts Engine::Util.hanzi_int("十")
# puts Engine::Util.hanzi_int("十七")
# puts Engine::Util.hanzi_int("二十")
# puts Engine::Util.hanzi_int("二十七")
# puts Engine::Util.hanzi_int("百")
# puts Engine::Util.hanzi_int("百零五")
# puts Engine::Util.hanzi_int("百十五")
# puts Engine::Util.hanzi_int("八百零五")
# puts Engine::Util.hanzi_int("八百三十五")
# puts Engine::Util.hanzi_int("四千零七")
# puts Engine::Util.hanzi_int("四千八百零七")
# puts Engine::Util.hanzi_int("四千二百一十七")
# puts Engine::Util.hanzi_int("九九九〇")
