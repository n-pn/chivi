require "crorm"

require "../../_data/_data"
require "../../zroot/html_parser/raw_rmcata"

require "./seed_type"

class WN::Wnseed
  ############

  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "wnseeds", :postgres

  field id : Int32, auto: true

  field wn_id : Int32 = 0, pkey: true
  field sname : String = "", pkey: true

  field s_bid : String = ""

  field chap_total : Int32 = 0
  field chap_avail : Int32 = 0

  field rlink : String = "" # remote page link
  field rtime : Int64 = 0   # remote sync time

  field privi : Int16 = 0
  field _flag : Int16 = 0

  field mtime : Int64 = 0

  # field created_at : Time = Time.utc
  # field updated_at : Time = Time.utc

  @[DB::Field(ignore: true)]
  getter chap_list : Crorm::SQ3 { Chinfo.load(@sname, @s_bid) }

  @[DB::Field(ignore: true)]
  getter seed_type : SeedType { SeedType.parse(sname) }

  #########

  def initialize(@wn_id, @sname, @s_bid = wn_id.to_s, @privi = 2_i16)
  end

  def init!(force : Bool = false) : Nil
    return unless force || _flag < 0

    Dir.mkdir_p("var/texts/rgbks/#{@sname}/#{@s_bid}")
    Chinfo.init!(@sname, @s_bid)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @sname
      jb.field "snvid", @s_bid

      jb.field "chmax", @chap_total
      jb.field "utime", @mtime

      jb.field "privi", @privi
    }
  end

  def remote?
    self.seed_type.globs?
  end

  def owner?(uname : String = "")
    @sname == "@#{uname}"
  end

  def edit_privi(uname = "")
    self.seed_type.edit_privi(is_owner: owner?(uname))
  end

  def read_privi(uname = "")
    self.seed_type.read_privi(is_owner: owner?(uname), base_privi: privi.to_i)
  end

  def lower_read_privi_count
    chap_count = @chap_total // 2
    chap_count > 40 ? chap_count : 40
  end

  def unpack_old_text!(force : Bool = false)
    return unless force || @chap_avail < 0

    raise "to be implemented!"

    # chaps = self.chap_list.all(&.<< "where ch_no > 0")

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
    @id = entry.id
    self
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @chap_total = chmax if @chap_total < chmax
    @mtime = mtime if @mtime < mtime

    query = @@schema.update_stmt(%w{chap_total mtime})
    @@db.exec(query, @chap_total, @mtime, @wn_id, @sname)
  end

  ###

  def refresh_chlist!(mode : Int32 = 1)
    stale = mode > 0 ? Time.utc - 3.minutes : Time.utc - 30.minutes

    if self.remote?
      rmcata = ZR::RawRmcata.from_seed(@sname, @s_bid, stale: stale)
    elsif !@rlink.empty?
      rmcata = ZR::RawRmcata.from_link(@rlink, stale: stale)
    else
      # Do nothing
    end

    sync_with_remote!(rmcata, mode: mode) if rmcata

    # TODO: smart reload translation instead of force regen
    self.update_chap_vinfos!
  end

  private def sync_with_remote!(rmcata : ZR::RawRmcata, mode : Int32 = 0)
    chlist = rmcata.chap_list

    return if chlist.empty?
    max_ch_no = chlist.size

    # FIXME: check for real last_chap and offset
    # if max_ch_no > 0
    #   chap_list = chap_list[max_ch_no..]
    # end

    # @_flag = parser.status_int.to_i

    self.upsert_chap_zinfos!(chlist)
    self.update_stats!(max_ch_no, rmcata.update_int)
  end

  private def upsert_chap_zinfos!(chlist : Array(ZR::Chinfo))
    Chinfo.upsert_zinfos!(self.chap_list, chlist)
  end

  private def update_chap_vinfos!(chmin = 1, chmax = 99999)
    ch_nos, zinfos = Chinfo.get_zinfos(self.chap_list, chmin, chmax)
    output = Chinfo.gen_vinfos_from_mt(ch_nos, zinfos, @wn_id)
    Chinfo.update_vinfos!(self.chap_list, output)
  end

  ###

  def word_count(chmin = 1, chmax = @chap_total) : Int32
    Chinfo.word_count(self.chap_list, chmin, chmax)
  end

  def get_chaps(pg_no : Int32, limit = 32)
    chmax = pg_no &* limit
    chmin = chmax &- limit

    chmax = @chap_total if chmax > @chap_total
    Chinfo.get_all(self.chap_list, chmin: chmin, chmax: chmax)
  end

  def top_chaps(limit : Int32 = 4)
    chmax = @chap_total
    Chinfo.get_top(self.chap_list, chmax: chmax, limit: limit)
  end

  def find_chap(ch_no : Int32)
    Chinfo.find(self.chap_list, ch_no)
  end

  def find_prev(ch_no : Int32)
    Chinfo.find_prev(self.chap_list, ch_no)
  end

  def find_succ(ch_no : Int32)
    Chinfo.find_succ(self.chap_list, ch_no)
  end

  def save_chap!(chinfo : Chinfo) : Nil
    chinfo.upsert!(db: self.chap_list)
  end

  def delete_chaps!(from : Int32 = 1, upto : Int32 = self.chap_total)
    query = "delete from chinfos where ch_no >= $1 and ch_no <= $2"
    self.chap_list.exec query, from, upto
    @chap_total = from &- 1
  end

  #######

  def self.all(wn_id : Int32) : Array(self)
    stmt = self.schema.select_stmt(&.<< " where wn_id = $1 order by mtime desc")
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

  def self.soft_delete!(wn_id : Int32, sname : String)
    self.db.exec <<-SQL, wn_id, sname
      update wnseeds set wn_id = -wn_id where wn_id = $1 and sname = $2
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
