require "digest"

module CV::CoreUtils
  extend self

  BASE_32 = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k',
    'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x',
    'y', 'z',
  }

  # return semi unique hash string
  def digest32(input : String, limit : Int32 = 8)
    digest = Digest::SHA1.hexdigest(input)
    length = (limit &* 6 / 5).ceil.to_i

    number = digest[0, length].to_i64(base: 16)
    encode32(number).rjust(limit, '0')
  end

  # convert integer to zbase32
  def encode32(number : Int32 | Int64)
    String.build do |io|
      while number >= 32
        io << BASE_32.unsafe_fetch(number % 32)
        number //= 32
      end

      io << BASE_32.unsafe_fetch(number)
    end
  end

  # convert zbase32 to integer
  def decode32(input : String)
    number = 0_i64

    input.chars.reverse_each do |char|
      number = number &* 32 &+ map32(char)
    end

    number
  end

  private def map32(char : Char)
    case char
    when '0', 'o', 'O'           then 0
    when '1', 'l', 'L', 'i', 'I' then 1
    when '2'                     then 2
    when '3'                     then 3
    when '4'                     then 4
    when '5'                     then 5
    when '6'                     then 6
    when '7'                     then 7
    when '8'                     then 8
    when '9'                     then 9
    when 'a', 'A'                then 10
    when 'b', 'B'                then 11
    when 'c', 'C'                then 12
    when 'd', 'D'                then 13
    when 'e', 'E'                then 14
    when 'f', 'F'                then 15
    when 'g', 'G'                then 16
    when 'h', 'H'                then 17
    when 'j', 'J'                then 18
    when 'k', 'K'                then 19
    when 'm', 'M'                then 20
    when 'n', 'N'                then 21
    when 'p', 'P'                then 22
    when 'q', 'Q'                then 23
    when 'r', 'R'                then 24
    when 's', 'S'                then 25
    when 't', 'T'                then 26
    when 'v', 'V', 'u', 'U'      then 27
    when 'w', 'W'                then 28
    when 'x', 'X'                then 29
    when 'y', 'Y'                then 30
    when 'z', 'Z'                then 31
    else                              0
    end
  end
end

# puts CV::CoreUtils.digest32("95410")
# puts CV::CoreUtils.encode32(95410).ljust(8, '0')
# puts CV::CoreUtils.decode32("j5x20000")
# puts CV::CoreUtils.decode32("j5x20")
