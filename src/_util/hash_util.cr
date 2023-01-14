require "digest"

module HashUtil
  extend self

  @@seed = 0

  def gen_ukey(seed = Time.utc)
    number = seed.to_unix_ms // 8 + @@seed
    @@seed = (@@seed + 1) % 128
    encode32(number).reverse
  end

  # return semi unique hash string
  def digest32(input : String, limit : Int32 = 8)
    digest = Digest::SHA1.hexdigest(input)
    length = (limit &* 6 / 5).ceil.to_i

    number = digest[0, length].to_i64(base: 16)
    encode32(number).ljust(limit, '0')
  end

  # from base16 to base32
  def hexto32(input : String, limit : Int32 = 8) : String
    number = input[0, (limit &* 6 / 5).ceil.to_i].to_i64(base: 16)
    encode32(number).ljust(limit, '0')
  end

  def rand_str(limit : Int32 = 8)
    String.build do |io|
      limit.times { io << B32_CF.sample }
    end
  end

  B32_CF = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k',
    'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x',
    'y', 'z',
  }

  # convert integer to zbase32
  def encode32(number : Int32 | Int64)
    buffer = String::Builder.new

    while number >= 32
      buffer << B32_CF.unsafe_fetch(number % 32)
      number //= 32
    end

    buffer << B32_CF.unsafe_fetch(number)
    buffer.to_s
  end

  # convert zbase32 to integer
  def decode32(input : String) : Int64
    number = 0_i64

    input.chars.reverse_each do |char|
      number &*= 32
      number &+= map32(char)
    end

    number
  end

  private def map32(char : Char)
    {% begin %}
      case char
      {% for val, idx in B32_CF %}
      when {{val}} then {{idx}}
      {% end %}
      when 'o' then 0
      when 'l', 'i' then 0
      when 'u' then 27
      else 0
      end
    {% end %}
  end

  BASIS = 0x811c9dc5_u32
  PRIME =   16777619_u32
  MASK  = 4294967295_u32

  def fnv_1a(inp : String)
    hash = BASIS

    inp.each_byte do |byte|
      hash ^= byte
      hash = hash &* PRIME
      hash &= MASK
    end

    hash
  end

  # B32_ZH = {
  #   '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b',
  #   'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'm',
  #   'n', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
  #   'y', 'z',
  # }

  # def encode32_zh(number : Int32 | Int64)
  #   buffer = String::Builder.new

  #   while number >= 32
  #     buffer << B32_ZH.unsafe_fetch(number % 32)
  #     number //= 32
  #   end

  #   buffer << B32_ZH.unsafe_fetch(number)
  #   buffer.to_s
  # end

  # # convert zbase32 to integer
  # def decode32_zh(input : String) : Int64
  #   number = 0_i64

  #   input.chars.reverse_each do |char|
  #     number &*= 32
  #     number &+= map32_zh(char)
  #   end

  #   number
  # end

  # private def map32_zh(char : Char) : Int32
  #   {% begin %}
  #     case char
  #     {% for val, idx in B32_ZH %}
  #     when {{val}} then {{idx}}
  #     {% end %}
  #     else
  #       0
  #     end
  #   {% end %}
  # end
end

# puts HashUtil.digest32("95410")
# puts HashUtil.encode32(95410).ljust(8, '0')
# puts HashUtil.decode32("j5x20000")
# puts HashUtil.decode32("j5x20")

# str = "28unvs22456465"
# int = HashUtil.decode32_zh(str)
# puts str, int, HashUtil.encode32_zh(int)

# puts HashUtil.encode32(125272284354752)
# puts HashUtil.gen_ukey
# puts HashUtil.gen_ukey
# puts HashUtil.gen_ukey
