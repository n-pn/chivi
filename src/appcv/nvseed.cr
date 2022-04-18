require "../_util/site_link"
require "../_init/remote_info"
require "../cvmtl/mt_core"

require "./nvchap/ch_list"
require "./shared/sname_map"

class CV::Nvseed
  include Clear::Model

  self.table = "nvseeds"
  primary_key

  column uid : Int64 = 0_i64 # alternative unique index

  belongs_to nvinfo : Nvinfo
  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  column zseed : Int32 # seed name
  column sname : String = ""
  column snvid : String # seed book id

  # seed data

  column btitle : String = ""
  column author : String = ""

  column bcover : String = ""
  column bintro : String = ""
  column bgenre : String = ""

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  ##########

  column utime : Int64 = 0 # seed page update time as total seconds since the epoch
  column stime : Int64 = 0 # last crawled at

  column chap_count : Int32 = 0   # total chapters
  column last_schid : String = "" # seed's latest chap id

  timestamps

  getter cvmtl : MtCore { MtCore.generic_mtl(nvinfo.dname) }

  getter _repo : ChRepo { ChRepo.new(sname, snvid) }
  delegate chlist, to: _repo

  # update book id
  def fix_uid!
    self.uid = SnameMap.map_uid(nvinfo_id, zseed)
  end

  def clink(schid : String) : String
    SiteLink.text_url(sname, snvid, schid)
  end

  PSIZE = 32

  @cached = Hash(Int32, Array(ChInfo)).new

  def reset_cache!
    @cached.clear
    @lastpg = nil
  end

  def chpage(pgidx : Int32)
    @cached[pgidx] ||= begin
      chmin = pgidx * PSIZE + 1
      chmax = chmin + PSIZE - 1
      chmax = chap_count if chmax > chap_count

      chlist = _repo.chlist(pgidx // 4)
      (chmin..chmax).map { |chidx| chlist.get(chidx).trans!(cvmtl) }
    end
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

  def chinfo(index : Int32) # provide real chap index
    chpage(index // PSIZE)[index % PSIZE]?
  end

  def get_chvol(chidx : Int32, limit = 4)
    chmin = chidx - limit
    chmin = 1 if chmin > 1

    chidx.downto(chmin).each do |index|
      next unless info = self.chinfo(index - 1)
      return info.chvol unless info.chvol.empty?
    end

    ""
  end

  def chap_url(chidx : Int32, cpart = 0)
    return unless chinfo = self.chinfo(chidx - 1)
    chinfo.chap_url(cpart)
  end

  def chtext(chinfo : ChInfo, cpart = 0, mode = 0, uname = "")
    return [] of String if chinfo.invalid?

    chtext = ChText.new(sname, snvid, chinfo)
    chdata = chtext.load!(cpart)

    if mode > 1 || (mode == 1 && chdata.lines.empty?)
      # reset mode or text do not exist
      chdata = chtext.fetch!(cpart, ttl: mode > 1 ? 1.minutes : 10.years)
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

  def update_latest(chap : ChInfo, force : Bool = true)
    return unless force || self.chap_count <= chap.chidx
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

  def remote?(force : Bool = true)
    type = SnameMap.map_type(sname)
    type == 4 || (force && type == 3)
  end

  def fetch!(ttl : Time::Span, force : Bool = false, @lbl = "-/-") : Nil
    parser = RemoteInfo.new(sname, snvid, ttl: ttl)
    changed = parser.last_schid != self.last_schid

    return unless force || changed
    chinfos = parser.chap_infos

    _repo.store!(chinfos, reset: force)
    reset_cache!

    self.update_status(parser.status_int)
    self.update_latest(chinfos.last, force: true)

    self.stime = Time.utc.to_unix

    if parser.update_str.empty?
      mftime = changed ? self.stime : self.utime
    else
      mftime = parser.update_int
    end

    self.update_mftime(mftime)

    self.save!
  rescue err
    puts err.inspect_with_backtrace
  end

  def patch!(chap : ChInfo, utime : Int64 = Time.utc.to_unix) : Nil
    patch!([chap], utime)
  end

  def patch!(chaps : Array(ChInfo), utime : Int64 = Time.utc.to_unix) : Nil
    return if chaps.empty?
    _repo.patch!(chaps)

    self.update_latest(chaps.last, force: false)
    self.update_mftime(utime)

    self.save!
  end

  def proxy!(other : self, start = self.chap_count + 1) : Int32
    return start if other.chap_count < start
    infos = other._repo.fetch_as_proxies!(start, other.chap_count)

    if other.sname == "users"
      infos.select! { |chap| chap.stats.chars > 0 }
    end

    return start if infos.empty?
    self.patch!(infos, other.utime)
    infos.last.chidx + 1 # return latest patched chapter
  end

  def proxy_many!(others : Array(self), force : Bool = false) : Nil
    self.chap_count = 0 if force
    start = self.chap_count + 1

    others.each do |other|
      start = 1 if force && other.sname == "users"
      start = self.proxy!(other, start: start)
    end

    self.reset_cache!
  end

  def remap!(force : Bool = false, fetch : Bool = true)
    seeds = self.nvinfo.nvseeds.to_a.sort_by!(&.zseed)
    seeds.shift if seeds.first?.try(&.id.== self.id)

    ttl = map_ttl(force: force)

    seeds.each_with_index(1) do |nvseed, idx|
      next unless fetch && nvseed.remote?(force: false)
      nvseed.fetch!(ttl: ttl * (2 ** idx), force: false, lbl: "#{idx}/#{seeds.size}")
    rescue err
      puts err.colorize.red
    end

    proxy_many!(seeds, force: force)
  end

  # ------------------------

  def staled?(privi : Int32 = 4, force : Bool = false)
    return true if self.chap_count == 0
    tspan = Time.utc - Time.unix(self.stime)
    tspan >= map_ttl(force: force) * (4 - privi)
  end

  def map_ttl(force : Bool = false)
    case self.nvinfo.status
    when 0 then force ? 5.minutes : 60.minutes
    when 1 then force ? 5.hours : 60.hours
    when 2 then force ? 1.days : 12.days
    else        force ? 5.hours : 60.days
    end
  end

  def refresh!(force : Bool = false) : Nil
    if zseed == 0 # sname == "chivi"
      self.remap!(force: force, fetch: true)
      self.update({stime: Time.utc.to_unix})
    elsif self.remote?(force: force)
      self.fetch!(ttl: map_ttl(force: force), force: force)
      Nvseed.load!(self.nvinfo, 0).tap(&.proxy!(self)).reset_cache!
    else
      reset_cache! if force
    end
  end

  ###########################

  CACHE = RamCache(Int64, self).new(1024)

  def self.load!(nvinfo_id : Int64, zseed : Int32) : self
    load!(Nvinfo.load!(nvinfo_id), zseed)
  end

  def self.load!(nvinfo : Nvinfo, sname : String) : self
    load!(nvinfo, SnameMap.map_str(sname))
  end

  def self.load!(nvinfo : Nvinfo, zseed : Int32) : self
    CACHE.get(SnameMap.map_uid(nvinfo.id, zseed)) do
      find(nvinfo.id, zseed) || init!(nvinfo, zseed)
    end
  end

  def self.init!(nvinfo : Nvinfo, zseed : Int32, fetch : Bool = false)
    case zseed
    when  0 then init!(nvinfo, "chivi").tap(&.remap!(fetch: fetch))
    when 63 then init!(nvinfo, "users") # TODO: check folder and recover
    else         raise "Source #{zseed} not found!"
    end
  end

  def self.init!(nvinfo : Nvinfo, sname : String, snvid = nvinfo.bhash)
    zseed = SnameMap.map_int(sname)
    model = new({nvinfo: nvinfo, zseed: zseed, sname: sname, snvid: snvid})
    model.uid = SnameMap.map_uid(nvinfo.id, zseed)
    model.tap(&.save!)
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String)
    find(nvinfo.id, sname) || init!(nvinfo, sname, snvid)
  end

  def self.find(nvinfo_id : Int64, sname : String)
    zseed = SnameMap.map_int(sname)
    find({uid: SnameMap.map_uid(nvinfo_id, zseed)})
  end

  def self.find(nvinfo_id : Int64, zseed : Int32)
    find({uid: SnameMap.map_uid(nvinfo_id, zseed)})
  end
end
