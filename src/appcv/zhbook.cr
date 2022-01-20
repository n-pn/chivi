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

  getter wlink : String { SiteLink.binfo_url(sname, snvid) }
  getter cvmtl : MtCore { MtCore.generic_mtl(nvinfo.bhash) }
  getter _type : Int32 do
    case sname
    when "chivi"          then 0
    when "users", "local" then 1
    else
      NvSeed::REMOTES.includes?(sname) ? 3 : 2
    end
  end

  # def unmatch?(nvinfo_id : Int64) : Bool
  #   nvinfo_id_column.value(0) != nvinfo_id
  # end

  def clink(schid : String) : String
    SiteLink.chtxt_url(sname, snvid, schid)
  end

  def staled?(ttl = 12.hours)
    Time.unix(self.atime) < Time.utc - ttl
  end

  def fix_id!
    id = nvinfo.id << 6 | zseed
  end

  # mode:
  # 0 : just return utime and chap_count
  # 1 : reset cached translation
  # 2 : update remote source
  # 3 : make a full remote update

  def count_chap!(mode = 0, ttl = 5.minutes) : Int32
    if mode > 1
      parser = RmInfo.init(sname, snvid, ttl: ttl, mkdir: true)
      changed = parser.last_schid != self.last_schid

      if changed || mode > 2
        self.atime = Time.utc.to_unix
        self.update_status(parser.istate)

        infos = parser.chap_infos
        pgmax = (infos.size - 1) // CV_PSIZE + 1

        if mode > 2
          ChList.save!(sname, snvid, infos)
          pgmin = 0
        else
          chmin = self.chap_count - 1
          pgmin = chmin // CV_PSIZE
          ChList.save!(sname, snvid, infos[chmin..])
        end

        if changed
          self.chap_count = infos.size
          self.last_schid = infos.last.schid

          self.utime = parser.mftime > 0 ? parser.mftime : self.atime
          nvinfo.update_utime(self.utime)
        end

        lastpg = nil
        purge_cache!(pgmin, pgmax)
      end

      self.save!
    elsif mode > 0
      purge_cache!
    end

    self.chap_count
  end

  def update_status(status : Int32)
    return if self.status >= status && self.status != 3
    nvinfo.set_status(status)
    self.status = status
  end

  CV_PSIZE = 32
  CV_CACHE = RamCache(String, Array(ChInfo)).new(4096, 12.hours)

  def chpage(pgidx : Int32)
    CV_CACHE.get(page_uuid(pgidx)) do
      chlist = ChList.load!(sname, snvid, pgidx // 4)

      chmin = pgidx * CV_PSIZE + 1
      chmax = chmin + CV_PSIZE - 1
      chmax = self.chap_count if chmax > self.chap_count

      (chmin..chmax).map { |chidx| chlist.get(chidx).tap(&.trans!(cvmtl)) }
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

  def purge_cache!(pgmin : Int32 = 0, pgmax : Int32 = chap_count % CV_PSIZE + 1)
    pgmin.upto(pgmax) { |pgidx| CV_CACHE.delete(page_uuid(pgidx)) }
  end

  private def page_uuid(pgidx : Int32)
    "#{sname}-#{snvid}-#{pgidx}"
  end

  def chinfo(index : Int32) # provide real chap index
    chpage(index // CV_PSIZE)[index % CV_PSIZE]?
  end

  # def set_chap!(index : Int32, schid : String, title : String, label : String)
  #   chinfo.put_chap!(index, schid, title, label)
  # end

  def chtext(chinfo : ChInfo, cpart = 0, mode = 0, uname = "")
    return [] of String if chinfo.invalid?

    chtext = Chtext.load(sname, snvid, chinfo)
    chdata = chtext.load!(cpart)

    if mode > 1 || (mode == 1 && chdata.lines.empty?)
      chdata = chtext.fetch!(cpart, ttl: mode > 1 ? 3.minutes : 10.years)
      chinfo.uname = uname unless uname.empty?
      upsert_chinfo!(chinfo)
    elsif chinfo.utime < chdata.utime || chinfo.parts == 0
      # check if text existed in zip file but not stored in index
      upsert_chinfo!(chinfo, chtext.remap!)
    end

    chdata.lines
  rescue
    [] of String
  end

  def chap_url(chidx : Int32, cpart = 0)
    return unless chinfo = self.chinfo(chidx - 1)
    chinfo.chap_url(cpart)
  end

  def copy_newers!(others : Array(self))
    others.each do |other|
      next unless other.chap_count > self.chap_count

      infos = ChList.fetch(other.sname, other.snvid, self.chap_count + 1, other.chap_count)
      ChList.save!(self.sname, self.snvid, infos)

      self.chap_count = other.chap_count
      self.utime = other.utime if self.utime < other.utime
    end

    self.purge_cache!
    @lastpg = nil

    self.atime = Time.utc.to_unix
    self.save!
  end

  def chlist(pgidx : Int32)
    ChList.load!(sname, snvid, pgidx)
  end

  def upsert_chinfo!(chinfo : ChInfo, z_title : String? = nil, z_chvol : String? = nil) : Nil
    if z_title
      chinfo.z_title = z_title
      chinfo.z_chvol = z_chvol if z_chvol
    end

    chinfo.trans!(cvmtl)
    index = chinfo.chidx - 1

    chlist = self.chlist(index // ChList::PSIZE)
    chlist.update!(chinfo)

    CV_CACHE.delete page_uuid(index // CV_PSIZE)
    @lastpg = nil if chap_count < index + 4
  end

  def upsert_chinfos!(infos : Array(ChInfo), utime = Time.utc.to_unix)
    return if infos.empty?

    ChList.save!(self.sname, self.snvid, infos)
    self.utime = utime

    pgmin = (infos.first.chidx - 1) // CV_PSIZE
    pgmax = (infos.last.chidx - 1) // CV_PSIZE

    self.purge_cache!(pgmin, pgmax)
    @lastpg = nil

    return unless self.chap_count < infos.last.chidx

    self.chap_count = infos.last.chidx
    self.last_schid = infos.last.schid
    self.save!
  end

  ###########################

  def self.upsert!(nvinfo : Nvinfo, sname : String, snvid : String)
    zseed = NvSeed.map_id(sname)

    find({nvinfo_id: nvinfo.id, zseed: zseed}) || begin
      new({nvinfo: nvinfo, zseed: zseed, sname: sname, snvid: snvid}).tap(&.fix_id!)
    end
  end

  CACHE = {} of Int64 => self

  def self.find(nvinfo_id : Int64, zseed : Int32)
    find({nvinfo_id: nvinfo_id, zseed: zseed})
  end

  def self.load!(nvinfo_id : Int64, zseed : Int32) : self
    load!(Nvinfo.load!(nvinfo_id), zseed)
  end

  def self.load!(nvinfo : Nvinfo, sname : String) : self
    load!(nvinfo, NvSeed.map_id(sname))
  end

  def self.load!(nvinfo : Nvinfo, zseed : Int32) : self
    CACHE[nvinfo.id << 6 | zseed] ||= find(nvinfo.id, zseed) || begin
      case zseed
      when 63 then dummy_users_entry(nvinfo)
      when  0 then make_local_clone!(nvinfo)
      else         raise "Zhbook not found!"
      end
    end
  end

  def self.dummy_users_entry(nvinfo : Nvinfo)
    zseed = NvSeed.map_id("users")
    zhbook = new({nvinfo: nvinfo, zseed: zseed, sname: "users", snvid: nvinfo.bhash})
    zhbook.tap(&.fix_id!)
  end

  def self.make_local_clone!(nvinfo : Nvinfo)
    zhbook = new({nvinfo: nvinfo, zseed: 0, sname: "chivi", snvid: nvinfo.bhash})
    zhbook.fix_id!
    zhbook.copy_newers!(nvinfo.zhbooks.to_a)
  end
end
