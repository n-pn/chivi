require "log"
require "sqlite3"
require "colorize"
require "../wnchap/*"

def import_one(sname : String, s_bid : Int32, sn_id : Int32)
  inp_path = "var/chaps/texts/#{sname}/#{s_bid}/index.db"
  return unless mtime = File.info?(inp_path).try(&.modification_time)

  names_path = WN::ChName.db_path("bg/#{sname}/#{s_bid}")
  stats_path = WN::ChStat.db_path("bg/#{sname}/#{s_bid}")

  File.info?(names_path).try { |x| return if x.modification_time > mtime }

  mtime += 1.minutes

  import_names(inp_path, names_path, mtime, sn_id)
  import_stats(inp_path, stats_path, mtime, sn_id)
end

def import_names(source : String, target : String, mtime : Time, sn_id : Int32)
  DB.open("sqlite3:#{target}") do |db|
    db.exec WN::ChName.init_sql
    db.exec "pragma journal_mode = WAL"
    db.exec "pragma synchronous = normal"
    db.exec "attach database '#{source}' as source"

    db.exec "begin"
    db.exec <<-SQL
      replace into names (ch_no, s_cid, title, chdiv)
      select ch_no, s_cid, title, chvol as chdiv
      from source.chinfos where sn_id = #{sn_id}
    SQL
    db.exec "commit"
  end

  File.utime(mtime, mtime, target)
end

def import_stats(source : String, target : String, mtime : Time, sn_id : Int32)
  DB.open("sqlite3:#{target}") do |db|
    db.exec WN::ChStat.init_sql
    db.exec "pragma journal_mode = WAL"
    db.exec "pragma synchronous = normal"
    db.exec "attach database '#{source}' as source"

    db.exec "begin"
    db.exec <<-SQL
      replace into stats (ch_no, s_cid, c_len, p_len, mtime)
      select ch_no, s_cid, c_len, p_len, utime as mtime
      from source.chinfos where sn_id = #{sn_id}
    SQL
    db.exec "commit"
  end

  File.utime(mtime, mtime, target)
end

def import_all(sname : String, sn_id : Int32)
  Dir.mkdir_p("var/chaps/infos-bg/#{sname}")

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

snames.each do |sname|
  next if sname[0].in?('.', '=')
  next unless sn_id = SN_IDS[sname]?
  import_all(sname, sn_id)
end
