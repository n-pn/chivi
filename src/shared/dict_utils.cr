require "./consts/normalize"

module CV::DictUtils
  extend self

  # Convert chinese punctuations to english punctuations
  # and full width characters to ascii characters
  def normalize(input : String) : Array(Char)
    normalize(input.chars)
  end

  # :ditto:
  def normalize(input : Array(Char)) : Array(Char)
    input.map { |char| normalize(char) }
  end

  # :ditto:
  def normalize(char : Char) : Char
    NORMALIZE.fetch(char, char)
  end

  # convert chinese numbers to latin numbers
  # TODO: Handle bigger numbers
  def to_integer(str : String) : Int64
    str.to_i64?.try { |x| return x } # return early if input is an ascii number

    res = 0_i64
    mod = 1_i64
    acc = 0_i64

    str.chars.reverse_each do |char|
      int = to_integer(char)

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

  # :ditto:
  def to_integer(char : Char)
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
end

# puts CV::DictUtils.normalize("０")
# puts CV::DictUtils.normalize('０')

# puts CV::DictUtils.to_integer("1245")
# puts CV::DictUtils.to_integer("四")
