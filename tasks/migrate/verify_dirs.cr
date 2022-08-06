require "colorize"
require "file_utils"
require "compress/zip"

require "../src/appcv/nvchap/*"

INP_DIR = Path["var", "chtexts"]

Dir.children(INP_DIR).each do |sname|
  next unless sname.starts_with?('@')
  sname_dir = INP_DIR.join(sname)

  Dir.children(sname_dir).each do |s_bid|
    book_dir = sname_dir.join(s_bid)
    verify(book_dir, sname)
  end
end

def fix_zip(old_file : String, tail : String)
  fix_file = old_file.sub("#{tail}.zip", ".zip")
  unless File.exists?(fix_file)
    File.rename(old_file, fix_file)
    return fix_file
  end

  puts "resolve: #{old_file} => #{fix_file}".colorize.red

  out_dir = fix_file.sub(".zip", "")
  system("unzip", ["-o", old_file, "-d", out_dir])
  system("unzip", ["-o", fix_file, "-d", out_dir])

  File.rename(old_file, old_file.sub(".zip", ".old"))
  File.rename(fix_file, fix_file.sub(".zip", ".old"))

  system("zip", ["-rjmq", fix_file, out_dir])
  Dir.delete(out_dir)

  fix_file
end

def verify(book_dir : Path, sname)
  puts "- checking: #{book_dir}"

  Dir.glob(book_dir.join("*.zip")).each do |zip_file|
    # if zip_file.includes?("-users")
    #   zip_file = fix_zip(zip_file, "-users")
    # elsif zip_file.includes?("-patch")
    #   zip_file = fix_zip(zip_file, "-patch")
    # end

    tsv_file = zip_file.sub(".zip", ".tsv")
    raise "missing #{zip_file}" unless File.exists?(tsv_file)
  end

  Dir.glob(book_dir.join("*.tsv")).each do |file|
    input = CV::ChRepo0.new(file)

    map_parts = {} of String => Int16

    input.data.each_value do |info|
      next if info.proxy || info.stats.utime == 0

      unless info.chidx.to_s == info.schid
        raise "still in wrong format" unless sname == "miscs"
        raise "still in wrong format" unless new_schid = info.schid.to_i?
        raise "still in wrong format" if new_schid == 10 * info.chidx
      end

      map_parts[info.schid] = info.stats.parts
    end

    next if map_parts.empty?

    Compress::Zip::File.open(file.sub(".tsv", ".zip")) do |zip|
      zip.entries.each do |entry|
        schid = entry.filename.split("-").first
        if map_parts.has_key?(schid)
          map_parts[schid] -= 1
        else
          puts file
          raise "extra #{entry.filename}"
        end
      end
    end

    map_parts.each do |schid, parts|
      if parts < -6
        raise "Too much extra: #{schid}/#{parts.colorize.red}"
      elsif parts < 0
        puts " too much: #{schid}/#{parts}".colorize.yellow
      elsif parts > 0 && sname != "miscs"
        raise "Missing part: #{schid}/#{parts}"
      end
    end
  end
end
