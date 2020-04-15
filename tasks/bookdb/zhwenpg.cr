require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/spider/info_crawler"
require "../../src/entity/vsite"
# require "../../src/crawls/cr_text"

PAGE_URL = "https://novel.zhwenpg.com/?page=%i"

LOCATION = Time::Location.fixed(3600 * 8)

def fetch_page(sbooks, page = 1) : Void
  puts "PAGE: #{page}"
  html_file = "data/txt-inp/zhwenpg/pages/#{page}.html"

  page_url = PAGE_URL % page
  if CrawlUtil.outdated?(html_file, time: 3.hours)
    html = CrawlUtil.fetch_html(page_url, "zhwenpg")
    File.write(html_file, html)
  else
    html = File.read(html_file)
  end

  doc = Myhtml::Parser.new(html)

  tables = doc.css(".cbooksingle").to_a[2..-2]

  tables.each_with_index do |table, idx|
    rows = table.css("tr").to_a

    title = rows[0].css("a").first
    bsid = title.attributes["href"].sub("b.php?id=", "")

    updated = rows[3].css(".fontime").first
    time = Time.parse(updated.inner_text, "%F", LOCATION)

    sbooks[bsid] = fetch_info(bsid, time, "#{idx + 1}/#{tables.size}")
  end
end

def fetch_info(bsid : String, time : Time, label = "1/1")
  cache_span = Time.utc - time

  crawler = InfoCrawler.new("zhwenpg", bsid, time.to_unix_ms)
  if crawler.cached?(cache_span, require_html: true)
    crawler.load_cached!(slist: false)
  else
    crawler.reset_cache(html: true)
    crawler.crawl!(persist: true, label: label)
  end

  crawler.sbook
end

# def fetch_text(bsid, chap, index = 0)
#   crawler = Crawl::Text.new("zhwenpg", bsid, chap._id, chap.title, chap.mtime)
#   crawler.crawl!(persist: true, index: index) # unless crawler.cached?(require_html: true)
# end

FileUtils.mkdir_p("data/txt-tmp/serials/zhwenpg")
FileUtils.mkdir_p("data/txt-tmp/chlists/zhwenpg")

sbooks = {} of String => SBook
1.upto(12) { |page| fetch_page(sbooks, page) }

mapping = {} of String => VSite
sbooks.each do |bsid, sbook|
  mapping[sbook.label] = VSite.new(sbook)
end

File.write "data/txt-tmp/sitemap/zhwenpg.json", mapping.to_pretty_json

# input = Array(Crawl::Item).from_json File.read(".out/indexes/tocrawl.json")
# input = input.select(&.match?("zhwenpg"))

# input.each_with_index do |item, idx|
#   site = item.favor_crawl
#   bsid = item.crawl_links[site]

#   FileUtils.mkdir_p(".inp/zhwenpg/texts/#{bsid}")
#   FileUtils.mkdir_p(".tmp/chtexts/zhwenpg/#{bsid}")

#   crawler = CRAWLERS[bsid]
#   puts "- <#{idx + 1}/#{input.size}> [#{item.vi_slug}]: #{crawler.chapters.size} chapters".colorize(:yellow)

#   crawler.chapters.reverse.each_with_index do |chap, cid|
#     fetch_text(bsid, chap, index: cid)
#   end

#   word_count = 0
#   Dir.glob(".tmp/chtexts/zhwenpg/#{bsid}/*.txt").each do |f|
#     word_count += File.read(f).size
#   end

#   crawler.metadata.word_count = word_count
#   File.write crawler.info_file, crawler.metadata.to_pretty_json
# end
