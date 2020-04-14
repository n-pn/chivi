require "json"
require "colorize"
require "file_utils"

require "../../src/kernel/chlists"
require "./models/my_book"

books = Array(MyBook).from_json(File.read("data/txt-tmp/serials.json"))

puts "- books: #{books.size} entries".colorize(:cyan)

FileUtils.rm_rf("data/txt-out/serials")
FileUtils.mkdir_p("data/txt-out/serials")

FileUtils.rm_rf("data/txt-out/chlists")
FileUtils.mkdir_p("data/txt-out/chlists")

# puts "- converting...".colorize(:cyan)

CTIME = ((ARGV[0]? || "2").to_i? || 2).hours
CLIST = Chlists.new

# update entries

def mtime(status)
  case status
  when 0
    CTIME
  when 1
    CTIME * 48
  else
    CTIME * 100
  end
end

def save_book(book, label) : Void
  site = book.prefer_site
  bsid = book.prefer_bsid

  unless site.empty?
    crawler = CrInfo.new(site, bsid, book.updated_at)

    if crawler.cached?(mtime(book.status))
      crawler.load_cached!(serial: true, chlist: true)
    else
      crawler.reset_cache(html: true)
      crawler.mkdirs!
      crawler.crawl!(label: label)
    end

    info = crawler.serial
    book.status = info.status unless book.status > info.status
    book.chap_count = info.chap_count unless book.chap_count > info.chap_count
    book.updated_at = info.updated_at unless book.updated_at > info.updated_at

    list = crawler.chlist
    puts "- <#{label}> [#{book.zh_slug}/#{site}/#{bsid}]: #{list.size} chapters".colorize(:blue)
    CLIST.save(site, bsid, list)
  end

  book.translate!
  File.write "data/txt-out/serials/#{book.vi_slug}.json", book.to_pretty_json
end

limit = 20
channel = Channel(Nil).new(limit)

books.each_with_index do |book, idx|
  channel.receive unless idx < limit
  spawn do
    save_book(book, "#{idx + 1}/#{books.size}")
    channel.send(nil)
  end
end

limit.times { channel.receive }
