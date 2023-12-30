require "./chinfo"
require "./cztext"

require "./unlock"
require "../_raw/raw_rmchap"

class RD::Tsrepo
  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "tsrepos", :postgres, strict: false

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
  getter info_db : Crorm::SQ3 { Chinfo.db(sroot) }

  @[DB::Field(ignore: true, auto: true)]
  @[JSON::Field(ignore: true)]
  getter text_db : Cztext { Cztext.new(sroot) }

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

  def read_privi
    @stype > 1 ? 0 : -1
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

  ###

  def load_raw_part(cinfo : Chinfo, p_idx = 1, regen : Bool = false)
    ztext = self.text_db.get_chap_text(cinfo.ch_no)

    if (regen || !ztext) && !cinfo.rlink.empty?
      ztext = self.seed_ztext!(cinfo, force: regen)
    end

    if ztext
      parts = ztext.split("\n\n")
      title = parts[0].lines.last
      ptext = parts[p_idx]? || ""

      cpart = "#{title}\n#{ptext}"
      cksum = HashUtil.fnv_1a(cpart)
      p_max = parts.size &- 1
    else
      cpart = cinfo.ztitle
      cksum = 0
      p_max = 0
    end

    {cpart.gsub('　', ""), cksum, p_max}
  end

  def seed_ztext!(cinfo : Chinfo, force : Bool = false)
    stale = Time.utc - (force ? 2.minutes : 20.years)
    raw_chap = RawRmchap.from_link(cinfo.rlink, stale: stale)

    title, lines = raw_chap.parse_page!
    ztext = Cztext.fix_raw(lines, title: title)

    self.text_db.save_text!(
      ch_no: cinfo.ch_no, ztext: ztext,
      chdiv: cinfo.zchdiv, smode: 0,
      zipping: true
    )

    cinfo.uname = raw_chap.sname
    cinfo.mtime = Time.utc.to_unix
    cinfo.sizes = ztext.split("\n\n").map(&.size).join(' ')

    cinfo.upsert!(db: self.info_db)

    ztext
  rescue ex
    Log.error(exception: ex) { cinfo.rlink }
    nil
  end

  def save_chap!(
    ch_no : Int32, title : String,
    ztext : String, chdiv : String = "",
    smode : Int32 = 0, spath : String = "",
    uname : String = "", mtime = 0,
    persist : Bool = true
  )
    self.text_db.save_text!(
      ch_no: ch_no, ztext: ztext,
      chdiv: chdiv, smode: smode,
      zipping: persist
    )

    cinfo = self.get_cinfo(ch_no)

    cinfo.ztitle = title
    cinfo.zchdiv = chdiv

    cinfo.uname = uname
    cinfo.mtime = mtime
    cinfo.spath = spath
    cinfo.sizes = ztext.split("\n\n").map(&.size).join(' ')

    cinfo.upsert!(db: self.info_db) if persist
    cinfo
  end

  ###

  SET_CHMAX_SQL = "update tsrepos set chmax = $1 where sroot = $2"

  def set_chmax(chmax : Int32, force : Bool = false, persist : Bool = false)
    return unless force || chmax > @chmax

    @chmax = chmax
    @mtime = Time.utc.to_unix

    return unless persist
    @@db.query(SET_CHMAX_SQL, chmax, @sroot) rescue self.upsert!
  end

  def get_sname
    return @sname unless @sname.empty?
    @sroot.split('/')[3..]
  end

  def free_until : Int32
    auto_free = @chmax // 4
    auto_free < 150 ? auto_free : 150
  end

  @[AlwaysInline]
  def free_chap?(ch_no : Int32)
    ch_no < self.free_until
  end

  # returning user multp and real multp
  def chap_multp(ch_no : Int32, vu_id : Int32, privi : Int32)
    return {0_i16, 0_i16} if free_chap?(ch_no)
    vu_id == @owner ? {1_i16, 0_i16} : {5_i16 &- privi, 4_i16}
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
    Chinfo.get_all(self.info_db, start: start, limit: limit, chmax: @chmax)
  end

  @[AlwaysInline]
  def get_top(start : Int32 = @chmax, limit : Int32 = 4)
    Chinfo.get_top(self.info_db, start: start, limit: limit)
  end

  @[AlwaysInline]
  def get_chdiv(ch_no : Int32)
    Chinfo.get_chdiv(self.info_db, ch_no)
  end

  @[AlwaysInline]
  def get_cinfo(ch_no : Int32)
    get_cinfo(ch_no) { Chinfo.new(ch_no) }
  end

  def get_cinfo(ch_no : Int32, &)
    Chinfo.find(self.info_db, ch_no) || yield
  end

  ###

  @[AlwaysInline]
  def part_name(cinfo : Chinfo, p_idx : Int32)
    "#{@sroot}/#{cinfo.ch_no}-#{cinfo.cksum}-#{p_idx}"
  end

  ###

  ###

  @[AlwaysInline]
  def last_ch_no
    Chinfo.find_last(self.info_db).try(&.ch_no) || 0
  end

  @[AlwaysInline]
  def word_count(chmin : Int32, chmax : Int32) : Int32
    Chinfo.word_count(self.info_db, chmin, chmax)
  end

  @[AlwaysInline]
  def upsert_zinfos!(clist : Array(Chinfo))
    # latest = clist.last.ch_no
    # @chmax = latest if @chmax < latest
    Chinfo.upsert_zinfos!(self.info_db, clist)
  end

  @[AlwaysInline]
  def update_vinfos!(start : Int32 = 1, limit : Int32 = 99999)
    Chinfo.update_vinfos!(@sroot, wn_id: @wn_id, start: start, limit: limit)
  end

  ####

  # def save_raw_from_text!(cinfo : Chinfo, ztext : String, uname : String = "")
  #   lines = ChapUtil.split_lines(ztext)
  #   cinfo.ztitle = lines.first if cinfo.ztitle.empty?

  #   self.do_save_raw!(cinfo, lines)
  # end

  # private def do_save_raw!(cinfo : Chinfo, paras : Array(String), title : String = paras.shift)
  #   parts, sizes, cksum = ChapUtil.split_parts(paras: paras, title: title)

  #   cinfo.cksum = ChapUtil.cksum_to_s(cksum)
  #   cinfo.sizes = sizes.join(' ')

  #   parts.each_with_index do |ptext, p_idx|
  #     cdata = Chpart.new(part_name(cinfo, p_idx))
  #     cdata.save_raw!(ptext, p_idx > 0 ? title : nil)
  #   end

  #   cinfo.mtime = Time.utc.to_unix
  #   cinfo.upsert!(db: self.info_db)
  # end

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
end
