require "log"
require "sqlite3"
require "colorize"
require "option_parser"

require "../../../mt_v1/mt_core"
require "../../../_util/text_util"
require "../wn_chap"

def generate(inp_path : String, dname : String = "combine")
  raise "Input not found" unless File.file?(inp_path)
  # return unless mtime = File.info?(inp_path).try(&.modification_time)
  out_path = inp_path.sub("infos.db", "trans.db")

  File.delete?(out_path)
  File.copy(inp_path, out_path)

  trans = [] of {String, String, Int32}
  cvmtl = CV::MtCore.generic_mtl(dname)

  DB.open("sqlite3:#{inp_path}") do |db|
    db.query_each("select ch_no, title, chdiv from chaps order by ch_no asc") do |rs|
      ch_no, title, chdiv = rs.read(Int32, String, String)

      title = cvmtl.cv_title(title).to_txt unless title.blank?
      chdiv = cvmtl.cv_title(chdiv).to_txt unless chdiv.blank?

      trans << {title, chdiv, ch_no}
    end
  end

  raise "no thing to translate" if trans.empty?
  puts "- chaps: #{trans.size}"

  DB.open("sqlite3:#{out_path}") do |db|
    db.exec "pragma journal_mode = WAL"
    db.exec "pragma synchronous = normal"

    query = "update chaps set title = ?, chdiv = ? where ch_no = ?"

    db.exec "begin"
    trans.each { |args| db.exec query, *args }
    db.exec "commit"
  end

  # mtime += 1.minutes
  # File.utime(mtime, mtime, out_path)
end

input = ""
dname = "combine"

OptionParser.parse(ARGV) do |parser|
  parser.on("-d DNAME", "Unique dict name") { |d| dname = d }
  parser.unknown_args { |x| input = x.first unless x.empty? }
end

raise "Missing input file" if input.blank?

puts "file: #{input.colorize.yellow}, dict: #{dname.colorize.yellow}"
generate(input, dname)
