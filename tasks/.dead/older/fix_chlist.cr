require "file_utils"
require "compress/zip"
require "../src/_util/tsv_store"

DIR = "var/chtexts"

class CV::FixData
  def initialize(@sname : String, @snvid : String)
    @dir = "#{DIR}/#{@sname}/#{@snvid}"
  end

  def run!(redo = false)
    files = Dir.glob("#{@dir}/*.tsv").sort

    files.each do |file|
      pgidx = File.basename(file, ".tsv").to_i

      curr = chlist(pgidx)
      succ = chlist(pgidx + 1)

      wrong = ((pgidx + 1) * 128 + 1).to_s
      next unless stats = curr.get(wrong)
      curr.delete!(wrong)

      next if succ.get(wrong)
      succ.set!(wrong, stats)
      succ.save!
    end
  end

  @cache = {} of Int32 => TsvStore

  def chlist(pgidx : Int32)
    @cache[pgidx] ||= TsvStore.new("#{@dir}/#{pgidx}.tsv")
  end

  def self.run!(sname : String, snvid : String)
    new(sname, snvid).run!
  end

  def self.run_all!(sname : String)
    books = Dir.children("#{DIR}/#{sname}")
    books.each_with_index(1) do |snvid, idx|
      puts "\n[#{sname}] <#{idx}/#{books.size}> #{snvid}".colorize.cyan
      run!(sname, snvid)
    rescue err
      puts err
    end
  end
end

snames = ARGV.empty? ? Dir.children(DIR) : ARGV
snames.each { |sname| CV::FixData.run_all!(sname) }

# RebuildBook.new("hetushu", "1").run!
