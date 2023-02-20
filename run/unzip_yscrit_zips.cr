require "compress/zip"

INP = "var/ysapp/crits"
OUT = "var/ysapp/crits-txt"

def unzip_zh(zip_file : String)
  puts zip_file

  Compress::Zip::File.open(zip_file) do |zip|
    zip.entries.each do |entry|
      uuid = entry.filename.split('.').first

      dir_name = "#{OUT}/#{uuid[0..3]}-zh"
      Dir.mkdir_p(dir_name)

      out_path = "#{dir_name}/#{uuid}.txt"
      File.write(out_path, entry.open(&.getb_to_end))
    end
  end
end

def unzip_vi(zip_file : String)
  puts zip_file

  Compress::Zip::File.open(zip_file) do |zip|
    zip.entries.each do |entry|
      uuid = File.basename(entry.filename, ".htm")
      next if uuid.includes?('/')

      dir_name = "#{OUT}/#{uuid[0..3]}-vi"
      Dir.mkdir_p(dir_name)

      out_path = "#{dir_name}/#{uuid}.htm"
      File.write(out_path, entry.open(&.getb_to_end))
    end
  end
end

# Dir.glob("#{INP}/*-zh.zip").each { |file| unzip_zh(file) }
# Dir.glob("#{INP}/*-vi.zip").each { |file| unzip_vi(file) }

def move_file(dir_path : String, ext = ".htm", lang = "vi")
  puts dir_path

  Dir.glob("#{dir_path}/*#{ext}") do |inp_path|
    uuid = File.basename(inp_path, ext)

    dir_name = "#{OUT}/#{uuid[0..3]}-#{lang}"
    Dir.mkdir_p(dir_name)

    out_path = "#{dir_name}/#{uuid}#{ext}"
    puts "#{inp_path} => #{out_path}"

    File.delete?(out_path)
    File.rename(inp_path, out_path)
  end
end

# Dir.glob("#{INP}/../crits.tmp/*-zh").each { |dir| move_file(dir, ".txt", "zh") }
# Dir.glob("#{INP}/../crits.tmp/*-vi").each { |dir| move_file(dir, ".htm", "vi") }
# Dir.glob("#{INP}/../crits.tmp/*-bv").each { |dir| move_file(dir, ".htm", "bv") }
# Dir.glob("#{INP}/../crits.tmp/*-de").each { |dir| move_file(dir, ".htm", "de") }

Dir.glob("#{OUT}/*").each do |dir_path|
  zip_path = dir_path.sub("crits-txt", "crits-zip") + ".zip"
  puts "#{dir_path} => #{zip_path}"

  `zip -FSrjyoq '#{zip_path}' '#{dir_path}'`
end
