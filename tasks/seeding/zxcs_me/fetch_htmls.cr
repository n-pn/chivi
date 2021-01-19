require "file_utils"
require "../../../src/_utils/http_utils"

INFO_DIR = File.join("_db/_seeds/zxcs_me/infos")
FileUtils.mkdir_p(INFO_DIR)

def info_link(s_nvid : Int32)
  "http://www.zxcs.me/post/#{s_nvid}"
end

def info_file(s_nvid : Int32)
  File.join INFO_DIR, "#{s_nvid}.html"
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
  queue.each_with_index(1) do |s_nvid, idx|
    mark = "#{idx}/#{queue.size}"

    save_html(info_link(s_nvid), info_file(s_nvid), mark)
    sleep Random.rand(500).milliseconds
  end
end

fetch_htmls(1, 12092)
