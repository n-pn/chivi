require "json"
require "file_utils"

mapping = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

alias Crawl = Tuple(String, String, String, Int32, Int64)
input = Array(Crawl).from_json File.read(".out/crawls.json")

input.each do |site, bsid|
  mapping[site] << bsid
end

mapping.each do |site, book_ids|
  html_dir = ".inp/#{site}/texts"
  text_dir = ".tmp/chtexts/#{site}"

  html_ids = Dir.children(html_dir)
  text_ids = Dir.children(text_dir)

  unneeded = (html_ids + text_ids) - book_ids
  unneeded.uniq.each do |book_id|
    puts "#{site}/#{book_id}"
    FileUtils.rm_rf File.join(text_dir, book_id)
    FileUtils.rm_rf File.join(html_dir, book_id)
  end
end
