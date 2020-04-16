require "json"
require "colorize"
require "file_utils"

require "../../src/entity/vchap"
require "../../src/entity/vbook"

RECONVERT = ARGV.includes?("reconvert")
FIRSTONLY = ARGV.includes?("firstonly")

DIR = "data/txt-out"
FileUtils.mkdir_p("#{DIR}/chlists")

SITES = {
  "hetushu", "jx_la", "rengshu",
  "xbiquge", "nofff", "duokan8",
  "paoshu8", "69shu", "zhwenpg",
}
SITES.each do |site|
  FileUtils.mkdir_p("#{DIR}/chlists/#{site}")
end

files = File.read_lines("#{DIR}/hastext.txt").reverse
books = files.map { |file| }
puts "- books: #{files.size} entries".colorize(:cyan)

def convert(file, label)
  print label
  book = VBook.load(file)

  book.scrap_sites.each do |site, meta|
    bsid = meta.bsid
    list = RECONVERT ? VList.new : VList.load(site, bsid)

    changed = list.absorb(SList.load(site, bsid))
    list.save!(site, bsid) if changed

    break if FIRSTONLY
  end
end

limit = 20
channel = Channel(Nil).new(limit)

files.each_with_index do |file, idx|
  channel.receive unless idx < limit
  spawn do
    convert(file, "#{idx + 1}/#{books.size}")
    channel.send(nil)
  end
end

limit.times { channel.receive }
