# require "colorize"
# require "compress/zip"
# require "../src/rdapp/data/czdata"

# DB3_DIR = "/2tb/app.chivi/var/stems"
# ZIP_DIR = "/2tb/app.chivi/var/stems"
# INP_DIR = "/2tb/zroot/zdata"

# struct Chinfo
#   include DB::Serializable

#   getter ch_no : Int32
#   getter ztitle : String
#   getter zchdiv : String

#   getter spath : String
#   getter rlink : String
#   getter mtime : Int64
#   getter uname : String

#   def db_values(sname)
#     {

#       @rlink,
#       @mtime,
#       @uname.empty? ? sname : "?#{@uname}",
#     }
#   end

#   def s_cid
#     @spath.empty? ? 0 : spath.split('/').last.to_i? || 0
#   end

#   def title
#     @ztitle.empty? ? "" : CharUtil.normalize(@ztitle)
#   end

#   def chdiv
#     @zchdiv.empty? ? "" : CharUtil.normalize(@zchdiv)
#   end

#   def zorig(sname : String)
#     return "?#{@uname}" unless @uname.empty?
#     return sname if @rlink.empty?
#     URI.parse(@rlink).hostname.as(String).sub(/^www\./, "")
#   end

#   SQL = <<-SQL
#     insert into czdata(ch_no, s_cid, title, chdiv, mtime, zorig, zlink)
#     values($1, $2, $3, $4, $5, $6, $7)
#     on conflict(ch_no) do update set
#       s_cid = excluded.s_cid,
#       title = excluded.title,
#       chdiv = excluded.chdiv,
#       mtime = excluded.mtime,
#       zorig = excluded.zorig,
#       zlink = excluded.zlink
#     SQL

#   def upsert!(db, sname)
#     db.exec SQL, @ch_no, self.s_cid, self.title, self.chdiv, @mtime, self.zorig(sname), @rlink
#   end

#   def self.load_all(db_path)
#     DB.open("sqlite3:#{db_path}?immutable=1") do |db|
#       db.query_all "select ch_no, ztitle, zchdiv, spath, rlink, mtime, uname from chinfos", as: self
#     rescue ex
#       Log.error { ex }
#       [] of self
#     end
#   end
# end

# def read_ztexts(zip_path)
#   Compress::Zip::File.open(zip_path) do |zip|
#     zip.entries.map do |entry|
#       ch_no = File.basename(entry.filename, ".zh").to_i

#       title = chdiv = ""
#       state = zsize = 0

#       strio = String::Builder.new

#       entry.open do |input|
#         input.each_line do |line|
#           next if line.blank?
#           line = CharUtil.normalize(line)

#           if state > 1
#             strio << '\n' << line
#             zsize &+= line.size &+ 1
#           elsif state == 1 || !line.starts_with?("///")
#             title = line
#             strio << line
#             zsize &+= line.size
#             state = 2
#           else
#             chdiv = line.lstrip('/').lstrip(' ') if chdiv.size > 3
#             state = 1
#           end
#         end
#       end

#       {ch_no, strio.to_s, zsize, title, chdiv}
#     end
#   end
# end

# def migrate(out_db3_path, inp_db3_path, inp_zip_path, sname)
#   puts out_db3_path.colorize.blue

#   if File.file?(inp_db3_path)
#     cinfos = Chinfo.load_all(inp_db3_path)
#     puts "importing #{cinfos.size} cinfos"
#   else
#     puts "#{inp_db3_path} not found".colorize.dark_gray
#   end

#   if File.file?(inp_zip_path)
#     ztexts = read_ztexts(inp_zip_path).sort_by!(&.[0])
#     puts "importing #{ztexts.size} ztexts"
#   else
#     puts "#{inp_zip_path} not found".colorize.dark_gray
#   end

#   return unless cinfos || ztexts

#   RD::Czdata.db(out_db3_path).open_tx do |db|
#     cinfos.each(&.upsert!(db: db, sname: sname)) if cinfos

#     next unless ztexts

#     ztexts.each do |ch_no, ztext, zsize, title, chdiv|
#       db.exec <<-SQL, ch_no // 10, title, chdiv, ztext, zsize
#         insert into czdata(ch_no, s_cid, title, chdiv, ztext, zsize)
#         values ($1, 0, $2, $3, $4, $5)
#         on conflict(ch_no) do update set
#           title = IIF(excluded.title = '', czdata.title, excluded.title),
#           chdiv = IIF(excluded.chdiv = '', czdata.chdiv, excluded.chdiv),
#           ztext = excluded.ztext,
#           zsize = excluded.zsize
#         SQL
#     end
#   end
# end

# FRESH = Time.local(2024, 2, 17, 7, 0, 0)

# def migrate_all(old_sname)
#   new_sname = old_sname.sub(/^rm|wn|up/, "")
#   Dir.mkdir_p("/2tb/zroot/wn_db/#{new_sname}")

#   files = Dir.glob("#{DB3_DIR}/#{old_sname}/*-cinfo.db3")
#   puts "#{new_sname}: #{files.size}"

#   files.each do |inp_db3_path|
#     next if File.info(inp_db3_path).modification_time < FRESH

#     sn_id = File.basename(inp_db3_path, "-cinfo.db3")

#     out_db3_path = "/2tb/zroot/wn_db/#{new_sname}/#{sn_id}.v1.db3"
#     inp_zip_path = "/2tb/zroot/ztext/#{new_sname}/#{sn_id}.zip"

#     migrate(out_db3_path, inp_db3_path, inp_zip_path, new_sname)
#   end
# end

# # ARGV.each { |sname| migrate_all(sname) }
# Dir.each_child(DB3_DIR) { |sname| migrate_all(sname) }