require "file_utils"
require "compress/zip"

require "../src/cutil/tsv_store"
INP = "_db/chseed"
OUT = "db/chtexts"

class CV::FixData
  record Chap, schid : String, title : String, chvol : String

  def initialize(@sname : String, @snvid : String)
    @inp_dir = "#{INP}/#{@sname}/#{@snvid}"
    @out_dir = "#{OUT}/#{@sname}/#{@snvid}"
  end

  def run!(redo = false)
    inp_file = "#{@inp_dir}/_id.tsv"
    return unless File.exists?(inp_file)

    import_old_info!(inp_file)
    fix_splited_texts!
    cleanup_old_texts!

    File.delete(inp_file)

    if Dir.empty?(@inp_dir)
      FileUtils.rmdir(@inp_dir)
    else
      puts "Artifact remain, please resolve!".colorize.red
    end
  end

  @cache = {} of Int32 => TsvStore

  def chlist(pgidx : Int32)
    @cache[pgidx] ||= TsvStore.new("#{@out_dir}/#{pgidx}.tsv")
  end

  def import_old_info!(inp_file)
    lines = File.read_lines(inp_file)
    pgmax = (lines.size - 1) // 128

    0.upto(pgmax) do |pgidx|
      list = chlist(pgidx)
      from = pgidx * 128

      from.upto(from + 127) do |index|
        chidx = (index + 1).to_s

        next unless line = lines[index]?
        next if list.get(chidx)

        vals = line.split('\t', 4)
        vals.shift if vals.size > 3

        if @sname == "zxcs_me"
          vals[0] = vals[0].to_i.to_s
        elsif @sname == "chivi"
          vals[0] = vals[0].to_i.*(10).to_s
        end

        list.set!(chidx, vals)
      end

      list.save!(clean: true) if list.unsaved > 0
    end
  end

  def fix_splited_texts!
    Dir.glob("#{@out_dir}/*.zip").each do |zip_file|
      fix_text_in_output_zip(zip_file)
    rescue err
      puts err
    end
  end

  @existed = Set(String).new

  SAFEMARK = Time.utc(2021, 10, 1, 11, 40, 0).to_unix

  def fix_text_in_output_zip(zip_file)
    chlist = self.chlist(File.basename(zip_file, ".zip").to_i)

    need_remap = extract_unmapped(chlist)
    need_title = Set(String).new

    tparts = Hash(String, Int32).new(0)
    tchars = Hash(String, Int32).new(0)
    utimes = Hash(String, Int64).new(0_i64)

    part_files = [] of String

    Compress::Zip::File.open(zip_file) do |zip|
      zip.entries.each do |entry|
        schid, cpart = File.basename(entry.filename, ".txt").split("-")
        @existed << schid
        tparts[schid] += 1

        utime = entry.time.to_unix
        utimes[schid] = utime if utimes[schid] < utime

        need_title << schid if cpart != "0" && utime < SAFEMARK
      end

      need_title.concat(need_remap.keys).each do |snvid|
        next unless entry = zip["#{snvid}-0.txt"]?

        input = entry.open(&.gets_to_end)
        tchars[snvid] += input.size

        title = input.split("\n", 2).first + "\n"
        parts = tparts[snvid]

        1.upto(parts - 1) do |cpart|
          fpath = "#{snvid}-#{cpart}.txt"
          input = zip[fpath].open(&.gets_to_end)
          tchars[snvid] += input.size

          next if input.starts_with?(title)

          out_file = "#{@out_dir}/#{fpath}"
          File.write(out_file, title + input)
          part_files << out_file
        end

        if chidx = need_remap[snvid]?
          stats = chlist.get(chidx).not_nil!
          stats << utimes[snvid].to_s << tchars[snvid].to_s << parts.to_s
          chlist.set!(chidx, stats)
        end
      end
    end

    chlist.save!(clean: true) if chlist.unsaved > 0
    return if part_files.empty?

    puts "- Save #{part_files.size} updated parts to #{zip_file}".colorize.green
    `zip -jqm #{zip_file} #{part_files.join(" ")}`
  end

  def cleanup_old_texts!
    Dir.glob("#{@inp_dir}/*.zip").each do |zip_file|
      clean_text_in_old_zip(zip_file)
      File.delete(zip_file)
    rescue err
      puts err
    end
  end

  def clean_text_in_old_zip(zip_file)
    Compress::Zip::File.open(zip_file) do |zip|
      zip.entries.each do |entry|
        schid = File.basename(entry.filename, ".txt")
        next if @existed.includes?(schid)

        if @sname == "zxcs_me"
          schid = schid.to_i.to_s
        elsif @sname == "chivi"
          schid = schid.to_i.*(10).to_s
        end

        File.write("#{@inp_dir}/#{schid}.txt", entry.open(&.gets_to_end))
      end
    end
  end

  def extract_unmapped(chlist)
    output = {} of String => String

    chlist.data.each do |chidx, vals|
      output[vals[0]] = chidx if vals.size < 4
    end

    output
  end

  def self.run!(sname : String, snvid : String)
    new(sname, snvid).run!
  end

  def self.run_all!(sname : String)
    books = Dir.children("#{INP}/#{sname}")
    books.each_with_index(1) do |snvid, idx|
      puts "\n[#{sname}] <#{idx}/#{books.size}> #{snvid}".colorize.cyan
      run!(sname, snvid)
    rescue err
      puts err
    end
  end
end

snames = ARGV.empty? ? Dir.children(INP) : ARGV
snames.each { |sname| CV::FixData.run_all!(sname) }

# RebuildBook.new("hetushu", "1").run!
