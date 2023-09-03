require "http/client"

# pp parse("(NP\n  (QP (CD 很多))\n  (DNP (NP (NN 医学) (NN 领域) (PU 、) (NN 制药) (NN 领域)) (DEG 的))\n  (NP (NN 专家)))")

def parse_file(file : String)
  url = "http://localhost:5555/hmeb/file?file=#{file}"
  Dir.mkdir_p(File.dirname(file).sub("chtext", "nlp_wn"))
  HTTP::Client.get(url) do |res|
    raise "invalid: #{res.body_io.gets_to_end}" unless res.status.success?
    # puts File.read(file.sub(".txt", ".con"))
  end
end

# def parse_line(input : String)
#   url = "localhost:5555/con/rand"

#   HTTP::Client.post(url, body: input) do |res|
#     puts res.body_io.gets_to_end
#   end
# end
time = Time.measure do
  # parse_line " “浅川同学。”一花笑吟吟道，“昨天下午的提议你考虑的怎么样了？” "
  parse_file "var/wnapp/chtext/27050/233-c7uus7-1.txt"
end

puts time
