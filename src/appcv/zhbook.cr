require "../_util/ukey_util"
require "../_util/site_link"
require "../cvmtl/mt_core"
require "./nvinfo/nv_seed"
require "./nvchap/ch_list"
require "./remote/rm_info"

class CV::Zhbook
  include Clear::Model

  self.table = "zhbooks"
  primary_key

  belongs_to nvinfo : Nvinfo
  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  column zseed : Int32 # seed name
  column sname : String = ""
  column snvid : String # seed book id

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  column atime : Int64 = 0 # last fetching time as total minutes since the epoch
  column utime : Int64 = 0 # seed page update time as total seconds since the epoch

  column chap_count : Int32 = 0   # total chapters
  column last_schid : String = "" # seed's latest chap id

  timestamps

  getter cvmtl : MtCore { MtCore.generic_mtl(nvinfo.dname) }

  getter _repo : Nvchap { Nvchap.new(sname, snvid) }
  delegate chlist, to: _repo

  # update book id
  def fix_id!
    self.id = nvinfo.id << 6 | zseed
  end

  def clink(schid : String) : String
    SiteLink.chtxt_url(sname, snvid, schid)
  end

  CV_PSIZE = 32
  CV_CACHE = RamCache(String, Array(ChInfo)).new(4096, 12.hours)

  def chpage(pgidx : Int32)
    CV_CACHE.get(page_uid(pgidx)) do
      chlist = _repo.chlist(pgidx // 4)

      chmin = pgidx * CV_PSIZE + 1
      chmax = chmin + CV_PSIZE
      chmax = chap_count + 1 if chmax > chap_count

      (chmin...chmax).map do |chidx|
        next ChInfo.new(chidx) unless chinfo = chlist.data[chidx]?
        chinfo.tap(&.trans!(cvmtl))
      end
    end
  end

  def reset_cache!(pgmin : Int32 = 0, pgmax : Int32 = self.pgmax)
    pgmin.upto(pgmax) { |pgidx| CV_CACHE.delete(page_uid(pgidx)) }
    @lastpg = nil
  end

  def pgmax
    (self.chap_count - 1) % CV_PSIZE + 1
  end

  getter lastpg : Array(ChInfo) do
    chmax = self.chap_count - 1
    chmin = chmax > 3 ? chmax - 3 : 0

    output = [] of ChInfo

    chmax.downto(chmin) do |index|
      output << (self.chinfo(index) || ChInfo.new(index + 1))
    end

    output
  end

  private def page_uid(pgidx : Int32)
    "#{sname}-#{snvid}-#{pgidx}"
  end

  def chinfo(index : Int32) # provide real chap index
    chpage(index // CV_PSIZE)[index % CV_PSIZE]?
  end

  def chap_url(chidx : Int32, cpart = 0)
    return unless chinfo = self.chinfo(chidx - 1)
    chinfo.chap_url(cpart)
  end

  def chtext(chinfo : ChInfo, cpart = 0, mode = 0, uname = "")
    return [] of String if chinfo.invalid?

    chtext = Chtext.load(sname, snvid, chinfo)
    chdata = chtext.load!(cpart)

    if mode > 1 || (mode == 1 && chdata.lines.empty?)
      # reset mode or text do not exist
      chdata = chtext.fetch!(cpart, ttl: mode > 1 ? 3.minutes : 10.years)
      chinfo.stats.uname = uname
      patch!(chinfo)
    elsif chinfo.stats.parts == 0
      # check if text existed in zip file but not stored in index
      chinfo.set_title!(chtext.remap!)
      patch!(chinfo)
    end

    chdata.lines
  rescue
    [] of String
  end

  def update_latest(chap : ChInfo)
    self.last_schid = chap.schid
    self.chap_count = chap.chidx
  end

  def update_mftime(utime : Int64 = Time.utc.to_unix, force : Bool = false)
    return unless force || self.utime < utime
    self.nvinfo.update_utime(utime)
    self.utime = utime
  end

  def update_status(status : Int32)
    return if self.status >= status && self.status != 3
    nvinfo.set_status(status)
    self.status = status
  end

  def remote?
    return false if sname == "5200"
    NvSeed::REMOTES.includes?(sname)
  end

  def locals?
    {"users", "staff"}.includes?(sname)
  end

  def fetch!(ttl : Time::Span, force : Bool = false) : Nil
    parser = RmInfo.init(sname, snvid, ttl: ttl, mkdir: true)
    changed = parser.last_schid != self.last_schid

    return unless force || changed
    status, chinfos = parser.istate, parser.chap_infos

    pgmax, pgmin = _repo.store!(chinfos, reset: force)
    reset_cache!(pgmin * 4, pgmax * 4 + 1)

    self.update_status(status)
    self.update_latest(chinfos.last)
    self.update_mftime(parser.mftime > 0 ? parser.mftime : self.atime)
    self.atime = Time.utc.to_unix

    self.save!
  rescue err
    puts err.inspect_with_backtrace
  end

  def patch!(chap : ChInfo, utime : Int64 = Time.utc.to_unix) : Nil
    patch!([chap], utime)
  end

  def patch!(chaps : Array(ChInfo), utime : Int64 = Time.utc.to_unix)
    return if chaps.empty?

    pgmax, pgmin = _repo.patch!(chaps)
    reset_cache!(pgmin * 4, pgmax * 4 + 1)

    return unless (last = chaps.last?) && last.chidx > self.chap_count

    self.update_latest(last)
    self.update_mftime(utime)

    self.atime = Time.utc.to_unix
    self.save!
  end

  def proxy!(other : self, start = self.chap_count + 1)
    return if other.chap_count < start
    infos = other._repo.fetch!(start, other.chap_count)

    if other.sname == "users"
      infos.select! do |chap|
        next false if chap.stats.chars == 0
        next true unless prev = _repo.chinfo(chap.chidx)
        prev.stats.utime < chap.stats.utime || prev.o_sname != "staff"
      end

      return if infos.empty?
    end

    self.patch!(infos, other.utime)
  end

  def proxy_many!(others : Array(self), force : Bool = false) : Nil
    others.each do |other|
      start = force && other.sname == "users" ? 1 : self.chap_count + 1
      self.proxy!(other, start)
    end
  end

  def remap!(force : Bool = false)
    seeds = self.nvinfo.zhbooks.to_a.sort_by!(&.zseed)
    seeds.shift if seeds.first?.try(&.id.== self.id)

    seeds.first(4).each_with_index do |chseed, idx|
      next unless chseed.remote?
      ttl = map_expiry(self.nvinfo.status, force: force)
      chseed.fetch!(ttl: ttl * (2 ** idx), force: force)
    rescue
      next
    end

    proxy_many!(seeds, force: force)
  end

  # ------------------------

  def staled?(privi : Int32 = 4, force : Bool = false)
    return true if self.chap_count == 0
    tspan = Time.utc - Time.unix(self.atime)
    tspan > map_expiry(self.status, force) * (4 - privi)
  end

  def map_expiry(status = self.status, force : Bool = false)
    case self.status
    when 0 then force ? 3.minutes : 1.hours
    when 1 then force ? 2.hours : 2.days
    when 2 then force ? 3.days : 1.weeks
    else        force ? 4.hours : 4.days
    end
  end

  def refresh!(force : Bool = false) : Nil
    if sname == "chivi"
      self.remap!(force: force)
    elsif self.remote?
      self.fetch!(ttl: map_expiry(force: force), force: force)
      Zhbook.load!(self.nvinfo, 0).proxy!(self)
    else
      reset_cache! if force
    end
  end

  ###########################

  CACHE = {} of Int64 => self

  def self.load!(nvinfo : Nvinfo, zseed : Int32) : self
    CACHE[nvinfo.id << 6 | zseed] ||= find(nvinfo.id, zseed) || begin
      case zseed
      when 0
        seeds = nvinfo.zhbooks.to_a.sort_by!(&.zseed)
        init!(nvinfo, "chivi").tap(&.proxy_many!(seeds, force: true))
      when 63 then init!(nvinfo, "users")
      else         raise "Zhbook not found!"
      end
    end
  end

  def self.load!(nvinfo_id : Int64, zseed : Int32) : self
    load!(Nvinfo.load!(nvinfo_id), zseed)
  end

  def self.load!(nvinfo : Nvinfo, sname : String) : self
    load!(nvinfo, NvSeed.map_id(sname))
  end

  def self.init!(nvinfo : Nvinfo, sname : String, snvid = nvinfo.bhash)
    zseed = NvSeed.map_id(sname)
    model = new({nvinfo: nvinfo, zseed: zseed, sname: sname, snvid: snvid})
    model.tap(&.fix_id!)
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String)
    find({nvinfo_id: nvinfo.id, sname: sname}) || init!(nvinfo, sname, snvid)
  end

  def self.find(nvinfo_id : Int64, sname : String)
    find({nvinfo_id: nvinfo_id, zseed: NvSeed.map_id(sname)})
  end

  def self.find(nvinfo_id : Int64, zseed : Int32)
    find({nvinfo_id: nvinfo_id, zseed: zseed})
  end
end
