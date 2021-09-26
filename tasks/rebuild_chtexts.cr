require "file_utils"
require "compress/zip"

INP = "_db/chseed"
OUT = "db/chtexts"

class RebuildBook
  record Chap, schid : String, title : String, chvol : String

  PART_LIMIT = 3000

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

    infos.each_slice(128).with_index do |slice, page_idx|
      out_file = "#{@out_dir}/#{page_idx}.tsv"

      next if File.exists?(out_file) && !redo

      index = slice.map_with_index do |input, slice_idx|
        chidx = page_idx * 128 + slice_idx
        stats = [chidx.+(1).to_s, fix_schid(input.schid).to_s,
                 input.title, input.chvol]
        rebuild_chap(chidx, input.schid).try { |x| stats.concat(x.map(&.to_s)) }
        stats.map(&.to_s).join('\t')
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
      puts "\n[#{sname}] <#{idx}/#{books.size}> #{snvid}"
      run!(sname, snvid)
    end
  end
end

snames = ARGV.empty? ? Dir.children(INP) : ARGV
snames.each { |sname| RebuildBook.run_all!(sname) }

# RebuildBook.new("hetushu", "1").run!
