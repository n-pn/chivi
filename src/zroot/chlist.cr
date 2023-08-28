# require "./html_parser/raw_rmcata"

# require "./shared/chinfo"
# require "./shared/chfile"
# require "./shared/rminit"

# class ZR::Chlist
#   DIR = "var/zroot/wnovel"
#   ::Dir.mkdir_p(DIR)

#   def self.seed_path(sname : String)
#     "#{DIR}/#{sname}"
#   end

#   def self.make_path(sname : String, fname : String)
#     "#{seed_path(sname)}/#{fname}"
#   end

#   ###

#   # getter conf : Rmconf

#   getter zinfo_db : Crorm::SQ3
#   # getter zfile_db : Crorm::SQ3

#   getter zip_path : String
#   getter tmp_path : String

#   def initialize(@sname : String, @sn_id : String)
#     @zinfo_db = Chinfo.db(sname, sn_id)
#     # @zfile_db = Chfile.db(sname, sn_id)

#     @zip_path = "#{DIR}/#{sname}/#{sn_id}-ztext.zip"
#     @tmp_path = "#{DIR}/#{sname}/#{sn_id}"
#   end

#   # def import_old_zh_db(src_db_path : String)
#   #   db.exec "attach database '#{src_db_path}' as src"

#   #   db.exec <<-SQL
#   #     replace into chaps (ch_no, s_cid, cpath, ctitle, subdiv, chlen, xhash, mtime)
#   #     select ch_no, s_cid as text, '' as cpath, title, chdiv, c_len, 0 as xhash, mtime
#   #     from src.chaps
#   #     SQL
#   # end

#   ###

#   def reload_from_remote!(stale : Time = Time.utc - 1.days,
#                           uname : String = "")
#     conf = Rmconf.load!(@sname)
#     parser = RawRmcata.new(conf, @sn_id, stale: stale)
#     chlist = parser.chap_list

#     @zinfo_db.open_tx { |db| chlist.each(&.upsert!(db: db)) }

#     # Rminit.new(
#     #   chap_count: chlist.size, latest_cid: chlist.last.s_cid,
#     #   status_str: parser.status_str, update_str: parser.update_str,
#     #   uname: uname, rtime: Time.utc.to_unix
#     # ).insert!(db: @rinit_db)
#   end
# end
