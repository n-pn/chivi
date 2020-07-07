require "digest"

module Utils
  def self.gen_uuid(title : String, author : String)
    digest32("#{title}--#{author}")
  end

  def self.digest32(input : String)
    digest = Digest::SHA1.hexdigest(input)
    number = decode16(digest[0...10])
    encode32(number)
  end

  def self.decode16(string : String)
    number = 0_i64

    string.each_char do |char|
      number *= 16
      number += decode16(char)
    end

    number
  end

  def self.decode16(char : Char) : Int32
    case char
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

  BASE32 = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k',
    'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x',
    'y', 'z',
  }

  def self.encode32(number : Int64) : String
    String.build do |io|
      while number >= 32
        io << BASE32[number % 32]
        number //= 32
      end

      io << BASE32[number]
    end
  end

  # TODO: decode32?
end

# puts Utils.digest32("dfsfsdfsd3453452524352523434fsdfs")
