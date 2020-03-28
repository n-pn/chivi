require "json"
require "colorize"
require "file_utils"

require "./serials/*"

puts "- Save chlists...".colorize(:cyan)

files = Dir.glob("data/txt-out/serials/*.json")
files.each_with_index do |file, idx|
  output = MyBook.from_json File.read(file)
  next if output.favor_crawl.empty?

  site = output.favor_crawl
  bsid = output.crawl_links[site]

  out_dir = "data/txt-out/chlists/#{site}"
  FileUtils.mkdir_p(out_dir)
  out_file = File.join(out_dir, "#{bsid}.json")

  # next if File.exists?(out_file)
  puts "- <#{idx + 1}/#{files.size}> [#{output.vi_slug}/#{site}/#{bsid}]".colorize(:blue)

  chfile = "data/txt-tmp/chlists/#{site}/#{bsid}.json"
  chlist = CrInfo::ChList.from_json(File.read(chfile))

  out_list = chlist.map_with_index { |x, i| MyChap.new(x, i, site, bsid) }
  File.write out_file, out_list.to_pretty_json
rescue err
  puts err
end
