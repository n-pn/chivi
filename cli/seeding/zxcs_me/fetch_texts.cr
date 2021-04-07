require "file_utils"
require "compress/gzip"
require "myhtml"

require "../../../src/utils/http_utils"

DLPG_DIR = File.join("_db/.cache/zxcs_me/htmls/dlpgs")
TEXT_DIR = File.join("_db/.cache/zxcs_me/texts/batch")

FileUtils.mkdir_p(DLPG_DIR)
FileUtils.mkdir_p(TEXT_DIR)

def dlpg_link(snvid : Int32) : String
  "http://www.zxcs.me/download.php?id=#{snvid}"
end

def html_file(snvid : Int32) : String
  File.join DLPG_DIR, "#{snvid}.html"
end

def chap_file(snvid : Int32) : String
  File.join TEXT_DIR, "#{snvid}.rar"
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

def save_file(url : String, snvid : Int32) : Nil
  file = chap_file(snvid)

  # skipping downloaded files, unless they are 404 pages
  return if File.exists?(file) # && File.size(file) > 1000

  HTTP::Client.get(url) { |res| File.write(file, res.body_io) }
  puts "- Saving [#{File.basename(url).colorize.green}] \
          to [#{File.basename(file).colorize.green}], \
          filesize: #{File.size(file)} bytes"
end

def file_saved?(snvid : Int32)
  return true if File.exists?("_db/_seeds/zxcs_me/texts/fixed/#{snvid}.txt")
  return true if File.exists?("_db/_seeds/zxcs_me/texts/unrar/#{snvid}.txt")
end

def fetch_files(lower = 1, upper = 12092) : Nil
  queue = (lower..upper).to_a.shuffle
  queue.each_with_index(1) do |snvid, idx|
    next if file_saved?(snvid)

    mark = "#{idx}/#{queue.size}"

    html = load_html(dlpg_link(snvid), html_file(snvid), mark)
    urls = extract_dll(html)
    next if urls.empty?

    urls.reverse_each { |url| save_file(url, snvid) }
  rescue err
    puts err.colorize.red
  end
end

fetch_files(1, 12092)
