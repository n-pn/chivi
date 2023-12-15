require "../../_data/_data"

require "../_raw/raw_rmbook"
require "../_raw/raw_rmstem"

require "./util/rmrank"
require "./tsrepo"

class RD::Rmstem
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "rmstems", :postgres, strict: false

  field sname : String, pkey: true
  field sn_id : Int32, pkey: true

  field rtype : Int16 = 0_i16
  field srank : Int16 = 15_i16

  field rlink : String = ""   # remote catalog link
  field rtime : Int64 = 0_i64 # last remote update

  field btitle_zh : String = ""
  field author_zh : String = ""

  field btitle_vi : String = ""
  field author_vi : String = ""

  field cover_rm : String = ""
  field cover_cv : String = ""

  field intro_zh : String = ""
  field intro_vi : String = ""

  field genre_zh : String = ""
  field genre_vi : String = ""

  field status_str : String = ""
  field status_int : Int16 = 0_i16

  field update_str : String = ""
  field update_int : Int64 = 0_i64

  field latest_cid : String = ""
  field chap_count : Int32 = 0
  field chap_avail : Int32 = 0

  field view_count : Int32 = 0

  field multp : Int16 = 3_i16

  field wn_id : Int32 = 0 # map to wninfo_id
  field stime : Int64 = 0 # last synced_at
  field _flag : Int16 = 0 # multi purposes, if < 0 then the stem is inactive

  def initialize(@sname, @sn_id, @rlink = "")
  end

  ####

  def crepo : Tsrepo
    Tsrepo.load!(sroot: "rm#{@sname}/#{@sn_id}") do |repo|
      repo.owner = -1
      repo.stype = 2_i16
      repo.sname = @sname

      repo.sn_id = @sn_id
      repo.wn_id = @wn_id
      repo.pdict = @wn_id > 0 ? "wn#{@wn_id}" : "combine"

      repo.zname = @btitle_zh
      repo.vname = @btitle_vi

      repo.cover = @cover_rm

      repo.rm_slink = @rlink
      repo.rm_stime = @rtime

      repo.chmax = @chap_count
      repo.wn_id = @wn_id

      repo.plock = 0
      repo.multp = @multp

      repo.mtime = @update_int
      repo.view_count = @view_count
    end
  end

  def translate!
    hv_mt = MT::QtCore.hv_name

    @btitle_vi = hv_mt.translate @btitle_zh, true
    @author_vi = hv_mt.translate @author_zh, true
    @genre_vi = @genre_zh.split('\t').map! { |x| hv_mt.translate(x, true) }.join('\t')
    @intro_vi = HTTP::Client.post(CV_ENV.m1_host + "/_m1/qtran?format=txt", body: @intro_zh, &.body_io.gets_to_end)
  rescue ex
    Log.error(exception: ex) { ex }
  end

  # TODO: call from wninfo moel
  GET_WN_ID_SQL = <<-SQL
    select coalesce(id, 0) from wninfos where author_zh = $1 and btitle_zh = $2 limit 1
    SQL

  def fix_wn_id!
    author_zh, btitle_zh = BookUtil.fix_names(@author_zh, @btitle_zh)
    @wn_id = self.class.db.query_one GET_WN_ID_SQL, author_zh, btitle_zh, as: Int32
  end

  @[AlwaysInline]
  def alive?
    @rtype == 0 && @_flag >= 0
  end

  def rmrank
    Rmrank.index(@sname)
  end

  INC_VIEW_COUNT_SQL = <<-SQL
    update rmstems set view_count = view_count + $1
    where sname = $2 and sn_id = $3
    returning view_count
    SQL

  def inc_view_count!(value = 1)
    @view_count = @@db.query_one(INC_VIEW_COUNT_SQL, value, @sname, @sn_id, as: Int32)
  end

  UPDATE_FLAG_SQL = "update rmstems set _flag = $1 where sname = $2 and sn_id = $3"

  def update_flags!(@_flag : Int16)
    @@db.exec UPDATE_FLAG_SQL, _flag, @sname, @sn_id
    self
  end

  def update_stats!(chmax : Int32, mtime : Int64 = Time.utc.to_unix, persist : Bool = false)
    @stime = mtime if @stime < mtime
    @chap_count = chmax if @chap_count < chmax

    return unless persist

    query = @@schema.update_stmt(%w{chap_count stime})
    @@db.exec(query, @chap_count, @stime, @sname, @sn_id)
  end

  private def load_raw_stem!(crawl : Int32 = 1)
    return if @rtype > 2
    crawl = 0 unless self.alive?
    stale = Time.utc - reload_tspan(crawl)
    # raw_stem = RawRmstem.from_link(@rlink, stale: stale)
    RawRmstem.from_stem(@sname, @sn_id, stale: stale)
  rescue ex
    case ex.message || ""
    when .ends_with?("404") then self.update_flags!(-404_i16)
    when .ends_with?("301") then self.update_flags!(-301_i16)
    else                         raise ex
    end
    nil
  end

  def update!(crawl : Int32 = 1, regen : Bool = false, umode : Int32 = 1) : self | Nil
    unless raw_stem = load_raw_stem!(crawl: crawl)
      return self.tap { |x| x.crepo.update_vinfos! if umode > 0 }
    end

    # verify content changed by checking the latest chapter
    # not super reliable since some site reuse the latest chapter id for new chapter.
    # but since it is a rare occasion we can just ignore it
    if raw_stem.latest_cid == @latest_cid
      return unless regen || @chap_count == 0 # always redo in force crawl
    else
      @latest_cid = raw_stem.latest_cid
    end

    clist = raw_stem.extract_clist!
    @chap_count = clist.size

    self.crepo.tap do |crepo|
      crepo.chmax = @chap_count
      crepo.upsert_zinfos!(clist)

      if umode > 0
        spawn crepo.update_vinfos!
        @_flag = 1
      else
        @_flag = 0
      end

      crepo.upsert!
    end

    if raw_stem.update_str.empty?
      @update_int = Time.utc.to_unix
    else
      @update_str = raw_stem.update_str
      @update_int = raw_stem.update_int
    end

    # TODO: check if status exist and is updated
    unless raw_stem.status_str.empty?
      @status_str = raw_stem.status_str
      @status_int = raw_stem.status_int
    end

    # TODO: gen timestampt from html file modification time instead
    @rtime = Time.utc.to_unix

    @_flag == 1_i16 if @_flag == 0
    self.upsert!(db: @@db)
  end

  private def reload_tspan(crawl : Int32 = 1)
    case crawl
    when 2 then @status_int > 1 ? 30.minutes : 3.minutes # force crawl
    when 1 then @status_int > 1 ? 15.days : 30.minutes   # normal crawl
    else        10.years                                 # keep forever
    end
  end

  ###

  ALL_WN_SQL = @@schema.select_stmt do |sql|
    sql << " where wn_id = $1 "
    # sql << " order by srank asc, chap_count desc, _flag desc"
  end

  def self.all_by_wn(wn_id : Int32, uniq : Bool = false)
    stems = @@db.query_all(ALL_WN_SQL, wn_id, as: self)
    # TODO: sort in database
    stems.sort_by! { |x| {x.rmrank, -x.chap_count, -x._flag} }
    uniq ? stems.uniq!(&.sname) : stems
  end

  def self.find(sname : String, sn_id : Int32)
    get(sname, sn_id, &.<< " where sname = $1 and sn_id = $2")
  end

  def self.find!(sname : String, sn_id : Int32)
    get!(sname, sn_id, &.<< " where sname = $1 and sn_id = $2")
  end

  def self.from_html(bhtml : String,
                     sname : String, sn_id : Int32,
                     rtime = Time.utc.to_unix, force = false)
    entry = self.find(sname, sn_id) || new(sname, sn_id)
    return if !force && entry.rtime >= rtime

    input = RawRmbook.new(bhtml, sname: sname)
    return if input.btitle.empty?

    entry.btitle_zh = input.btitle
    entry.author_zh = input.author

    entry.cover_rm = input.cover
    entry.intro_zh = input.intro

    entry.genre_zh = "#{input.genre}\t#{input.xtags.gsub(" ", "\t")}".strip

    entry.status_int = input.status_int
    entry.status_str = input.status_str
    entry.update_str = input.update_str
    entry.update_int = input.update_int
    entry.latest_cid = input.latest_cid

    # entry.chap_count = raw_data.chap_count
    entry.rtime = rtime

    entry
  end

  def self.build_select_sql(
    btitle : String? = nil, author : String? = nil, status : Int32? = nil,
    wn_id : Int32? = nil, sname : String? = nil, genre : String? = nil,
    liked : Int32? = nil, order : String = "mtime"
  )
    args = [] of String | Int32

    query = String.build do |sql|
      sql << "select * from rmstems where 1 = 1"

      if sname
        args << sname
        sql << " and sname = $1"
      end

      if genre
        args << genre
        sql << " and genre_vi like '%' || $#{args.size} || '%'"
      end

      if wn_id
        args << wn_id
        sql << " and wn_id = $#{args.size}"
      end

      if status
        args << status
        sql << " and status = $#{args.size}"
      end

      if btitle
        args << btitle
        sql << " and _btitle_ts_ like '%' || scrub_name($#{args.size}) || '%'"
      end

      if author
        args << author
        sql << " and _author_ts_ like '%' || scrub_name($#{args.size}) || '%'"
      end

      if liked
        args << liked

        sql << <<-SQL
            and exists (
            select 1 from rdmemos as m
            where m.vu_id = $#{args.size}
            and m.sn_id = rmstems.sn_id
            and m.sname = 'rm' || rmstems.sname
            )
          SQL
      end

      case order
      when "rtime" then sql << " order by rtime desc"
      when "utime" then sql << " order by update_int desc"
      when "chaps" then sql << " order by chap_count desc"
      when "views" then sql << " order by view_count desc"
      end

      sql << " limit $#{args.size &+ 1} offset $#{args.size &+ 2}"
    end

    {query, args}
  end
end
