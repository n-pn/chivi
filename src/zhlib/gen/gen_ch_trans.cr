require "log"
require "sqlite3"
require "colorize"
require "option_parser"

require "../wnchap/*"
require "../../mt_v1/mt_core"
require "../../_util/text_util"

def generate(sname : String, s_bid : Int32, dname : String = "combine")
  inp_path = WN::ChInfo.db_path("#{sname}/#{s_bid}")
  out_path = WN::ChTran.db_path("#{sname}/#{s_bid}")

  raise "Input not found" unless File.file?(inp_path)
  # return unless mtime = File.info?(inp_path).try(&.modification_time)

  trans = [] of {String, String, String, Int32}
  cvmtl = CV::MtCore.generic_mtl(dname)

  DB.open("sqlite3:#{inp_path}") do |db|
    db.query_each("select ch_no, title, chdiv from chaps order by ch_no asc") do |rs|
      ch_no, title_zh, chdiv_zh = rs.read(Int32, String, String)

      title = title_zh.blank? ? "" : cvmtl.cv_title(title_zh).to_txt
      chdiv = chdiv_zh.blank? ? "" : cvmtl.cv_title(chdiv_zh).to_txt
      uslug = title.empty? ? "-" : TextUtil.tokenize(title)[0..7].join('-')

      trans << {title, chdiv, uslug, ch_no}
    end
  end

  puts "- chaps: #{trans.size}"

  DB.open("sqlite3:#{out_path}") do |db|
    db.exec WN::ChTran.init_sql
    db.exec "pragma journal_mode = WAL"
    db.exec "pragma synchronous = normal"

    db.exec "begin"

    trans.each do |args|
      query = "replace into trans(title, chdiv, uslug, ch_no) values (?, ?, ?, ?)"
      db.exec query, *args
    end

    db.exec "commit"
  end

  # mtime += 1.minutes
  # File.utime(mtime, mtime, out_path)
end

sname = ""
s_bid = 0
dname = "combine"

OptionParser.parse(ARGV) do |parser|
  parser.on("-s SNAME", "Seed name") { |s| sname = s }
  parser.on("-b S_BID", "Book id") { |i| s_bid = i.to_i }
  parser.on("-d DNAME", "Unique dict name") { |d| dname = d }
end

puts "seed: #{sname.colorize.yellow}, book: #{s_bid.colorize.yellow}, dict: #{dname.colorize.yellow}"

raise "Missing sname" if sname.empty?
raise "Missing s_bid" if s_bid == 0

generate(sname, s_bid, dname)
