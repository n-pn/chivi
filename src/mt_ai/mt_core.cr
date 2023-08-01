require "http/client"

require "./core/*"
require "./data/*"

class AI::MtCore
  def initialize(wn_id : Int32, uname : String = "")
    @dict = MtDict.new(wn_id, uname)
  end

  # def translate(data : MtNode, opts = MtOpts::Initial)
  #   String.build do |io|
  #     data.translate(io, @dict, opts)
  #   end
  # end

end

# def parse_file(input : String)
#   url = "localhost:5555/mtl/file?file=#{input}"
#   HTTP::Client.get(url) do |res|
#     raise "invalid: #{res.body_io.gets_to_end}" unless res.status.success?
#     # puts File.read(input.sub(".txt", ".con"))
#   end
# end

# def parse_line(input : String)
#   url = "localhost:5555/con/rand"

#   HTTP::Client.post(url, body: input) do |res|
#     puts res.body_io.gets_to_end
#   end
# end

# time = Time.measure do
#   # parse_line " “浅川同学。”一花笑吟吟道，“昨天下午的提议你考虑的怎么样了？” "
#   parse_file "/www/chivi/tmp/texts/sample.txt"
# end

# puts time
