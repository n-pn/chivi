require "file_utils"
require "compress/zip"

require "../src/cutil/tsv_store"
INP = "_db/chseed"
OUT = "db/chtexts"

class CV::RebuildBook
  record Chap, schid : String, title : String, chvol : String

  def initialize(@sname : String, @snvid : String)
    @inp_dir = "#{INP}/#{@sname}/#{@snvid}"
    @out_dir = "#{OUT}/#{@sname}/#{@snvid}"
  end

  def run!(redo = false)
    idx_file = "#{@inp_dir}/_id.tsv"
    return unless File.exists?(idx_file)

    Dir.glob("#{@out_dir}/*.tsv").each do |file|
      zip_file = file.sub("tsv", "zip")
      next unless File.exists?(zip_file)

      input = TsvStore.new(file)
      input.data.each do |chidx, infos|
        next if infos.size > 3
        input.set!(chidx, remap!(zip_file, infos))
      end

      input.save!(clean: true) if input.unsaved > 0
    end
  end

  def remap!(zip_file : String, infos : Array(String)) : Array(String)
    parts = chars = 0
    utime = 0_i64

    Compress::Zip::File.open(zip_file) do |zip|
      while true
        fpath = "#{infos[0]}-#{parts}.txt"
        break unless entry = zip[fpath]?
        lines = entry.open(&.gets_to_end).split('\n')

        etime = entry.time.to_unix
        utime = etime if utime < etime
        chars += lines.map(&.size).sum
        parts += 1
      end
    end

    infos << utime.to_s << chars.to_s << parts.to_s
  end

  def fix_schid(schid : String)
    case @sname
    when "zxcs_me" then schid.to_i
    when "chivi"   then schid.to_i * 10
    else                schid
    end
  end

  def self.run!(sname : String, snvid : String)
    new(sname, snvid).run!
  end

  def self.run_all!(sname : String)
    books = Dir.children("_db/chtran/#{sname}")
    books.each_with_index(1) do |snvid, idx|
      puts "\n[#{sname}] <#{idx}/#{books.size}> #{snvid}"
      run!(sname, snvid)
    rescue err
      puts err
    end
  end
end

snames = ARGV.empty? ? Dir.children(INP) : ARGV
snames.each { |sname| CV::RebuildBook.run_all!(sname) }

# RebuildBook.new("hetushu", "1").run!
