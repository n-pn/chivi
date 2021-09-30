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

    FileUtils.mkdir_p(@out_dir)

    infos = File.read_lines(idx_file).map do |line|
      parts = line.split('\t')
      Chap.new(parts[0], parts[1], parts[2])
    end

    infos.each_slice(128).with_index do |slice, pgidx|
      output = TsvStore.new("#{@out_dir}/#{pgidx}.tsv")

      slice.map_with_index do |input, slice_idx|
        chidx = pgidx * 128 + slice_idx

        index = (chidx + 1).to_s
        return if stats = output.get(index)

        schid = fix_schid(input.schid).to_s
        stats = [schid, input.title, input.chvol]

        output.set!(index, stats)
      end

      output.save!(clean: true) if output.unsaved > 0
      puts "- <#{@sname}/#{@snvid}/#{pgidx}> saved, entries: #{slice.size}"
    end
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
    books = Dir.children("#{INP}/#{sname}")
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
