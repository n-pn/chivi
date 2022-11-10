require "log"
require "http/client"

class TL::POSTagger
  def initialize
    @client = HTTP::Client.new(URI.parse("http://localhost:5401"))
  end

  private def call(body : String)
    @client.post("/pos", body: body) do |res|
      body = res.body_io.gets_to_end.strip
      body.split('\n').map(&.split('\t'))
    end
  end

  def tag!(words : Array(String))
    call(words.join('\t')).first
  end

  def tag!(lines : Array(Array(String)))
    body = String.build do |str|
      lines.each_with_index do |line, i|
        str << '\n' unless i == 0
        line.join(str, '\t')
      end
    end

    call(body)
  end
end

tagger = TL::POSTagger.new

puts tagger.tag!(["我", "的", "希望", "是", "希望", "的", "世界", "和平"])
puts tagger.tag!([["我", "的", "希望", "是", "希望"], ["希望", "是", "世界"]])
