require "log"
require "sqlite3"
require "colorize"
require "../wnchap/*"
require "../../mt_v1/mt_core"

def import_one(sname : String, s_bid : Int32, dname : String = "combine", regen = false)
  db_path = WN::ChInfo.db_path("#{sname}/#{s_bid}")
  return unless mtime = File.info?(db_path).try(&.modification_time)

  File.info?(db_path).try { |x| return if x.modification_time > mtime }

  mtime += 1.minutes

  trans = [] of {String, String, String, Int32}
  cvmtl = CV::MtCore.generic_mtl(dname)

  DB.open("sqlite3:#{db_path}") do |db|
    query = "select ch_no, title_zh, chdiv_zh from infos"
    query += " where title = ''" unless regen

    db.query_each(query) do |rs|
      ch_no, title_zh, chdiv_zh = rs.read(Int32, String, String)

      title = title_zh.blank? ? "" : cvmtl.cv_title(title_zh).to_txt
      chdiv = chdiv_zh.blank? ? "" : cvmtl.cv_title(chdiv_zh).to_txt
      uslug = TextUtil.tokenize(title)[0..7].join('-')

      trans << {title, chdiv, uslug, ch_no}
    end
  end

  DB.open("sqlite3:#{db_path}") do |db|
    db.exec WN::ChInfo.init_sql
    db.exec "pragma journal_mode = WAL"
    db.exec "pragma synchronous = normal"

    db.exec "begin"

    trans.each do |args|
      query = "update chaps set title = ?, chdiv = ?, uslug = ? where ch_no = ?"
      db.exec query, args: args.to_a
    end

    db.exec "commit"
  end

  File.utime(mtime, mtime, db_path)
end

def import_all(sname : String, threads = 6, regen : Bool = false)
  Dir.mkdir_p("var/chaps/infos-fg/#{sname}")
  s_bids = Dir.children("var/chaps/texts/#{sname}").map(&.to_i).sort!

  workers = Channel({Int32, Int32}).new(s_bids.size)
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        s_bid, idx = workers.receive
        import_one(sname, s_bid, regen: regen)
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

regen = ARGV.includes?("--regen")
ARGV.reject!(&.starts_with?('-'))

snames = ARGV.empty? ? Dir.children("var/chaps/texts") : ARGV
puts snames.colorize.yellow

snames.each do |sname|
  next if sname == "=user"
  import_all(sname, threads, regen: regen) if sname[0].in?('@', '=')
end
