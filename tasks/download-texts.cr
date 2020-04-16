require "json"
require "colorize"
require "file_utils"

require "../src/entity/vbook"
require "../src/entity/schap"

require "../src/spider/html_crawler"
require "../src/spider/text_crawler"

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}

SITES.each { |site| HtmlCrawler.info_mkdir(site) }

files = File.read_lines("data/txt-out/hastext.txt").reverse
books = files.map { |file| }
puts "- books: #{files.size} entries".colorize(:cyan)

def download_text(site, bsid, chap, label) : Void
  crawler = TextCrawler.new(site, bsid, chap.csid, chap.title)
  crawler.crawl!(persist: true, label: label) unless crawler.existed?
end

def fetch_texts(site, bsid) : Void
  return if bsid.empty?

  list = SList.load(site, bsid)
  return if list.empty?

  HtmlCrawler.text_mkdir(site, bsid)

  limit = 20
  limit = list.size if limit > list.size
  channel = Channel(Nil).new(limit)

  list.each_with_index do |chap, idx|
    channel.receive unless idx < limit

    spawn do
      download_text(site, bsid, chap, "#{idx + 1}/#{list.size}")
      channel.send(nil)
    end
  end

  limit.times { channel.receive }
end

files.each_with_index do |file, idx|
  book = VBook.load(file, label: "#{idx + 1}/#{books.size}")
  fetch_texts(book.prefer_site, book.prefer_bsid)
end
