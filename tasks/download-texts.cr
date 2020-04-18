require "json"
require "colorize"
require "file_utils"

require "../src/entity/vbook"
require "../src/entity/schap"

require "../src/spider/html_crawler"
require "../src/spider/text_crawler"
require "../src/spider/info_crawler"

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}
SITES.each { |site| HtmlCrawler.info_mkdir(site) }

alias Crawl = Tuple(String, String, String, Int32, Int64)

def fetch_text(site, bsid, chap, label) : Void
  crawler = TextCrawler.new(site, bsid, chap.csid, chap.title)
  crawler.crawl!(persist: true, label: label) unless crawler.cached?
rescue err
  puts "ERROR: #{err.colorize(:red)}"
  File.delete HtmlCrawler.text_path(site, bsid, chap.csid)
end

def cache_time(status)
  case status
  when 0
    2.hours
  when 1
    10.days
  else
    100.days
  end
end

def fetch_book(crawl : Crawl, label : String) : Void
  site, bsid, slug, status, mtime = crawl

  return if bsid.empty?

  crawler = InfoCrawler.new(site, bsid, mtime)
  if crawler.cached?(time: cache_time(status))
    puts "- <#{label.colorize(:blue)}> cached, skipping"
    crawler.load_cached!(slist: true)
  else
    crawler.crawl!(persist: true, label: label)
  end

  list = crawler.slist
  return if list.empty?

  FileUtils.mkdir_p File.join("data", "txt-inp", site, "texts", bsid)
  FileUtils.mkdir_p File.join("data", "txt-tmp", "chtexts", site, bsid)

  limit = list.size
  limit = 8 if limit > 8
  channel = Channel(Nil).new(limit)

  list.each_with_index do |chap, idx|
    channel.receive unless idx < limit

    spawn do
      fetch_text(site, bsid, chap, "#{slug}: #{idx + 1}/#{list.size}")
    ensure
      channel.send(nil)
    end
  end

  limit.times { channel.receive }
end

crawls = Array(Crawl).from_json(File.read("data/txt-out/crawls.json"))

puts "- books: #{crawls.size} entries".colorize(:cyan)

limit = 4
channel = Channel(Nil).new(limit)

crawls.each_with_index do |crawl, idx|
  channel.receive unless idx < limit

  spawn do
    fetch_book(crawl, "#{crawl[2]}: #{idx + 1}/#{crawls.size}")
  ensure
    channel.send(nil)
  end
end

limit.times { channel.receive }
