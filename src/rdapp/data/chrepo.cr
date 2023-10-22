require "./chinfo"
require "./czdata"
require "./unlock"
require "../_raw/raw_rmchap"

class RD::Chrepo
  CACHE = {} of String => self

  def self.load(sroot : String)
    CACHE[sroot] ||= new(sroot)
  end

  getter sroot : String

  property owner : Int32 = -1

  property chmax : Int32 = 9999
  property wn_id : Int32 = 0

  property gifts : Int16 = 1
  property multp : Int16 = 4

  def initialize(@sroot)
    @info_db = Chinfo.db(sroot)
    @text_db = Czdata.db(sroot)

    @bak_dir = "var/users/upload/#{sroot}"
    Dir.mkdir_p(@bak_dir)

    @txt_dir = "var/texts/#{sroot}"
    Dir.mkdir_p(@txt_dir)
  end

  def chmax=(@chmax : Int32)
    @free_until = nil
  end

  getter free_until : Int32 do
    return @chmax if @gifts == 0
    auto_free = @chmax &* @gifts // 4
    auto_free > 120 ? auto_free : 120
  end

  @[AlwaysInline]
  def free_chap?(ch_no : Int32)
    ch_no < self.free_until
  end

  @[AlwaysInline]
  def get_all(start : Int32 = 1, limit : Int32 = 32)
    Chinfo.get_all(@info_db, start: start, limit: limit, chmax: @chmax)
  end

  @[AlwaysInline]
  def get_top(start : Int32 = @chmax, limit : Int32 = 4)
    Chinfo.get_top(@info_db, start: start, limit: limit)
  end

  @[AlwaysInline]
  def find(ch_no : Int32)
    Chinfo.find(@info_db, ch_no)
  end

  @[AlwaysInline]
  def get_chdiv(ch_no : Int32)
    Chinfo.get_chdiv(@info_db, ch_no)
  end

  def load(ch_no : Int32)
    find(ch_no) || Chinfo.new(ch_no)
  end

  def chap_mutlp(ch_no : Int32, vu_id : Int32, privi : Int32)
    return {0_i16, 0_i16} if vu_id == @owner || free_chap?(ch_no)
    {@multp > privi ? @multp &- privi : 0_i16, @multp}
  end

  ####

  @[AlwaysInline]
  def part_name(cinfo : Chinfo, p_idx : Int32)
    "#{@sroot}/#{cinfo.ch_no}-#{cinfo.cksum}-#{p_idx}"
  end

  ###

  def prev_part(ch_no : Int32, p_idx : Int32)
    return "#{ch_no}_#{p_idx &- 1}" if p_idx > 1

    return "" unless ch_no > 1
    return "" unless pchap = Chinfo.find_prev(@info_db, ch_no)

    psize = pchap.psize
    psize > 1 ? "#{pchap.ch_no}_#{psize}" : pchap.ch_no.to_s
  end

  def next_part(ch_no : Int32, p_idx : Int32, psize : Int32)
    return "#{ch_no}_#{p_idx &+ 1}" if p_idx < psize
    Chinfo.find_next(@info_db, ch_no).try(&.ch_no).to_s
  end

  ###

  @[AlwaysInline]
  def last_ch_no
    Chinfo.find_last(@info_db).try(&.ch_no) || 0
  end

  @[AlwaysInline]
  def word_count(chmin : Int32, chmax : Int32) : Int32
    Chinfo.word_count(@info_db, chmin, chmax)
  end

  @[AlwaysInline]
  def upsert_zinfos!(clist : Array(Chinfo))
    # latest = clist.last.ch_no
    # @chmax = latest if @chmax < latest
    Chinfo.upsert_zinfos!(@info_db, clist)
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

  def save_czdata!(zdata : Czdata)
    cksum = ChapUtil.cksum_to_s(zdata.cksum)

    spawn File.write("#{@bak_dir}/#{zdata.ch_no}-#{cksum}.json", zdata.to_pretty_json)
    spawn zdata.upsert!(db: @text_db)

    cinfo = self.load(zdata.ch_no)
    cinfo.ztitle = zdata.title
    cinfo.zchdiv = zdata.chdiv

    cinfo.uname = zdata.uname
    cinfo.mtime = zdata.mtime
    cinfo.spath = zdata.zorig

    cinfo.cksum = cksum
    cinfo.sizes = zdata.sizes

    zdata.parts.split("\n\n").each_with_index do |ptext, p_idx|
      cdata = Chpart.new(part_name(cinfo, p_idx))
      cdata.save_raw!(ptext, p_idx > 0 ? zdata.title : nil)
    end

    cinfo.upsert!(db: @info_db)
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
    cinfo.upsert!(db: @info_db)
  end

  def load_raw!(cinfo : Chinfo)
    return "" if cinfo.cksum.empty?

    String.build do |io|
      1.upto(cinfo.psize) do |p_idx|
        lines = Chpart.read_raw("#{@sroot}/#{cinfo.ch_no}-#{cinfo.cksum}-#{p_idx}")
        lines.shift if p_idx > 1
        lines.each { |line| io << line << '\n' }
      end
    end
  end
end
