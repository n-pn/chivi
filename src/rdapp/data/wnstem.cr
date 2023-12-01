# require "crorm"

# require "../../_data/_data"

# require "./tsrepo"
# require "./rmstem"

# class RD::Wnstem
#   ############

#   class_getter db : DB::Database = PGDB

#   include Crorm::Model
#   schema "wnseeds", :postgres, strict: false

#   field wn_id : Int32 = 0, pkey: true
#   field sname : String = "", pkey: true

#   field s_bid : String = ""

#   field chap_total : Int32 = 0
#   field chap_avail : Int32 = 0

#   field rlink : String = "" # remote page link
#   field rtime : Int64 = 0   # remote sync time

#   field privi : Int16 = 0
#   field multp : Int16 = 3

#   field _flag : Int16 = 0
#   field mtime : Int64 = 0

#   field created_at : Time = Time.utc
#   field updated_at : Time = Time.utc

#   def crepo : Tsrepo
#     Tsrepo.load!("wn#{@sname}/#{@wn_id}") do |r|
#       r.owner = -1
#       r.stype = 0_i16
#       r.sname = @sname

#       r.sn_id = @wn_id
#       r.wn_id = @wn_id

#       r.chmax = @chap_total

#       r.plock = 0
#       r.multp = @multp

#       r.mtime = @mtime
#     end
#   end

#   #########

#   def initialize(@wn_id, @sname, @s_bid = wn_id.to_s)
#     @privi = 3_i16
#   end

#   def to_json(jb : JSON::Builder)
#     jb.object {
#       jb.field "sname", @sname
#       jb.field "sn_id", @wn_id

#       jb.field "chmax", @chap_total
#       jb.field "utime", @mtime

#       jb.field "multp", @multp
#       jb.field "privi", @privi

#       jb.field "rlink", @rlink
#       jb.field "rtime", @rtime
#     }
#   end

#   @[AlwaysInline]
#   def chap_plock(ch_no : Int32)
#     ch_no <= gift_chaps ? 0 : self.plock
#   end

#   private def reload_tspan(crawl : Int32 = 1)
#     case crawl
#     when 2 then 3.minutes  # force crawl
#     when 1 then 30.minutes # normal crawl
#     else        10.years   # keep forever
#     end
#   end

#   def update!(crawl : Int32 = 1, regen : Bool = false, umode : Int32 = 1) : Nil
#     rstems = Rmstem.all_by_wn(@wn_id, uniq: true)
#     rstems.reject! { |x| x.rtype > 0 && x.chap_count == 0 }

#     return self.update_rtime! if rstems.empty?

#     start = 1

#     rstems.first(4).each do |rstem|
#       rstem.update!(crawl: crawl, regen: regen, umode: umode) if rstem.alive?

#       chmax = rstem.chap_count
#       next if chmax < start

#       clist = rstem.crepo.get_all(start: start, limit: chmax &- start &+ 1)
#       self.crepo.upsert_zinfos!(clist)

#       start = chmax

#       mtime = rstem.update_int
#       self.update_stats!(chmax, mtime, persist: false)
#     end

#     if umode > 0 && @chap_total > 0
#       self.crepo.chmax = @chap_total
#       self.crepo.update_vinfos!
#       self.crepo.upsert!

#       @_flag == 1_i16 if @_flag == 0
#     else
#       @_flag = 0
#     end

#     @rtime = Time.utc.to_unix
#     self.upsert!(db: @@db)
#   end

#   def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix, persist : Bool = false)
#     @mtime = mtime if @mtime < mtime

#     if @chap_total < chmax
#       @chap_total = chmax
#       self.crepo.chmax = chmax
#     end

#     return unless persist

#     query = @@schema.update_stmt(%w{chap_total mtime})
#     @@db.exec(query, @chap_total, @mtime, @wn_id, @sname)
#   end

#   UPDATE_FIELD_SQL = "update #{@@schema.table} set %s = $1 where sname = $2 and wn_id = $3"

#   def update_rtime!(@rtime = Time.utc.to_unix)
#     query = UPDATE_FIELD_SQL % "rtime"
#     @@db.exec query, rtime, @sname, @wn_id
#     self
#   end

#   def update_flags!(@_flag : Int16)
#     query = UPDATE_FIELD_SQL % "_flag"
#     @@db.exec query, _flag, @sname, @wn_id
#     self
#   end

#   ###

#   def delete_chaps!(from : Int32 = 1, upto : Int32 = self.chap_total)
#     query = "delete from chinfos where ch_no >= $1 and ch_no <= $2"
#     self.crepo.exec query, from, upto
#     @chap_total = from &- 1
#   end

#   #######

#   def self.all_by_sname(sname : String) : Array(self)
#     stmt = self.schema.select_stmt(&.<< " where sname = $1")
#     self.db.query_all(stmt, sname, as: self)
#   end

#   def self.all_by_wn_id(wn_id : Int32) : Array(self)
#     stmt = self.schema.select_stmt(&.<< " where wn_id = $1 and sname like '~%'")
#     self.db.query_all(stmt, wn_id, as: self)
#   end

#   def self.find(wn_id : Int32, sname : String) : self | Nil
#     stmt = self.schema.select_stmt(&.<< " where wn_id = $1 and sname = $2")
#     self.db.query_one?(stmt, wn_id, sname, as: self)
#   end

#   def self.find!(wn_id : Int32, sname : String) : self
#     self.find(wn_id, sname) || raise "wn_seed [#{wn_id}/#{sname}] not found!"
#   end

#   def self.load(wn_id : Int32, sname : String)
#     self.load(wn_id, sname) { new(wn_id, sname) }
#   end

#   def self.load(wn_id : Int32, sname : String, &)
#     self.find(wn_id, sname) || yield
#   end

#   ###
# end
