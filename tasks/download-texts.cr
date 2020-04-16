require "json"
require "colorize"
require "file_utils"

require "../src/entity/vbook"
require "../src/entity/schap"

require "../src/spider/html_crawler"

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}
SITES.each { |site| HtmlCrawler.info_mkdir(site) }

files = File.read_lines("data/txt-out/hastext.txt").reverse
books = files.map { |file| }
puts "- books: #{files.size} entries".colorize(:cyan)

def download(file, label)
  book = VBook.load(file)
  site = book.prefer_site
  bsid = book.prefer_bsid

  return if bsid.empty?

  list = SList.load(site, bsid).reject! do |chap|
    File.exists?(HtmlCrawler.text_path(site, bsid, chap.csid))
  end

  return if list.empty?

  HtmlCrawler.text_mkdir(site, bsid)

  limit = 5
  limit = list.size if limit > list.size
  channel = Channel(Nil).new(limit)

  list.each_with_index do |chap, idx|
    channel.receive unless idx < limit
    spawn do
      HtmlCrawler.fetch_text(site, bsid, chap.csid)
      channel.send(nil)
    end
  end

  limit.times { channel.receive }
end

limit = 5
channel = Channel(Nil).new(limit)

files.each_with_index do |file, idx|
  channel.receive unless idx < limit
  spawn do
    download(file, "#{idx + 1}/#{books.size}")
    channel.send(nil)
  end
end

limit.times { channel.receive }
