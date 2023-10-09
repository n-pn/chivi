require "crorm"

require "../../_data/_data"

require "./chrepo"
require "./wnchap"
require "./rmstem"

class RD::Wnstem
  ############

  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "wnseeds", :postgres, strict: false

  field wn_id : Int32 = 0, pkey: true
  field sname : String = "", pkey: true

  field s_bid : String = ""

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field rlink : String = "" # remote page link
  field rtime : Int64 = 0   # remote sync time

  field privi : Int16 = 0
  field multp : Int16 = 3

  field _flag : Int16 = 0
  field mtime : Int64 = 0

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter crepo : Chrepo do
    Chrepo.load("wn#{@sname}/#{@wn_id}").tap do |repo|
      repo.chmax = @chap_total
      repo.wn_id = @wn_id

      repo.gifts = 2
      repo.multp = @multp
    end
  end

  #########

  def initialize(@wn_id, @sname, @s_bid = wn_id.to_s)
    @privi = self.plock(sname).to_i16
  end

  def init!(force : Bool = false) : Nil
    return if !force && @_flag >= 0 && File.file?(Chinfo.db_path(@sname, @s_bid))
    return unless Chinfo.init!(@sname, @s_bid)

    @_flag = -@_flag

    query = @@schema.update_stmt(%w{_flag})
    @@db.exec(query, @_flag, @wn_id, @sname)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @sname
      jb.field "sn_id", @wn_id

      jb.field "chmax", @chap_total
      jb.field "utime", @mtime

      jb.field "multp", @multp
      jb.field "privi", @privi
      jb.field "gifts", 2

      jb.field "rlink", @rlink
      jb.field "rtime", @rtime
    }
  end

  @[AlwaysInline]
  def chap_plock(ch_no : Int32)
    ch_no <= gift_chaps ? 0 : self.plock
  end

  def remote?
    @sname[0] == '!' && Rmhost.remote?(@sname)
  end

  def active?
    remote? && Rmhost.from_sname!(@sname).active?
  end

  def plock(sname = @sname)
    case sname
    when "~avail" then 2
    when "~chivi" then 3
    else               3
    end
  end

  private def reload_tspan(crawl : Int32 = 1)
    case crawl
    when 2 then 3.minutes  # force crawl
    when 1 then 30.minutes # normal crawl
    else        10.years   # keep forever
    end
  end

  def update!(crawl : Int32 = 1, regen : Bool = false, umode : Int32 = 1) : Nil
    rstems = Rmstem.all_by_wn(@wn_id).sort_by(&.rmrank)

    active = rstems.find do |rstem|
      rstem.update!(crawl: crawl, regen: regen, umode: umode) if rstem.rtype == 0
      Log.debug { "#{rstem.sname}/#{rstem.sn_id}: #{rstem.chap_count}" }
      rstem
    rescue
      nil
    end

    unless active
      self.crepo.update_vinfos! if umode > 0
      @rtime = Time.utc.to_unix
      return self.upsert!(db: @@db)
    end

    @mtime = active.update_int if @mtime < active.update_int
    @chap_total = active.chap_count if @chap_total < active.chap_count

    clist = active.crepo.get_all(start: 1, limit: active.chap_count)

    self.crepo.tap do |crepo|
      crepo.chmax = @chap_total
      crepo.upsert_zinfos!(clist)

      if umode > 0 && @chap_total > 0
        crepo.update_vinfos!
        @_flag == 1_i16 if @_flag == 0
      else
        @_flag = 0
      end
    end

    @rtime = Time.utc.to_unix
    self.upsert!(db: @@db)
  end

  ####

  def upsert!(query = @@schema.upsert_stmt, args_ = self.db_values, db = @@db)
    db.write_one(query, *args_, as: self.class)
  end

  ###

  def delete_chaps!(from : Int32 = 1, upto : Int32 = self.chap_total)
    query = "delete from chinfos where ch_no >= $1 and ch_no <= $2"
    self.crepo.exec query, from, upto
    @chap_total = from &- 1
  end

  #######

  def self.all_by_sname(sname : String) : Array(self)
    stmt = self.schema.select_stmt(&.<< " where sname = $1")
    self.db.query_all(stmt, sname, as: self)
  end

  def self.all_by_wn_id(wn_id : Int32) : Array(self)
    stmt = self.schema.select_stmt(&.<< " where wn_id = $1 and sname like '~%'")
    self.db.query_all(stmt, wn_id, as: self)
  end

  def self.get(wn_id : Int32, sname : String) : self | Nil
    stmt = self.schema.select_stmt(&.<< " where wn_id = $1 and sname = $2")
    self.db.query_one?(stmt, wn_id, sname, as: self)
  end

  def self.get!(wn_id : Int32, sname : String) : self
    self.get(wn_id, sname) || raise "wn_seed [#{wn_id}/#{sname}] not found!"
  end

  def self.load(wn_id : Int32, sname : String)
    self.load(wn_id, sname) { new(wn_id, sname) }
  end

  def self.load(wn_id : Int32, sname : String, &)
    self.get(wn_id, sname) || yield
  end

  def self.find(id : Int32)
    self.find!(id) rescue nil
  end

  def self.find!(id : Int32)
    stmt = self.schema.select_stmt(&.<< " where id = $1 limit 1")
    self.db.query_all(stmt, id, as: self)
  end

  def self.upsert!(wn_id : Int32, sname : String, s_bid = wn_id)
    self.db.exec <<-SQL, wn_id, sname, s_bid
      insert into wnseeds(wn_id, sname, s_bid) values ($1, $2, $3)
      on conflict do update set s_bid = excluded.s_bid
    SQL
  end

  ###
end
