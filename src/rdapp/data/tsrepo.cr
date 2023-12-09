require "./chinfo"
require "./czdata"
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
  getter text_db : Crorm::SQ3 { Czdata.db(sroot) }

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

  TXT_DIR = "var/texts"

  def mkdirs!
    Dir.mkdir_p("#{TXT_DIR}/#{@sroot}")
    Dir.mkdir_p(File.dirname("var/stems/#{@sroot}"))
  end

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
    auto_free < 120 ? auto_free : 120
  end

  @[AlwaysInline]
  def free_chap?(ch_no : Int32)
    ch_no < self.free_until
  end

  def chap_mutlp(ch_no : Int32, vu_id : Int32, privi : Int32)
    return {0_i16, 0_i16} if vu_id == @owner || free_chap?(ch_no)
    {@multp > privi ? @multp &- privi : 0_i16, @multp}
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
  def find(ch_no : Int32)
    Chinfo.find(self.info_db, ch_no)
  end

  @[AlwaysInline]
  def get_chdiv(ch_no : Int32)
    Chinfo.get_chdiv(self.info_db, ch_no)
  end

  @[AlwaysInline]
  def load(ch_no : Int32)
    find(ch_no) || Chinfo.new(ch_no)
  end

  FIND_ZDATA_SQL = <<-SQL
    select * from czinfos
    where ch_no = $1 and cksum <> 0
    order by mtime desc limit 1
    SQL

  @[AlwaysInline]
  def get_zdata(ch_no : Int32)
    self.text_db.query_one? FIND_ZDATA_SQL, ch_no, as: Czdata
  end

  ###

  def init_text_db!(uname = "")
    ignore = self.text_db.open_ro(&.query_all("select ch_no from czinfos where cksum <> 0", as: Int32).to_set)

    cinfos = self.get_all(limit: 99999)
    zdatas = cinfos.compact_map do |cinfo|
      next if cinfo.cksum.empty? && cinfo.ch_no.in?(ignore)
      cbody = load_raw_from_cksum!(cinfo) rescue ""
      Czdata.from_info(cinfo, cbody, uname)
    end

    self.text_db.open_tx { |db| zdatas.each(&.upsert!(db: db)) }
    zdatas.size
  end

  def load_full_raw!(cinfo : Chinfo)
    self.get_zdata(cinfo.ch_no).try(&.parts) || self.load_raw_from_cksum!(cinfo) rescue ""
  end

  def load_raw_from_cksum!(cinfo : Chinfo)
    return "" if cinfo.cksum.empty?

    String.build do |io|
      1.upto(cinfo.psize) do |p_idx|
        rpath = "#{self.part_name(cinfo, p_idx)}.raw.txt"
        lines = File.read_lines(rpath, chomp: true)
        lines.shift if p_idx > 1
        lines.each { |line| io << line << '\n' }
      end
    end
  end

  ###

  @[AlwaysInline]
  def part_name(cinfo : Chinfo, p_idx : Int32)
    "#{@sroot}/#{cinfo.ch_no}-#{cinfo.cksum}-#{p_idx}"
  end

  def get_fpath(cinfo : Chinfo, p_idx : Int32)
    if !cinfo.cksum.empty?
      fpath = self.part_name(cinfo, p_idx)
      return fpath if File.file?("#{TXT_DIR}/#{fpath}.raw.txt")
    end

    return "" unless zdata = self.get_zdata(cinfo.ch_no)

    cinfo.cksum = ChapUtil.cksum_to_s(zdata.cksum)
    spawn cinfo.upsert!(db: self.info_db)
    self.save_raw_text(cinfo, zdata)

    return self.part_name(cinfo, p_idx)
  end

  private def save_raw_text(cinfo : Chinfo, zdata : Czdata)
    Dir.mkdir_p("#{TXT_DIR}/#{@sroot}")

    zdata.parts.split("\n\n").each_with_index do |ptext, index|
      rpath = "#{TXT_DIR}/#{self.part_name(cinfo, index)}.raw.txt"
      File.open(rpath, "w") do |file|
        file << zdata.title << '\n' if index > 0
        file << ptext
      end
    end
  end

  ####

  ###

  def prev_part(ch_no : Int32, p_idx : Int32)
    return "#{ch_no}_#{p_idx &- 1}" if p_idx > 1

    return "" unless ch_no > 1
    return "" unless pchap = Chinfo.find_prev(self.info_db, ch_no)

    psize = pchap.psize
    psize > 1 ? "#{pchap.ch_no}_#{psize}" : pchap.ch_no.to_s
  end

  def next_part(ch_no : Int32, p_idx : Int32, psize : Int32)
    return "#{ch_no}_#{p_idx &+ 1}" if p_idx < psize
    Chinfo.find_next(self.info_db, ch_no).try(&.ch_no).to_s
  end

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

  def save_raw_from_link!(cinfo : Chinfo, uname : String, force : Bool = false)
    return unless force || cinfo.cksum.empty?

    rlink = cinfo.rlink

    if rlink.empty?
      return # TODO: regenerate from spath
    else
      stale = Time.utc - (force ? 2.minutes : 20.years)
      raw_chap = RawRmchap.from_link(rlink, stale: stale)
    end

    cinfo.uname = uname
    title, paras = raw_chap.parse_page!

    self.do_save_raw!(cinfo, paras: paras, title: title)
  rescue
    nil
  end

  def save_czdata!(zdata : Czdata) : Nil
    spawn zdata.upsert!(db: self.text_db)

    cinfo = self.load(zdata.ch_no)
    cinfo.inherit(zdata)

    spawn do
      bak_path = "var/texts/#{@sroot}/#{cinfo.ch_no}-#{cinfo.cksum}.raw.json"
      File.write(bak_path, zdata.to_pretty_json)
    end

    cinfo.upsert!(db: self.info_db)
  end

  def save_raw_from_text!(cinfo : Chinfo, ztext : String, uname : String = "")
    lines = ChapUtil.split_lines(ztext)
    cinfo.ztitle = lines.first if cinfo.ztitle.empty?

    self.do_save_raw!(cinfo, lines)
  end

  private def do_save_raw!(cinfo : Chinfo, paras : Array(String), title : String = paras.shift)
    parts, sizes, cksum = ChapUtil.split_parts(paras: paras, title: title)

    cinfo.cksum = ChapUtil.cksum_to_s(cksum)
    cinfo.sizes = sizes.join(' ')

    parts.each_with_index do |ptext, p_idx|
      cdata = Chpart.new(part_name(cinfo, p_idx))
      cdata.save_raw!(ptext, p_idx > 0 ? title : nil)
    end

    cinfo.mtime = Time.utc.to_unix
    cinfo.upsert!(db: self.info_db)
  end

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
