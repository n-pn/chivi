# require "zip"
# require "json"
# require "colorize"
# require "file_utils"

# require "../src/kernel/models/book_info"

# infos = VpInfo.load_all.reject do |ubid, info|
#   info.cr_sitemap.empty?
# end
# infos = infos.values.sort_by(&.tally.-)

# puts "- input: #{infos.size} entries".colorize(:cyan)

# HTML_DIR = File.join("var", ".inits", "txt-inp")
# TEXT_DIR = File.join("var", "zh_texts")

# infos.each_with_index do |info, idx|
#   info.cr_sitemap.each do |site, bsid|
#     text_dir = File.join(TEXT_DIR, "#{info.ubid}.#{site}.#{bsid}")
#     next unless File.exists?(text_dir)

#     html_dir = File.join(HTML_DIR, site, "texts", bsid)
#     next unless File.exists?(html_dir)

#     puts "- <#{idx + 1}/#{infos.size}> #{info.zh_title.colorize(:blue)} #{info.zh_author.colorize(:blue)} #{site.colorize(:blue)} #{bsid.colorize(:blue)}"

#     keep_dir = "/mnt/e/Asset/chivi/#{site}/#{bsid}"
#     FileUtils.mkdir_p(keep_dir)

#     files = Dir.children(html_dir)
#     files.each do |file|
#       FileUtils.cp(File.join(html_dir, file), File.join(keep_dir, file))
#     end

#     FileUtils.rm_rf(html_dir)
#   end
# end

# require "../src/shared/file_utils"

# INP = "_db/.cache"

# Dir.children(INP).each do |seed|
#   puts "- #{seed}"

#   dir = File.join(INP, seed, "infos")
#   next unless File.exists?(dir)
#   files = Dir.glob("#{dir}/*.html")

#   files.each_with_index do |file, idx|
#     puts "- <#{idx + 1}/#{files.size}> #{file}".colorize.blue
#   end
# end
