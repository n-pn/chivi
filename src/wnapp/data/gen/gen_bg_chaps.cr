require "log"
require "sqlite3"
require "colorize"
require "../wn_repo"

def read_mtime(path : String)
  File.info?(path).try(&.modification_time)
end

IMPORT_QUERY_1 = <<-SQL
  replace into chaps (ch_no, s_cid, title, chdiv, c_len, p_len, mtime, uname)
  select ch_no, s_cid, title, chvol as chdiv, c_len, p_len, utime as mtime, uname
  from src.chinfos
SQL

IMPORT_QUERY_2 = IMPORT_QUERY_1 + " where sn_id = ?"

def import_one(sname : String, s_bid : Int32, sn_id : Int32)
  inp_path = "var/chaps/texts/#{sname}/#{s_bid}/index.db"
  return unless inp_time = read_mtime(inp_path)

  bg_sname = sname[0] == '@' ? "+" + sname[1..] : "!" + sname

  out_path = WN::WnRepo.db_path("#{bg_sname}/#{s_bid}-infos")
  out_time = read_mtime(out_path)
  return if out_time && out_time > inp_time

  DB.open("sqlite3:#{out_path}") do |db|
    db.exec WN::WnRepo.init_sql # unless out_time

    db.exec "pragma journal_mode = WAL"
    db.exec "pragma synchronous = normal"
    db.exec "attach database '#{inp_path}' as src"

    db.exec "begin"

    if sname.starts_with?('@') # ignore mirrored chapter in user seeds
      db.exec IMPORT_QUERY_2, sn_id
    else
      db.exec IMPORT_QUERY_1
    end

    db.exec "commit"
  end

  inp_time += 1.minutes
  File.utime(inp_time, inp_time, out_path)
end

def import_all(sname : String, sn_id : Int32)
  # Dir.mkdir_p("var/chaps/infos/#{sname}")

  s_bids = Dir.children("var/chaps/texts/#{sname}").map(&.to_i).sort!

  workers = Channel({Int32, Int32}).new(s_bids.size)

  threads = 6
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        s_bid, idx = workers.receive
        import_one(sname, s_bid, sn_id)
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

SN_IDS = {} of String => Int32

{"common.tsv", "viuser-live.tsv", "viuser.tsv"}.each do |file|
  File.each_line("var/fixed/seeds/#{file}") do |line|
    next if line.empty? || line.starts_with?('#')
    cols = line.split('\t')
    sname, sn_id, _ = cols
    SN_IDS[sname] = sn_id.to_i
  end
end

snames = ARGV.empty? ? Dir.children("var/chaps/texts") : ARGV

snames.sort!.each do |sname|
  next if sname[0].in?('.', '=')
  next unless sn_id = SN_IDS[sname]?

  import_all(sname, sn_id)
end
