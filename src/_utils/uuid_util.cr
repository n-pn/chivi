require "digest"

module UuidUtil
  extend self

  def gen_ubid(title : String, author : String)
    digest32("#{title}--#{author}")
  end

  CHARS = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k',
    'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x',
    'y', 'z',
  }

  def digest32(input : String, limit = 8)
    length = (limit * 6 / 5).ceil.to_i
    digest = Digest::SHA1.hexdigest(input)
    number = digest[0, length].to_i64(base: 16)

    String.build do |io|
      limit.times do
        io << CHARS[number % 32]
        number //= 32
      end
    end
  end
end

# puts UuidUtil.digest32("aaaa")
