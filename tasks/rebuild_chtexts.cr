require "file_utils"
require "compress/zip"

INP = "_db/chseed"
OUT = "db/chtexts"

record OldChap, schid : String, title : String, chvol : String do
  def to_s(x : Nil)
    {schid, title, chvol}.join("\t")
  end

  def to_s(x : Tuple(Int64, Int32, Int32))
    {schid, title, chvol, x[0], x[1], x[2]}.join("\t")
  end
end

class RebuildBook
  PART_LIMIT = 3000

  def initialize(@sname : String, @snvid : String)
    @inp_dir = "#{INP}/#{@sname}/#{@snvid}"
    @out_dir = "#{OUT}/#{@sname}/#{@snvid}"
  end

  def run!(redo = false)
    idx_file = "#{@inp_dir}/_id.tsv"
    return unless File.exists?(idx_file)

    return if File.exists?(@out_dir) && !redo
    FileUtils.mkdir_p(@out_dir)

    infos = File.read_lines(idx_file).map do |line|
      parts = line.split('\t')

      OldChap.new(parts[0], parts[1], parts[2])
    end

    infos.each_slice(128).with_index do |slice, page_idx|
      out_file = "#{@out_dir}/#{page_idx}.tsv"

      index = slice.map_with_index do |chinfo, slice_idx|
        chidx = page_idx * 128 + slice_idx
        stats = rebuild_chap(chidx, chinfo.schid)
        chinfo.schid = fix_schid(schid).to_s
        chinfo.to_s(stats)
      end

      File.write(out_file, index.join("\n"))
      puts "- <#{@sname}/#{@snvid}/#{page_idx}> saved, entries: #{index.size}"
    end
  end

  def rebuild_chap(chidx : Int32, schid : String)
    zip_name = chidx.//(100).to_s.rjust(3, '0')
    zip_file = "#{@inp_dir}/#{zip_name}.zip"
    return unless File.exists?(zip_file)

    out_zip = "#{@out_dir}/#{chidx // 128}.zip"
    fixed_schid = fix_schid(schid)

    Compress::Zip::File.open(zip_file) do |zip|
      return unless entry = zip["#{schid}.txt"]?

      mtime = entry.time
      texts = entry.open(&.gets_to_end)

      char_count = texts.size
      part_count = char_count./(PART_LIMIT).round.to_i
      part_count = 1 if part_count < 1
      char_count = char_count // part_count

      parts = split_parts(texts, char_count)

      parts.each_with_index do |part, idx|
        out_file = "#{@out_dir}/#{fixed_schid}-#{idx}.txt"
        File.write(out_file, part)
        FileUtils.touch(out_file, mtime)
        `zip -jqm #{out_zip} #{out_file}`
      end

      {mtime.to_unix, char_count, part_count}
    end
  end

  def fix_schid(schid : String)
    case @sname
    when "zxcs_me" then schid.to_i
    when "chivi"   then schid.to_i * 10
    else                schid
    end
  end

  def split_parts(texts : String, limit = PART_LIMIT)
    lines = texts.split("\n")
    parts = [[] of String]

    count = 0
    lines.each do |line|
      count += line.size

      if count > limit
        parts << [] of String
        count = 0
      end

      parts.last.push(line)
    end

    parts.map(&.join("\n"))
  end

  def self.run!(sname : String, snvid : String)
    new(sname, snvid).run!(redo: sname == "chivi")
  end

  def self.run_all!(sname : String)
    books = Dir.children("#{INP}/#{sname}")
    books.each_with_index(1) do |snvid, idx|
      puts "- <#{idx}/#{books.size}> #{sname}/#{snvid}"
      run!(sname, snvid)
    end
  end
end

snames = Dir.children(INP)
snames.each { |sname| RebuildBook.run_all!(sname) }

# RebuildBook.new("hetushu", "1").run!
