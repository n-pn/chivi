require "log"
require "http/client"

class HanLP
  def initialize
    @client = HTTP::Client.new(URI.parse("http://localhost:5401"))
  end

  def tok!(input : String)
    post_data("/tok", input).first
  end

  def tok!(lines : Array(String))
    post_data("/tok", encode(lines))
  end

  def tag!(words : Array(String))
    post_data("/pos", encode(words)).first
  end

  def tag!(lines : Array(Array(String)))
    post_data("/pos", encode(lines))
  end

  private def encode(input : Array(String))
    input.join('\t')
  end

  private def encode(input : Array(Array(String)))
    String.build do |str|
      input.each_with_index do |line, i|
        str << '\n' unless i == 0
        line.join(str, '\t')
      end
    end
  end

  private def post_data(uri : String, body : String)
    @client.post(uri, body: body) do |res|
      body = res.body_io.gets_to_end
      body.strip.split('\n').map(&.split('\t'))
    end
  end
end

# hanlp = HanLP.new
# puts hanlp.tok!("缪大爷")
# puts hanlp.tag!(["缪大爷"])
# puts hanlp.tag!(["缪", "大爷"])

# puts hanlp.tok!("我的希望是希望的世界和平")
# puts hanlp.tag!(["我", "的", "希望", "是", "希望", "的", "世界", "和平"])
# puts hanlp.tag!([["我", "的", "希望", "是", "希望"], ["希望", "是", "世界"]])
