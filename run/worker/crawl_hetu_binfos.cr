require "http/client"
require "../../src/_util/file_util"

MAX = 7496

MAX.downto(1) do |b_id|
  save_path = "var/.keep/rmbook/hetushu.com/#{b_id}.htm"
  next if FileUtil.status(save_path, ttl: Time.utc - 2.month) > 0

  link = "https://www.hetushu.com/book/#{b_id}/index.html"
  html = HTTP::Client.get(link, &.body_io.gets_to_end)

  File.write(save_path, html)
  puts "#{link} saved!"
end
