require "log"
require "sqlite3"
require "colorize"
require "../wn_repo"

SNAMES = {} of Int32 => String

{"common.tsv", "viuser-live.tsv", "viuser.tsv"}.each do |file|
  File.each_line("var/fixed/seeds/#{file}") do |line|
    next if line.empty? || line.starts_with?('#')
    cols = line.split('\t')
    sname, sn_id, _ = cols
    SNAMES[sn_id.to_i] = sname
  end
end

def import_one(sname : String, s_bid : Int32)
  inp_path = "var/chaps/texts/#{sname}/#{s_bid}/index.db"
  return unless mtime = File.info?(inp_path).try(&.modification_time)

  fg_sname = sname[0] == '=' ? "-" : sname
  out_path = WN::WnRepo.db_path("#{fg_sname}/#{s_bid}-infos")

  out_info = File.info?(out_path)
  out_info.try { |x| return if x.modification_time > mtime }

  mtime += 1.minutes
  paths = [] of {Int32, String}

  DB.open("sqlite3:#{inp_path}") do |db|
    query = "select sn_id, s_bid, ch_no, s_cid from chinfos"

    db.query_each query do |rs|
      sn_id, s_bid, ch_no, s_cid = rs.read(Int32, Int32, Int32, Int32)
      sname = SNAMES[sn_id]
      sname = sname[0] == '@' ? "+" + sname[1..] : "!" + sname
      paths << {ch_no, "#{sname}/#{s_bid}/#{s_cid}:#{ch_no}"}
    end
  end

  DB.open("sqlite3:#{out_path}") do |db|
    db.exec WN::WnRepo.init_sql
    db.exec "pragma journal_mode = WAL"
    db.exec "pragma synchronous = normal"
    db.exec "attach database '#{inp_path}' as src"

    db.exec "begin"
    db.exec <<-SQL
      replace into chaps (ch_no, s_cid, title, chdiv, c_len, p_len, mtime, uname)
      select ch_no, s_cid, title as title, chvol as chdiv, c_len, p_len, utime as mtime, uname
      from src.chinfos
    SQL

    paths.each do |ch_no, path|
      db.exec "update chaps set _path = ? where ch_no = ?", path, ch_no
    end

    db.exec "commit"
  end

  File.utime(mtime, mtime, out_path)
end

def import_all(sname : String, threads = 6)
  return if sname == "=user"
  Dir.mkdir_p("var/chaps/infos/#{sname}") unless sname[0] == '='

  s_bids = Dir.children("var/chaps/texts/#{sname}").map(&.to_i).sort!

  workers = Channel({Int32, Int32}).new(s_bids.size)
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        s_bid, idx = workers.receive
        import_one(sname, s_bid)
        puts " - <#{idx}/#{s_bids.size}> [#{sname}/#{s_bid}]"
      rescue err
        puts "#{sname}, #{s_bid}, #{err.message} ".colorize.red
      ensure
        results.send(nil)
      end
    end
  end

  s_bids.each_with_index(1) { |s_bid, idx| workers.send({s_bid, idx}) }
  s_bids.size.times { results.receive }
end

threads = ENV["CRYSTAL_WORKERS"]?.try(&.to_i?) || 6
threads = 6 if threads < 6

snames = ARGV.empty? ? Dir.children("var/chaps/texts") : ARGV
snames.sort!

puts snames.colorize.yellow

snames.each do |sname|
  import_all(sname, threads) if sname[0].in?('@', '=')
end
