require "./czdata"
require "./cvtran"

require "./unlock"
require "../_raw/raw_rmchap"

class RD::Tsrepo
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "tsrepos", :postgres, strict: false

  field id : Int32, auto: true

  field sroot : String, pkey: true
  field owner : Int32 = -1

  field stype : Int16 = -1_i16 # 0: wn, 1: up, 2: rm, 3: ?
  field sn_id : Int32 = 0
  field sname : String = ""

  field zname : String = ""
  field vname : String = ""
  field cover : String = ""

  field wn_id : Int32 = 0
  field pdict : String = ""

  field chmax : Int32 = 0
  field mtime : Int64 = 0_i64

  field plock : Int16 = 0_i16
  field multp : Int16 = 4_i16

  field rm_stime : Int64 = 0_i64
  field rm_slink : String = ""
  field rm_chmin : Int32 = 0

  field _flag : Int16 = 0_i16

  field view_count : Int32 = 0
  field like_count : Int32 = 0
  field star_count : Int32 = 0

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter zdata_db : Crorm::SQ3 { Czdata.db(@sname, @sn_id) }

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter vtran_db : Crorm::SQ3 { Cvtran.db(@sname, @sn_id) }

  def initialize(@sroot)
  end

  def fix_pdict!
    case
    when @stype == 0 then @pdict = "wn#{@sn_id}"
    when @wn_id >= 1 then @pdict = "wn#{@wn_id}"
    when @stype == 1 then @pdict = "up#{@sn_id}"
    else                  @pdict = "combine"
    end
  end

  # def read_privi
  #   @stype > 1 ? 0 : -1
  # end

  def read_privi(ch_no : Int32)
    ch_no > 24 ? 0_i16 : -1_i16
  end

  def conf_privi(vu_id : Int32 = 0)
    case @stype
    when 0 then 2
    when 1 then 0
    else        3
    end
  end

  def edit_privi(vu_id : Int32)
    case @stype
    when 0 then {vu_id, 0}
    when 1 then {@owner, 1}
    else        {vu_id, 2}
    end
  end

  def admin(vu_id : Int32 = 0)
    @stype == 1 ? @owner : vu_id
  end

  @[AlwaysInline]
  def get_zdata(ch_no : Int32, rmode : Int32 = 0)
    self.zdata_db.open_rw do |db|
      zdata = Czdata.load(db, ch_no: ch_no)
      zdata.save_ztext!(db: db) if rmode > 0 && zdata.init_by_zlink(force: rmode > 1)
      zdata
    end
  end

  ###

  SET_CHMAX_SQL = <<-SQL
    update tsrepos set chmax = $1, mtime = $2, rm_chmin = $3
    where sname = $4 and sn_id = $5
    SQL

  def set_chmax(chmax : Int32, force : Bool = false, persist : Bool = false)
    return unless force || chmax > @chmax
    @rm_chmin = chmax if @rm_chmin < chmax

    @chmax = chmax
    @mtime = Time.utc.to_unix

    return unless persist
    @@db.query(SET_CHMAX_SQL, chmax, @mtime, @rm_chmin, @sname, @sn_id)
  rescue
    self.upsert!
  end

  def get_sname
    return @sname unless @sname.empty?
    @sroot.split('/')[3..]
  end

  def free_until : Int32
    {@chmax // 4, 120}.min
  end

  @[AlwaysInline]
  def free_chap?(ch_no : Int32)
    ch_no < self.free_until
  end

  # returning user_cost multp and owner_get multp
  #
  def mt_multp(ch_no : Int32, vu_id : Int32, privi : Int32)
    return {0_i16, 0_i16} if ch_no <= self.free_until || self.multp == -1

    user_cost = privi > 3 ? 0_i16 : privi > 2 ? 1_i16 : 2_i16
    owner_got = 1_i16

    case @sname[0]?
    when '~'
      user_cost &-= 1_i16
    when '@'
      if vu_id == @owner
        owner_got &-= 1_i16
        user_cost &-= 1_i16
      end
    end

    {user_cost > 0 ? user_cost : 0_i16, owner_got}
  end

  ###

  def update_from_link!(cmode : Int32 = 1, persist : Bool = true)
    return false if @rm_slink.empty?

    @rm_stime = Time.utc.to_unix

    origin = RawRmstem.from_link(@rm_slink, stale: Time.utc - reload_tspan(cmode))
    chlist = origin.extract_clist!

    return false if chlist.size <= @rm_chmin
    @chmax = chlist.size if @chmax < chlist.size

    self.upsert_zinfos!(chlist[@rm_chmin..])

    if origin.update_str.empty?
      @mtime = @rm_stime
    else
      @mtime = {origin.update_int, @mtime}.max
    end

    self.upsert! if persist
    true
  end

  private def reload_tspan(cmode : Int32 = 1)
    case cmode
    when 2 then 3.minutes  # force crawl
    when 1 then 30.minutes # normal crawl
    else        10.years   # keep forever
    end
  end

  ###

  @[AlwaysInline]
  def get_all(start : Int32 = 1, limit : Int32 = 32)
    chaps = Czdata.get_all(self.zdata_db, start: start, limit: limit, chmax: @chmax)
    load_vtran(chaps)
    # TODO: load
  end

  @[AlwaysInline]
  def get_top(start : Int32 = @chmax, limit : Int32 = 4)
    chaps = Czdata.get_top(self.zdata_db, start: start, limit: limit)
    load_vtran(chaps)
  end



  def load_vtran(chaps : Array(Czdata))
    zstrs = [] of String

    chaps.each do |chap|
      zstrs << chap.title unless chap.title.empty?
      zstrs << chap.chdiv unless chap.chdiv.empty?
    end

    trans = Cvtran.get_trans(self.vtran_db, zstrs, @wn_id)

    chaps.each do |chap|
      chap.title = trans.put_if_absent(chap.title, chap.title)
      chap.chdiv = trans.put_if_absent(chap.chdiv, chap.chdiv) unless chap.chdiv.empty?
    end

    chaps
  rescue ex
    Log.error(exception: ex) { @sroot }

    chaps
  end



  @[AlwaysInline]
  def suggest_chdiv(ch_no : Int32)
    query = "select chdiv from czdata where ch_no <= $1 and chdiv <> '' order by ch_no desc limit 1"
    self.zdata_db.open_ro { |db| db.query_one?(query, ch_no, as: String) || "" }
  end

  @[AlwaysInline]
  def get_cinfo(ch_no : Int32)
    get_cinfo(ch_no) { Czdata.new(ch_no) }
  end

  @[AlwaysInline]
  def get_cinfo(ch_no : Int32, &)
    get_all(ch_no &- 2, ch_no &+ 2).find(&.ch_no.== ch_no) || yield
  end


  ###

  @[AlwaysInline]
  def last_ch_no
    Czdata.find_last(self.info_db).try(&.ch_no) || 0
  end

  @[AlwaysInline]
  def word_count(chmin : Int32, chmax : Int32) : Int32
    Czdata.word_count(self.info_db, chmin, chmax)
  end

  @[AlwaysInline]
  def upsert_zinfos!(clist : Array(Czdata))
    # latest = clist.last.ch_no
    # @chmax = latest if @chmax < latest
    self.zdata_db.open_tx { |db| clist.each(&.save_zinfo!(db: db)) }
  end

  ####

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix)
    @mtime = mtime if @mtime < mtime
    @chmax = chmax if @chmax < chmax
    @@db.exec(@@schema.update_stmt(%w{chmax mtime}), @chmax, @mtime, @sroot)
  end

  def inc_view_count!(value = 1)
    query = <<-SQL
      update tsrepos set view_count = view_count + $1
      where sroot = $2 returning view_count
      SQL

    @view_count = @@db.query_one(query, value, @sroot, as: Int32)
  end

  # repo.update_vinfos!
  # repo.init_text_db!(uname: @sname)

  ###

  CACHE = {} of String => self

  def self.find(sroot : String) : self | Nil
    self.db.query_one?("select * from tsrepos where sroot = $1", sroot, as: self)
  end

  def self.load!(sroot : String, &)
    CACHE[sroot] ||= self.find(sroot) || begin
      crepo = new(sroot)
      yield crepo
      crepo.upsert!
    end
  end

  def self.load!(sroot : String)
    load!(sroot) { raise NotFound.new("Nguồn chương không tồn tại!") }
  end

  def delete_chaps!(from : Int32 = 1, upto : Int32 = self.chmax)
    @chmax = {from - 1, 0}.max
    # @@db.exec "update tsrepos set chmax = $1 where sname = $2 and sn_id = $3", @chmax, @sname, @sn_id

    query = "delete from czdata where ch_no >= $1 and ch_no <= $2"
    self.zdata_db.open_rw(&.exec query, from, upto)
  end

  #
  def self.get_all(
    vu_id : Int32 = 0, state : Int32 = -1, stars : Int32 = -1,
    stype : String = "", wn_id : Int32 = 0, order : String = "mtime",
    limit : Int32 = 32, offset : Int32 = 0
  ) : Array(self)
    args = [] of Int32

    query = String.build do |sql|
      sql << "where 1 = 1"

      if vu_id > 0 && (state > -1 || stars > -1)
        args << vu_id

        if state > -1
          args << state
          sql << " and id in (select rd_id from rdmemos where vu_id = $1 and rd_state "
          sql << (state == 0 ? ">=" : "=") << " $2)"
        end

        if stars > -1
          args << stars
          sql << " and id in (select rd_id from rdmemos where vu_id = $1 and rd_stars "
          sql << (stars == 0 ? ">=" : "=") << " $#{args.size})"
        end
      end

      if wn_id > 0
        args << wn_id
        sql << "and wn_id = $#{args.size}"
      end

      case stype
      when "wn" then sql << " and sname like '~%'"
      when "up" then sql << " and sname like '@%'"
      when "rm" then sql << " and sname like '!%'"
      end

      case order
      when "ctime" then sql << " order by id desc"
      when "views" then sql << " order by view_count desc"
      when "likes" then sql << " order by like_count desc"
      when "stype" then sql << " order by stype asc"
      else              sql << " order by mtime desc"
      end

      sql << " limit $#{args.size + 1} offset $#{args.size + 2}"
      args << limit << offset
    end

    self.get_all(args: args, db: self.db, &.<< query)
  end

  def self.fetch_all(ids : Array(Int32))
    self.get_all(args: [ids], db: self.db, &.<< "where id = any($1)")
  end
end
