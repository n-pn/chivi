module Oldcv::Utils
  # convert chinese numbers to latin numbers
  # TODO: Handle bigger numbers
  def self.han_to_int(str : String)
    return str.to_i64 unless str =~ /\D/
    # raise "Type mismatch [#{str}]" if str =~ /\d/

    res = 0_i64
    mod = 1_i64
    acc = 0_i64

    str.chars.reverse_each do |char|
      int = han_to_int(char)

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

  def self.han_to_int(char : Char)
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
