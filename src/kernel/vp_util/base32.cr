module VpUtil::Base32
  extend self

  B32 = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c',
         'd', 'e', 'f', 'g', 'h', 'j', 'k', 'm', 'n', 'p', 'q', 'r', 's',
         't', 'v', 'w', 'x', 'y', 'z'}

  def encode(int : Int64) : String
    String.build do |io|
      while int >= 32
        io << B32[int % 32]
        int //= 32
      end
      io << B32[int]
    end
  end

  def decode(str : String) : Int64
    int = 0_i64
    str.chars.reverse_each do |char|
      int = int * 32 + lookup(char)
    end

    int
  end

  private def lookup(chr : Char)
    case chr
    when '0', 'o', 'O'           then 0
    when '1', 'i', 'I', 'l', 'L' then 1
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
    when 'v', 'V'                then 27
    when 'w', 'W'                then 28
    when 'x', 'X'                then 29
    when 'y', 'Y'                then 30
    when 'z', 'Z'                then 31
    else                              0
    end
  end
end
