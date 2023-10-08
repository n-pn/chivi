require "crorm"

require "../../_data/_data"
require "../_raw/raw_rmstem"

require "./chrepo"
require "./wnchap"

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
  field multp : Int16 = 4

  field _flag : Int16 = 0
  field mtime : Int64 = 0

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter crepo : Chrepo do
    Chrepo.load("wn#{@sname}/#{@wn_id}").tap do |repo|
      repo.zname = ""
      repo.chmax = @chap_total
      repo.wn_id = @wn_id
      repo.gifts = 2
      repo.plock = @privi.to_i

      repo.update_vinfos!
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
      jb.field "sn_id", @s_bid

      jb.field "chmax", @chap_total
      jb.field "utime", @mtime

      jb.field "multp", @multp
      jb.field "privi", @privi
      jb.field "gifts", 2
    }
  end

  @[AlwaysInline]
  def gift_chaps
    gift_chaps = @chap_total // 2
    gift_chaps < 40 ? 40 : gift_chaps
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
    when "~draft" then 1
    when "~avail" then 2
    when "~chivi" then 3
    else               3
    end
  end

  def unpack_old_text!(force : Bool = false)
    return unless force || @chap_avail < 0

    raise "to be implemented!"

    # chaps = self.crepo.all(&.<< "where ch_no > 0")

    # clist.open_ro do |db|
    #   sql = "select ch_no, s_cid from chaps"

    #   db.query_each(sql) do |rs|
    #     ch_no, s_cid = rs.read(Int32, Int32)
    #     txt_path = TextStore.gen_txt_path(sname, s_bid, s_cid)
    #     if File.file?(txt_path)
    #       c_len = File.read(txt_path, encoding: "GB18030").size
    #       avail += 1 if c_len > 0
    #     else
    #       c_len = 0
    #     end

    #     stats << {c_len, ch_no}
    #   end
    # end

    # @repo.open_tx do |db|
    #   query = "update chaps set c_len = ? where ch_no = ?"
    #   stats.each { |c_len, ch_no| db.exec(query, c_len, ch_no) }
    # end

    # avail

    # self.upsert!
  end

  ####

  def bump_mtime(mtime : Int64, force : Bool = false)
    @mtime = mtime if mtime > 0 || force
  end

  def bump_chmax(chmax : Int32, force : Bool = false)
    return unless force || chmax > self.chap_total
    @chap_total = chmax
  end

  def upsert!(query = @@schema.upsert_stmt, args_ = self.db_values, db = @@db)
    entry = db.write_one(query, *args_, as: self.class)
    self
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @chap_total = chmax if @chap_total < chmax
    @mtime = mtime if @mtime < mtime

    query = @@schema.update_stmt(%w{chap_total mtime})
    @@db.exec(query, @chap_total, @mtime, @wn_id, @sname)

    self.crepo.chmax = @chap_total
  end

  ###

  private def remote_reload_tspan(_mode : Int32 = 1)
    case _mode
    when 2 then 3.minutes
    when 1 then 30.minutes
    else        10.years
    end
  end

  def reload_chlist!(mode : Int32 = 1)
    stale = Time.utc - remote_reload_tspan(mode)

    if self.remote?
      rmstem = RawRmstem.from_stem(@sname, @s_bid, stale: stale) rescue nil
    elsif !@rlink.empty?
      rmstem = RawRmstem.from_link(@rlink, stale: stale) rescue nil
    else
      # Do nothing
    end

    if rmstem && mode >= 0
      sync_with_remote!(rmstem, mode: mode) rescue nil
    end

    # TODO: smart reload translation instead of force regen
    self.update_chap_vinfos!
  end

  private def sync_with_remote!(rmstem : RawRmstem, mode : Int32 = 0)
    clist = rmstem.extract_clist!
    return if clist.empty?

    self.crepo.upsert_zinfos!(clist)
    self.update_stats!(clist.size, rmstem.update_int)
  end

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

  def self.auto_create_privi(sname : String, uname : String) : Int32?
    case SeedType.parse(sname)
    when .draft? then 1
    when .chivi? then 2
    when .users? then 2
    else              nil
    end
  end
end
