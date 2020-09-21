require "../src/utils/http_util"

def fetch_info(sbid = 1, label = "1/1")
  file = "var/appcv/.cached/zxcs_me/infos/#{sbid}.html"

  if File.exists?(file)
    puts "- <#{label}> [#{sbid}] downloaded, skipping...".colorize.cyan
    return
  end

  url = "www.zxcs.me/post/#{sbid}"
  puts "- <#{label}> HIT: [#{url}]".colorize.blue

  html = HttpUtil.fetch_html(url, encoding: "UTF-8", tls: nil)
  File.write(file, html)
rescue err
  puts err.colorize.red
end

lower = 1
upper = 12092

queue = (lower..upper).to_a.shuffle
queue.each_with_index do |sbid, idx|
  fetch_info(sbid, "#{idx + 1}/#{queue.size}")
  sleep Random.rand(500).milliseconds
end
