INP = "var/anlzs/texsmart/tmp"

def convert(inp_path : String)
  out_path = inp_path.sub(".tsv", ".pos")

  out_file = File.open(out_path, "w")

  File.read(inp_path).split("\n\n") do |sentence|
    sentence.lines.join(out_file, '\t') do |line|
      if line.includes?('\t')
        zstr, zpos = line.split('\t')
        out_file << zstr << '¦' << zpos
      else
        out_file << line
      end
    end

    out_file << '\n'
  end

  out_file.close
end

TMP = "/2tb/chivi/var/anlzs/texsmart/tmp"

books = Dir.children(INP)
books.each do |bname|
  zip_file = "#{TMP}/#{bname}.zip"
  next if File.file?(zip_file)

  files = Dir.glob("#{INP}/#{bname}/*log*.tsv")
  puts "#{bname}: #{files.size}"

  files.each do |file|
    convert(file)
    File.delete?(file)
  end

  `zip -rjyoq '#{zip_file}' '#{INP}/#{bname}'`
end
