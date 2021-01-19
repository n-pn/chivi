require "file_utils"
require "../../../src/_utils/http_utils"

INFO_DIR = File.join("var/seeds/zxcs_me/htmls/infos")
FileUtils.mkdir_p(INFO_DIR)

def info_link(sbid : Int32)
  "http://www.zxcs.me/post/#{sbid}"
end

def info_file(sbid : Int32)
  File.join INFO_DIR, "#{sbid}.html"
end

def save_html(link : String, file : String, mark = "1/1")
  if File.exists?(file)
    puts "- <#{mark}> [#{File.basename(file)}] existed, skipping...".colorize.cyan
    return
  end

  puts "- <#{mark}> HIT: [#{link}]".colorize.green

  html = HttpUtils.get_html(link)
  File.write(file, html)
rescue err
  puts err.colorize.red
end

def fetch_htmls(lower = 1, upper = 12092)
  queue = (lower..upper).to_a.shuffle
  queue.each_with_index do |sbid, idx|
    mark = "#{idx + 1}/#{queue.size}"

    save_html(info_link(sbid), info_file(sbid), mark)
    sleep Random.rand(500).milliseconds
  end
end

fetch_htmls(1, 12092)
