require "compress/gzip"

INP = "_db/.cache"

def save_to_gz(html_file : String, label = "1/1")
  puts "- <#{label}> #{html_file}"
  gzip_file = html_file + ".gz"

  File.open(html_file, "r") do |inp_io|
    File.open(gzip_file, "w") do |out_io|
      Compress::Gzip::Writer.open(out_io) { |gzip| IO.copy(inp_io, gzip) }
    end
  end

  utime = File.info(html_file).modification_time
  File.utime(utime, utime, gzip_file)

  File.delete(html_file)
end

def save_folder(path : String, label = "1/1")
  puts "\n<#{label}> [#{path}]"

  files = Dir.glob(File.join(path, "*.html"))
  files.each_with_index(1) do |file, idx|
    save_to_gz(file, "#{idx}/#{files.size}")
  end
end

def save_folders(path : String)
  dirs = Dir.glob(File.join(path, "*/"))
  dirs.each_with_index(1) do |dir, idx|
    save_folder(dir, label: "#{idx}/#{dirs.size}")
  end
end

dirs = Dir.children(INP)
dirs.each do |zseed|
  puts "[#{zseed}]"

  save_folder("#{INP}/#{zseed}/infos")
  save_folders("#{INP}/#{zseed}/texts")

  save_folder("#{INP}/#{zseed}/pages") if zseed == "zhwenpg"
  save_folder("#{INP}/#{zseed}/dlpgs") if zseed == "zxcs_me"
end
