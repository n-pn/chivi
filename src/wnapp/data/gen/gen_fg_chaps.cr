# require "log"
# require "sqlite3"
# require "colorize"
# require "../wn_repo"

# SNAMES = {} of Int32 => String

# MAP_BG = {
#   "biqugee":  "!biqugee.com",
#   "bxwxorg":  "!bxwxorg.com",
#   "rengshu":  "!rengshu.com",
#   "shubaow":  "!shubaow.net",
#   "duokan8":  "!duokan8.com",
#   "paoshu8":  "!paoshu8.com",
#   "miscs":    "!chivi.app",
#   "xbiquge":  "!xbiquge.bz",
#   "hetushu":  "!hetushu.com",
#   "69shu":    "!69shu.com",
#   "sdyfcm":   "!nofff.com",
#   "nofff":    "!nofff.com",
#   "5200":     "!5200.tv",
#   "zxcs_me":  "!zxcs.me",
#   "jx_la":    "!jx.la",
#   "ptwxz":    "!ptwxz.com",
#   "uukanshu": "!uukanshu.com",
#   "uuks":     "!uuks.org",
#   "bxwxio":   "!bxwx.io",
#   "133txt":   "!133txt.com",
#   "biqugse":  "!biqugse.com",
#   "bqxs520":  "!bqxs520.com",
#   "yannuozw": "!yannuozw.com",
#   "kanshu8":  "!kanshu8.net",
#   "biqu5200": "!biqu5200.net",
#   "b5200":    "!b5200.org",
# }

# {"common.tsv", "viuser-live.tsv", "viuser.tsv"}.each do |file|
#   File.each_line("var/fixed/seeds/#{file}") do |line|
#     next if line.empty? || line.starts_with?('#')
#     cols = line.split('\t')
#     sname, sn_id, _ = cols

#     SNAMES[sn_id.to_i] = MAP_BG[sname]? || sname
#   end
# end

# def get_mtime(file : String)
#   File.info?(file).try(&.modification_time)
# end

# def import_one(sname : String, s_bid : Int32, force : Bool = false)
#   inp_path = "var/chaps/texts/#{sname}/#{s_bid}/index.db"
#   return unless mtime = get_mtime(inp_path)

#   fg_sname = sname[0] == '=' ? "_" : sname
#   out_path = WN::WnRepo.db_path(fg_sname, s_bid)

#   return if !force && get_mtime(out_path).try(&.> mtime)

#   mtime += 1.minutes
#   paths = [] of {Int32, String}

#   DB.open("sqlite3:#{inp_path}") do |db|
#     query = "select sn_id, s_bid, ch_no, s_cid from chinfos"

#     db.query_each query do |rs|
#       sn_id, s_bid, ch_no, s_cid = rs.read(Int32, Int32, Int32, Int32)
#       paths << {ch_no, "#{SNAMES[sn_id]}/#{s_bid}/#{s_cid}:#{ch_no}"}
#     end
#   end

#   DB.open("sqlite3:#{out_path}") do |db|
#     db.exec WN::WnRepo.init_sql
#     db.exec "pragma journal_mode = WAL"
#     db.exec "pragma synchronous = normal"
#     db.exec "attach database '#{inp_path}' as src"

#     db.exec "begin"

#     db.exec <<-SQL
#       replace into chaps (ch_no, s_cid, title, chdiv, c_len, p_len, mtime, uname)
#       select ch_no, s_cid, title, chvol as chdiv, c_len, p_len, utime as mtime, uname
#       from src.chinfos
#     SQL

#     paths.each do |ch_no, path|
#       db.exec "update chaps set _path = ? where ch_no = ?", path, ch_no
#     end

#     db.exec "commit"
#   end

#   File.utime(mtime, mtime, out_path)
# rescue err
#   puts "#{sname}, #{s_bid}, #{err.class}".colorize.red
# end

# def import_all(sname : String, threads = 6, force = false)
#   Dir.mkdir_p("var/chaps/infos/#{sname}") unless sname[0] == '='

#   s_bids = Dir.children("var/chaps/texts/#{sname}").map(&.to_i).sort!

#   workers = Channel({Int32, Int32}).new(s_bids.size)
#   results = Channel(Nil).new(threads)

#   threads.times do
#     spawn do
#       loop do
#         s_bid, idx = workers.receive
#         import_one(sname, s_bid, force: force)
#         puts " - <#{idx}/#{s_bids.size}> [#{sname}/#{s_bid}]"
#         results.send(nil)
#       end
#     end
#   end

#   s_bids.each_with_index(1) { |s_bid, idx| workers.send({s_bid, idx}) }
#   s_bids.size.times { results.receive }
# end

# threads = ENV["CRYSTAL_WORKERS"]?.try(&.to_i?) || 6
# threads = 6 if threads < 6

# force = ARGV.includes?("--force")
# ARGV.reject!(&.starts_with?('-'))

# snames = ARGV.empty? ? Dir.children("var/chaps/texts") : ARGV
# snames.sort!.reverse!

# puts snames.colorize.yellow

# snames.each do |sname|
#   next unless sname[0].in?('@', '=') && sname != "=user"
#   import_all(sname, threads, force: force)
# end
