require "compress/gzip"
require "../src/zroot/html_parser/raw_rmchap"

def read_html(gz_file : String)
  File.open(gz_file, "r") do |io|
    Compress::Gzip::Reader.open(io, &.gets_to_end)
  end
end

DIR = "/www/chivi/cwd"
OUT = "var/texts/rgbks"

def extract_chap(inp_file : String, out_file : String, conf : Rmconf)
  html = read_html(inp_file)
  chap = RawRmchap.new(html, conf)

  text = chap.content
  File.write(out_file, text.encode("GB18030", invalid: :skip), encoding: "GB18030")

  puts "- #{out_file} saved!"
rescue ex
  puts [inp_file, ex.message]
end

def extract_book(sname : String, b_id : String | Int32, conf = Rmconf.load!(sname))
  files = Dir.glob("#{DIR}/#{sname}/#{b_id}/*.html.gz")
  out_dir = "#{OUT}/#{sname}/#{b_id}"
  Dir.mkdir_p(out_dir)

  files.each do |file|
    c_id = File.basename(file, ".html.gz")
    out_path = "#{out_dir}/#{c_id}.gbk"
    extract_chap(file, out_path, conf)
  end
end

def extract_seed(sname : String)
  conf = Rmconf.load!(sname)

  Dir.children("#{DIR}/#{sname}").each do |b_id|
    extract_book(sname, b_id, conf)
  end
end

ARGV.each do |sname|
  extract_seed(sname)
end
