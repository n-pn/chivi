require "../_util/site_link"
require "../_init/remote_info"
require "../cvmtl/mt_core"

require "./nvchap/ch_list"
require "./nvinfo/sname_map"

class CV::Zhbook
  include Clear::Model

  self.table = "zhbooks"
  primary_key

  column ix : Int64 = 0_i64 # alternative unique index

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

  getter _repo : ChRepo { ChRepo.new(sname, snvid) }
  delegate chlist, to: _repo

  # update book id
  def fix_ix!
    self.ix = Zhbook.map_ix(nvinfo_id, zseed)
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
    type == 3 || (force && type == 4)
  end

  def fetch!(ttl : Time::Span, force : Bool = false) : Nil
    parser = RemoteInfo.new(sname, snvid, ttl: ttl)
    changed = parser.last_schid != self.last_schid

    return unless force || changed
    status, _ = parser.status
    chinfos = parser.chap_infos

    _repo.store!(chinfos, reset: force)
    reset_cache!

    self.update_status(status)
    self.update_latest(chinfos.last, force: true)

    self.atime = Time.utc.to_unix

    mftime, update_str = parser.update
    mftime = self.atime if update_str.empty? && changed
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
    self.atime = Time.utc.to_unix

    self.save!
  end

  def proxy!(other : self, start = self.chap_count + 1) : Int32
    return start if other.chap_count < start
    infos = other._repo.fetch_as_proxies!(start, other.chap_count)

    if other.sname == "users"
      infos.select! do |chap|
        next false if chap.stats.chars == 0
        next true unless prev = _repo.chinfo(chap.chidx)
        prev.stats.utime < chap.stats.utime || prev.o_sname != "staff"
      end

      return start if infos.empty?
    end

    self.patch!(infos, other.utime)
    infos.last.chidx # return latest patched chapter
  end

  def proxy_many!(others : Array(self), force : Bool = false) : Nil
    self.chap_count = 0 if force
    start = self.chap_count + 1

    others.each do |other|
      start = 1 if force && other.sname == "users"
      start = self.proxy!(other, start: start) + 1
    end

    self.reset_cache!
  end

  def remap!(force : Bool = false, fetch : Bool = true)
    seeds = self.nvinfo.zhbooks.to_a.sort_by!(&.zseed)
    seeds.shift if seeds.first?.try(&.id.== self.id)

    seeds.each_with_index do |nvseed, idx|
      next unless fetch && self.remote?(force: false)
      ttl = map_expiry(self.nvinfo.status, force: false)
      nvseed.fetch!(ttl: ttl * (2 ** idx), force: false)
    rescue err
      puts err.colorize.red
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
      self.remap!(force: force, fetch: true)
    elsif self.remote?(force: force)
      self.fetch!(ttl: map_expiry(force: force), force: force)
      Zhbook.load!(self.nvinfo, 0).tap(&.proxy!(self)).reset_cache!
    else
      reset_cache! if force
    end
  end

  ###########################

  CACHE = RamCache(Int64, self).new(1024)

  def self.map_ix(nvinfo_id : Int64, zseed = 0)
    (nvinfo_id << 6) | zseed
  end

  def self.load!(nvinfo_id : Int64, zseed : Int32) : self
    load!(Nvinfo.load!(nvinfo_id), zseed)
  end

  def self.load!(nvinfo : Nvinfo, sname : String) : self
    load!(nvinfo, SnameMap.map_str(sname))
  end

  def self.load!(nvinfo : Nvinfo, zseed : Int32) : self
    CACHE.get(map_ix(nvinfo.id, zseed)) do
      find(nvinfo.id, zseed) || init!(nvinfo, zseed)
    end
  end

  def self.init!(nvinfo : Nvinfo, zseed : Int32)
    case zseed
    when  0 then init!(nvinfo, "chivi").tap(&.remap!(fetch: false))
    when 63 then init!(nvinfo, "users")
    else         raise "Source not found!"
    end
  end

  def self.init!(nvinfo : Nvinfo, sname : String, snvid = nvinfo.bhash)
    zseed = SnameMap.map_int(sname)
    model = new({nvinfo: nvinfo, zseed: zseed, sname: sname, snvid: snvid})
    model.ix = map_ix(nvinfo.id, zseed)
    model.tap(&.save!)
  end

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String)
    find(nvinfo.id, sname) || init!(nvinfo, sname, snvid)
  end

  def self.find(nvinfo_id : Int64, sname : String)
    zseed = SnameMap.map_int(sname)
    find({ix: map_ix(nvinfo_id, zseed)})
  end

  def self.find(nvinfo_id : Int64, zseed : Int32)
    find({ix: map_ix(nvinfo_id, zseed)})
  end
end
