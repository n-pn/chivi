require "compress/zip"
require "colorize"
require "../../src/rdapp/data/cztext"

INP_DIR = "/2tb/zroot/zdata"
OUT_DIR = "/2tb/zroot/ztext"

record Input, ch_no : Int32, chdiv : String, ztext : String do
  include DB::Serializable

  def save!(tmp_path : String)
    File.open("#{tmp_path}/#{ch_no}0.zh", "w") do |file|
      file << "///" << @chdiv << '\n'
      file << RD::Cztext.fix_raw(@ztext)
    end
  end
end

def load_existed(zip_path)
  Compress::Zip::File.open(zip_path) do |zip|
    zip.entries.map { |x| File.basename(x.filename, ".zh").to_i // 10 }.to_set
  end
rescue
  Set(String).new
end

def save_data(sname : String, db3_path : String)
  sn_id = File.basename(db3_path, "-zdata.db3")
  tmp_path = "#{OUT_DIR}/#{sname}/#{sn_id}"
  zip_path = "#{tmp_path}.zip"

  skips = load_existed(zip_path)

  chaps = DB.connect("sqlite3:#{db3_path}?immutable=1") do |db|
    db.query_all "select ch_no, chdiv, ztext from czdata where ztext <> ''", as: Input
  end

  return puts "#{db3_path}: no file in source!" if chaps.empty?
  chaps.reject!(&.ch_no.in?(skips))

  return puts "#{db3_path}: all files (#{skips.size}) saved, skipping!".colorize.blue if chaps.empty?

  Dir.mkdir_p(tmp_path)
  chaps.each(&.save!(tmp_path))

  `zip -rjyomq '#{zip_path}' '#{tmp_path}'`
  puts "#{db3_path}: #{chaps.size} recovered!".colorize.yellow
end

snames = ARGV.reject(&.starts_with?("-"))
snames = ["!rengshu.com"] if snames.empty?

snames.each do |sname|
  files = Dir.glob("#{INP_DIR}/#{sname}/*-zdata.db3")
  files.each do |file|
    save_data(sname, file)
  rescue ex
    puts file, ex
  end
end
