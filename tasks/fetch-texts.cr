require "json"
require "colorize"
require "file_utils"

require "../src/models/vp_info"

require "../src/bookdb/info_spider"
require "../src/bookdb/text_spider"

# def fetch_text(site, bsid, chap, label) : Void
#   crawler = TextCrawler.new(site, bsid, chap.csid, chap.title)
#   crawler.crawl!(persist: true, label: label) unless crawler.cached?
# rescue err
#   puts "ERROR: #{err.colorize(:red)}"
#   File.delete HtmlCrawler.text_path(site, bsid, chap.csid)
# end

# def cache_time(status)
#   case status
#   when 0
#     2.hours
#   when 1
#     10.days
#   else
#     100.days
#   end
# end

# def fetch_book(crawl : Crawl, label : String) : Void
#   site, bsid, slug, status, mtime = crawl

#   return if bsid.empty?

#   crawler = InfoCrawler.new(site, bsid, mtime)
#   if crawler.cached?(time: cache_time(status), require_html: true)
#     puts "- <#{label.colorize(:blue)}> cached, skipping"
#     crawler.load_cached!(slist: true)
#   else
#     crawler.reset_cache(html: true)
#     crawler.crawl!(persist: true, label: label)
#   end

#   list = crawler.slist
#   return if list.empty?

#   FileUtils.mkdir_p File.join("data", "txt-inp", site, "texts", bsid)
#   FileUtils.mkdir_p File.join("data", "txt-tmp", "chtexts", site, bsid)

#   limit = list.size
#   limit = 8 if limit > 8
#   channel = Channel(Nil).new(limit)

#   list.each_with_index do |chap, idx|
#     channel.receive unless idx < limit

#     spawn do
#       fetch_text(site, bsid, chap, "#{slug}: #{idx + 1}/#{list.size}")
#     ensure
#       channel.send(nil)
#     end
#   end

#   limit.times { channel.receive }
# end

crawls = VpInfo.load_all.reject do |uuid, info|
  info.cr_anchors.empty?
end

puts "- to crawl: #{crawls.size} entries".colorize(:cyan)

INP_DIR = File.join("data", ".inits", "txt-tmp", "zhtexts")
OUT_DIR = File.join("data", "zh_texts")
FileUtils.mkdir_p(OUT_DIR)

crawls.each do |uuid, info|
  site = info.cr_site_df
  bsid = info.cr_anchors[site]

  inp_dir = File.join(INP_DIR, site, bsid)
  next unless File.exists?(inp_dir)

  puts inp_dir
  out_dir = File.join(OUT_DIR, "#{uuid}.#{site}.#{bsid}")
  FileUtils.mv(inp_dir, out_dir)
end

# limit = 4
# channel = Channel(Nil).new(limit)

# crawls.each_with_index do |crawl, idx|
#   channel.receive unless idx < limit

#   spawn do
#     fetch_book(crawl, "#{crawl[2]}: #{idx + 1}/#{crawls.size}")
#   ensure
#     channel.send(nil)
#   end
# end

# limit.times { channel.receive }
