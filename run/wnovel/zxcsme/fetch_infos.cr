require "http/client"
require "lexbor"

require "../../../src/_util/http_util"

HTML_DIR = "var/seeds/zxcs.me/infos"
Dir.mkdir_p(HTML_DIR)

def still_fresh?(zip_file : String)
  return false unless info = File.info?(zip_file)
  info.modification_time > Time.utc - 15.days
end

# run!

sb_ids = 14930.downto(1).to_a

sb_ids.each_with_index(1) do |sb_id, idx|
  htm_file = "#{HTML_DIR}/#{sb_id}.htm"
  next if still_fresh?(htm_file)

  info_url = "http://www.zxcs.info/post/#{sb_id}"
  puts "- <#{idx}:#{sb_id}> HIT: #{info_url}".colorize.magenta
  File.write(htm_file, HttpUtil.fetch(info_url))
rescue ex
  puts ex
end
