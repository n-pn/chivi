require "colorize"
require "../../src/rdapp/data/czdata"

record Chinfo, ch_no : Int32, title : String, chdiv : String, mtime : Int64 do
  include JSON::Serializable
end

INP_DIR = "/www/chivi/xyz/seeds/zxcs.me/split"
OUT_DIR = "/mnt/serve/chivi.app/texts/!zxcs.me"
Dir.mkdir_p(OUT_DIR)

inp_files = Dir.glob("#{INP_DIR}/*.jsonl")
inp_files.each { |inp_file| combine(inp_file) }

def combine(inp_file : String)
  sn_id = File.basename(inp_file, ".jsonl")
  cinps = File.read_lines(inp_file, chomp: true).map { |line| Chinfo.from_json(line) }

  zdata = cinps.map do |cinfo|
    RD::Czdata.new(
      ch_no: cinfo.ch_no,
      cbody: File.read(File.join INP_DIR, sn_id, "#{cinfo.ch_no}.txt"),
      title: cinfo.title,
      chdiv: cinfo.chdiv,
      uname: "!zxcs.me",
      zorig: "#{sn_id}/#{cinfo.ch_no}",
      mtime: cinfo.mtime
    )
  end

  repo = RD::Czdata.db("!zxcs.me/#{sn_id}")
  repo.open_tx { |db| zdata.each(&.upsert!(db: db)) }
  puts " - #{repo.db_path} saved!"
end
