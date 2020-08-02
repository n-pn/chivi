require "zip"
require "json"
require "colorize"
require "file_utils"

require "../src/appcv/models/book_info"

infos = VpInfo.load_all.reject do |ubid, info|
  info.cr_sitemap.empty?
end
infos = infos.values.sort_by(&.tally.-)

puts "- input: #{infos.size} entries".colorize(:cyan)

HTML_DIR = File.join("data", ".inits", "txt-inp")
TEXT_DIR = File.join("data", "zh_texts")

infos.each_with_index do |info, idx|
  info.cr_sitemap.each do |site, bsid|
    text_dir = File.join(TEXT_DIR, "#{info.ubid}.#{site}.#{bsid}")
    next unless File.exists?(text_dir)

    html_dir = File.join(HTML_DIR, site, "texts", bsid)
    next unless File.exists?(html_dir)

    puts "- <#{idx + 1}/#{infos.size}> #{info.zh_title.colorize(:blue)} #{info.zh_author.colorize(:blue)} #{site.colorize(:blue)} #{bsid.colorize(:blue)}"

    keep_dir = "/mnt/e/Asset/chivi/#{site}/#{bsid}"
    FileUtils.mkdir_p(keep_dir)

    files = Dir.children(html_dir)
    files.each do |file|
      FileUtils.cp(File.join(html_dir, file), File.join(keep_dir, file))
    end

    FileUtils.rm_rf(html_dir)
  end
end
