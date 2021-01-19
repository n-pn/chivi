require "file_utils"
require "myhtml"

require "../../../src/_utils/http_utils"

DLPG_DIR = File.join("_db/_seeds/zxcs_me/htmls/dlpgs")
FileUtils.mkdir_p(DLPG_DIR)

TEXT_DIR = File.join("_db/_seeds/zxcs_me/texts/batch")
FileUtils.mkdir_p(TEXT_DIR)

def dlpg_link(s_nvid : Int32) : String
  "http://www.zxcs.me/download.php?id=#{s_nvid}"
end

def html_file(s_nvid : Int32) : String
  File.join DLPG_DIR, "#{s_nvid}.html"
end

def chap_file(s_nvid : Int32) : String
  File.join TEXT_DIR, "#{s_nvid}.rar"
end

def load_html(link : String, file : String, mark = "1/1") : String
  if File.exists?(file)
    puts "- <#{mark}> [#{File.basename(file)}] existed, skipping...".colorize.light_blue
    File.read(file)
  else
    HttpUtils.get_html(link).tap { |html| File.write(file, html) }
  end
end

def extract_dll(html : String) : Array(String)
  doc = Myhtml::Parser.new(html)
  doc.css(".downfile > a").to_a.map do |node|
    node.attributes["href"].not_nil!
  end
end

def save_file(url : String, s_nvid : Int32) : Nil
  file = chap_file(s_nvid)

  # skipping downloaded files, unless they are 404 pages
  return if File.exists?(file) # && File.size(file) > 1000

  HTTP::Client.get(url) { |res| File.write(file, res.body_io) }
  puts "- Saving [#{File.basename(url).colorize.green}] \
          to [#{File.basename(file).colorize.green}], \
          filesize: #{File.size(file)} bytes"
end

def file_saved?(s_nvid : Int32)
  return true if File.exists?("_db/_seeds/zxcs_me/texts/fixed/#{s_nvid}.txt")
  return true if File.exists?("_db/_seeds/zxcs_me/texts/unrar/#{s_nvid}.txt")
end

def fetch_files(lower = 1, upper = 12092) : Nil
  queue = (lower..upper).to_a.shuffle
  queue.each_with_index(1) do |s_nvid, idx|
    next if file_saved?(s_nvid)

    mark = "#{idx}/#{queue.size}"

    html = load_html(dlpg_link(s_nvid), html_file(s_nvid), mark)
    urls = extract_dll(html)
    next if urls.empty?

    urls.reverse_each { |url| save_file(url, s_nvid) }
  rescue err
    puts err.colorize.red
  end
end

fetch_files(1, 12092)
