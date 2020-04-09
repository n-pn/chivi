require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/crawls/cr_info"
require "../../src/crawls/cr_text"

PAGE_URL = "https://novel.zhwenpg.com/?page=%i"

LOCATION = Time::Location.fixed(3600 * 8)

def fetch_page(crawlers, page = 1) : Void
  puts "PAGE: #{page}"
  html_file = "data/txt-inp/zhwenpg/pages/#{page}.html"

  page_url = PAGE_URL % page
  if CrUtil.outdated?(html_file, time: 3.hours)
    html = CrUtil.fetch_html(page_url, "zhwenpg")
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
    updated_at = Time.parse(updated.inner_text, "%F", LOCATION)

    crawlers[bsid] = fetch_info(bsid, updated_at, "#{idx + 1}/#{tables.size}")
  end
end

def fetch_info(bsid : String, updated_at : Time, label = "1/1")
  cache_span = Time.utc - updated_at

  crawler = CrInfo.new("zhwenpg", bsid, updated_at.to_unix_ms)
  if crawler.cached?(cache_span, require_html: true)
    crawler.load_cached!
  else
    # crawler.reset_cache(html: true)
    crawler.crawl!(persist: true, label: label)
  end

  crawler
end

def fetch_text(bsid, chap, index = 0)
  crawler = Crawl::Text.new("zhwenpg", bsid, chap._id, chap.title, chap.mtime)
  crawler.crawl!(persist: true, index: index) # unless crawler.cached?(require_html: true)
end

crawlers = {} of String => CrInfo
1.upto(12) { |page| fetch_page(crawlers, page) }

indexing = {} of String => String
crawlers.each do |bsid, crawler|
  indexing[crawler.serial.slug] = bsid
end

File.write "data/txt-tmp/sitemap/zhwenpg.json", indexing.to_pretty_json

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
