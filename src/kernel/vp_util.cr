# require "./vp_util/*"
require "digest"

module VpUtil
  extend self

  def hash_id(str : String, len = 10)
    digest = Digest::SHA1.hexdigest(str)
    number = decode16(digest[0...len])
    encode32(number)
  end

  private def decode16(str : String)
    int = 0_i64
    str.each_char do |char|
      int = int * 16 + lookup(char)
    end

    int
  end

  private def lookup(chr : Char)
    case chr
    when '0' then 0
    when '1' then 1
    when '2' then 2
    when '3' then 3
    when '4' then 4
    when '5' then 5
    when '6' then 6
    when '7' then 7
    when '8' then 8
    when '9' then 9
    when 'a' then 10
    when 'b' then 11
    when 'c' then 12
    when 'd' then 13
    when 'e' then 14
    when 'f' then 15
    else          0
    end
  end

  B32 = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c',
         'd', 'e', 'f', 'g', 'h', 'j', 'k', 'm', 'n', 'p', 'q', 'r', 's',
         't', 'v', 'w', 'x', 'y', 'z'}

  private def encode32(int : Int64) : String
    String.build do |io|
      while int >= 32
        io << B32[int % 32]
        int //= 32
      end
      io << B32[int]
    end
  end
end

# puts VpUtil.hash_id("dfsfsdfsd3453452524352523434fsdfs")
