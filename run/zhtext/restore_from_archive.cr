require "compress/zip"
require "colorize"

INP = "/media/nipin/Roams/Chivi/var/texts/rzips"
OUT = "/www/var.chivi/zroot/rawtxt"

def zip_data(zip_path)
  return [] of String unless File.file?(zip_path)
  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.map(&.filename)
  end
end

def check(inp_sname, out_sname = inp_sname)
  files = Dir.glob("#{INP}/#{inp_sname}/*.zip")

  files.each do |inp_path|
    out_path = inp_path.sub(INP, OUT)
    out_path = inp_path.sub(inp_sname, out_sname) if inp_sname != out_sname

    inp_files = zip_data(inp_path)
    out_files = zip_data(out_path)

    missing = inp_files - out_files
    next if missing.empty?

    puts "found: #{missing.size} missing".colorize.yellow
  end
end

check ARGV[0]? || "!piaotia.com"
