require "../_util/site_link"
require "../_util/file_util"
require "../_init/remote_info"

require "./nvchap/ch_list"
require "./shared/sname_map"

require "./inners/nvseed_inner"

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
  getter _repo : ChRepo { ChRepo.new(sname, snvid, nvinfo.dname) }
  delegate chlist, to: _repo

  include NvseedInner

  # update book id
  def fix_uid!
    self.uid = SnameMap.map_uid(nvinfo_id, zseed)
  end

  def clink(schid : String) : String
    SiteLink.text_url(sname, snvid, schid)
  end

  VI_PSIZE = 32

  @vpages = Hash(Int32, Array(ChInfo)).new

  def reset_cache!
    @vpages.clear
    @lastpg = nil
  end

  def chpage(vi_pg : Int32)
    @vpages[vi_pg] ||= begin
      chmin = vi_pg * VI_PSIZE + 1
      chmax = chmin + VI_PSIZE - 1
      chmax = chap_count if chmax > chap_count

      chlist = _repo.chlist(vi_pg // 4)
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

  def chinfo(index : Int32) : ChInfo?
    self.chpage(index // VI_PSIZE)[index % VI_PSIZE]?
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

  def fetch!(ttl : Time::Span, force : Bool = false, lbl = "-/-") : Nil
    parser = RemoteInfo.new(sname, snvid, ttl: ttl, lbl: lbl)
    changed = parser.last_schid != self.last_schid

    return unless force || changed
    chinfos = parser.chap_infos
    return if chinfos.empty?

    spawn { ChList.save!(_repo.fseed, chinfos, mode: "w") }
    _repo.store!(chinfos, reset: force)

    self.reset_cache!
    self.stime = FileUtil.mtime_int(parser.info_link)

    if parser.update_str.empty?
      mftime = changed ? self.stime : self.utime
    else
      mftime = parser.update_int
    end

    self.set_mftime(mftime)
    self.set_status(parser.status_int)
    self.set_latest(chinfos.last, force: true)

    self.save!
  rescue err
    puts err.inspect_with_backtrace
  end

  def patch!(chap : ChInfo, utime : Int64 = Time.utc.to_unix) : Nil
    patch!([chap], utime)
  end

  def patch!(chaps : Array(ChInfo), utime : Int64, save = true) : Nil
    return if chaps.empty?
    _repo.patch!(chaps)

    self.set_mftime(utime, force: false)
    self.set_latest(chaps.last, force: false)

    self.save! if save
  end

  def proxy!(other : self, start = 1) : Int32
    return start if other.chap_count < start

    infos = other._repo.fetch_as_proxies!(start, other.chap_count)
    infos.select!(&.stats.chars.> 0) if other.sname == "users"

    return start if infos.empty?
    self.patch!(infos, other.utime, save: false)
    infos.last.chidx + 1 # return latest patched chapter
  end

  def remap!(force : Bool = false, fetch : Bool = true) : Nil
    seeds = self.nvinfo.nvseeds.to_a.sort_by!(&.zseed)

    seeds.shift if seeds.first?.try(&.zseed.== 0)
    users_seed = seeds.pop if seeds.last?.try(&.sname.== "users")

    ttl = map_ttl(force: force)
    start = 1

    seeds = seeds.first(5)
    seeds.each_with_index(1) do |other, idx|
      if fetch && other.remote?(force: force)
        ttl *= 2
        other.fetch!(ttl: ttl, force: false, lbl: "#{idx}/#{seeds.size}")
        self.stime = other.stime if self.stime < other.stime
      end

      start = self.proxy!(other, start: start)
    rescue err
      Log.error { err.colorize.red }
    end

    users_seed.try { |x| self.proxy!(x, start: 1) }

    self.reset_cache!
    self.save!
  end

  # ------------------------

  def refresh!(force : Bool = false) : Nil
    if zseed == 0 # sname == "chivi"
      if force
        self.chap_count = 0
        self.last_schid = ""
        self.utime = 0_i64
        self.stime = Time.utc.to_unix
      end

      self.remap!(force: force, fetch: true)
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
