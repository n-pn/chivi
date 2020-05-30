require "json"
require "colorize"
require "file_utils"

require "../src/bookdb/book_info"
require "../src/bookdb/chap_list"

require "../src/spider/info_spider"
require "../src/spider/text_spider"

def fetch_text(file : String, site : String, bsid : String, chap : ZhChap, label : String) : Void
  return if File.exists?(file)

  crawler = TextSpider.load(site, bsid, chap.csid)
  title = crawler.get_title!
  paras = crawler.get_paras!

  puts "-- <#{label.colorize(:blue)}> [#{site}-#{bsid}] #{title.colorize(:blue)}"
  File.open(file, "w") do |io|
    io << title
    paras.each { |para| io << "\n" << para }
  end
rescue err
  puts "-- <#{label.colorize(:red)}> #{err.colorize(:red)}"
  File.write(file, chap.title)
  File.delete SpiderUtil.text_path(site, bsid, chap.csid)
end

LIST_DIR = File.join("data", "zh_lists")

TEXT_DIR = File.join("data", "zh_texts")
FileUtils.mkdir_p(TEXT_DIR)

def fetch_book(info, label)
  site = info.cr_site_df
  bsid = info.cr_anchors[site]

  name = "#{info.uuid}.#{site}.#{bsid}"

  list_file = File.join(LIST_DIR, "#{name}.json")
  return unless File.exists?(list_file)

  text_dir = File.join(TEXT_DIR, name)
  FileUtils.mkdir_p(text_dir)

  FileUtils.mkdir_p(SpiderUtil.text_dir(site, bsid))

  chaps = ZhList.from_json(File.read(list_file))
  puts "- <#{label.colorize(:cyan)}> [#{site}-#{bsid}-#{info.title_zh}] #{chaps.size.colorize(:cyan)} entries"

  limit = 4
  limit = chaps.size if limit > chaps.size
  channel = Channel(Nil).new(limit)

  chaps.each_with_index do |chap, idx|
    channel.receive unless idx < limit

    spawn same_thread: true do
      file = File.join(text_dir, "#{chap.csid}.txt")
      fetch_text(file, site, bsid, chap, "#{idx + 1}/#{chaps.size}")
      channel.send(nil)
    end
  end

  limit.times { channel.receive }
end

crawls = VpInfo.load_all.reject do |uuid, info|
  info.cr_anchors.empty?
end

puts "- to crawl: #{crawls.size} entries".colorize(:cyan)

limit = 4
channel = Channel(Nil).new(limit)

crawls.values.sort_by(&.tally.-).each_with_index do |info, idx|
  channel.receive unless idx < limit

  spawn do
    fetch_book(info, "#{idx + 1}/#{crawls.size}")
    channel.send(nil)
  end
end

limit.times { channel.receive }
