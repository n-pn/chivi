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

  def clink(schid : String) : String
    SiteLink.chtxt_url(sname, snvid, schid)
  end

  getter nvinfo : Nvinfo { Nvinfo.load!(self.nvinfo_id) }

  def unmatch?(nvinfo_id : Int64) : Bool
    nvinfo_id_column.value(0) != nvinfo_id
  end

  def outdated?(privi = 0)
    utime = Time.unix(atime)

    case self.status
    when 0 then Time.utc - 2.**(4 - privi).hours > utime
    when 1 then Time.utc - 2.*(4 - privi).months > utime
    else        false
    end
  end

  def refresh!(privi = 4, mode = 0, ttl = 5.minutes) : Tuple(Int64, Int32)
    vip_user = privi > 1

    unless mode > 0 && NvSeed.remote?(sname, privi, old_enough?)
      purge_cache! if vip_user
      return {utime, chap_count}
    end

    parser = RmInfo.init(sname, snvid, ttl: ttl, mkdir: true)
    changed = parser.last_schid != self.last_schid
    if mode > 1 || changed
      self.atime = Time.utc.to_unix
      self.update_status(parser.istate)

      if changed
        self.chap_count = parser.chap_infos.size
        self.last_schid = parser.last_schid

        self.utime = parser.mftime > 0 ? parser.mftime : self.atime
        nvinfo.update_utime(self.utime)
      end

      if changed || vip_user
        CACHE.delete(page_uuid(-1))
        pgmax, pgmin = ChList.save!(sname, snvid, parser.chap_infos, redo: vip_user)
        purge_cache!(pgmin * 4, pgmax * 4 - 1)
      end

      self.save!
    else
      purge_cache! if vip_user
    end

    {utime, chap_count}
  rescue err
    Log.error { err.inspect_with_backtrace }
    {self.utime, self.chap_count}
  end

  def update_status(status : Int32)
    return if self.status >= status && self.status != 3
    nvinfo.set_status(status)
    self.status = status
  end

  def remote?(privi = 4)
    NvSeed.remote?(sname, privi, old_enough?)
  end

  def old_enough?
    return false if Time.unix(self.atime) >= Time.utc - 30.minutes
    Time.unix(self.utime) < Time.utc - (status < 1 ? 2.days : 4.weeks)
  end

  private def chlist(pgidx : Int32)
    ChList.load!(sname, snvid, pgidx)
  end

  P_SIZE  = 32
  P_CACHE = RamCache(String, Array(ChInfo)).new(4096, 12.hours)

  def chpage(pgidx : Int32)
    P_CACHE.get(page_uuid(pgidx)) do
      chlist = self.chlist(pgidx // 4)

      chmin = pgidx * P_SIZE + 1
      chmax = chmin + P_SIZE - 1
      chmax = self.chap_count if chmax > self.chap_count

      (chmin..chmax).map do |chidx|
        chlist.get(chidx).tap(&.trans!(cvmtl))
      end
    end
  end

  def lastpg
    P_CACHE.get(page_uuid(-1)) do
      chmax = chap_count

      chmin = chmax - 3
      chmin = 1 if chmin < 1

      output = [] of ChInfo
      chmax.downto(chmin) do |chidx|
        output << (self.chinfo(chidx - 1) || ChInfo.new(chidx))
      end

      output
    end
  end

  def purge_cache!(pgmin = 0, pgmax = chap_count // 4 + 1)
    pgmin.upto(pgmax) { |pgidx| P_CACHE.delete(page_uuid(pgidx)) }
  end

  private def page_uuid(pgidx : Int32) : String
    "#{sname}-#{snvid}-#{pgidx}"
  end

  def chinfo(index : Int32) # provide real chap index
    chpage(index // P_SIZE)[index % P_SIZE]?
  end

  def public_chap?(chidx : Int32)
    chidx <= 40 || chidx >= self.chap_count - 5
  end

  def update_stats!(chinfo : ChInfo, z_title : String? = nil) : Nil
    if z_title
      chinfo.z_title = z_title
      chinfo.trans!(cvmtl)
    end

    chlist = self.chlist(ChList.pgidx(chinfo.chidx))
    chlist.put!(chinfo)

    index = chinfo.chidx - 1
    P_CACHE.delete page_uuid(index // P_SIZE)
    P_CACHE.delete page_uuid(-1) if chap_count < index + 4
  end

  # def get_schid(index : Int32)
  #   chinfo.get_info(index).try(&.first?) || (index + 1).to_s
  # end

  # def set_chap!(index : Int32, schid : String, title : String, label : String)
  #   chinfo.put_chap!(index, schid, title, label)
  # end

  def chtext(index : Int32, schid : String? = get_schid(index))
    ChText.load(nvinfo.bhash, sname, snvid, index, schid)
  end

  def chtext(index : Int32, cpart : Int32 = 0, privi : Int32 = 4, reset : Bool = false)
    unless (chinfo = self.chinfo(index)) && !chinfo.invalid?
      return [] of String
    end

    chtext = Chtext.load(sname, snvid, chinfo)
    lines, utime = chtext.load!(cpart)

    if remote_text?(index, privi) && (reset || lines.empty?)
      lines, _ = chtext.fetch!(cpart, stale: reset ? 3.minutes : 30.years)
      update_stats!(chtext.infos)
    elsif chinfo.utime < utime || chinfo.parts == 0
      # check if text existed in zip file but not stored in index
      update_stats!(chtext.infos, chtext.remap!)
    end

    lines
  rescue
    [] of String
  end

  def remote_text?(chidx : Int32, privi : Int32 = 4)
    NvSeed.remote?(sname, privi, public_chap?(chidx))
  end

  def chap_url(chidx : Int32, cpart = 0)
    return unless chinfo = self.chinfo(chidx - 1)
    chinfo.chap_url(cpart)
  end

  ###########################

  def self.upsert!(zseed : Int32, snvid : String)
    find({zseed: zseed, snvid: snvid}) || new({zseed: zseed, snvid: snvid})
  end

  def self.upsert!(sname : String, snvid : String)
    upsert!(NvSeed.map_id(sname), snvid)
  end

  CACHE = {} of Int64 => self

  def self.find(nvinfo_id : Int64, zseed : Int32)
    find({nvinfo_id: nvinfo_id, zseed: zseed})
  end

  def self.load!(nvinfo_id : Int64, zseed : Int32) : self
    load!(Nvinfo.load!(nvinfo_id), zseed)
  end

  def self.load!(nvinfo : Nvinfo, zseed : Int32) : self
    CACHE[nvinfo.id << 6 | zseed] ||= find(nvinfo.id, zseed) || begin
      zseed == 0 ? dummy_local(nvinfo) : raise "Zhbook not found!"
    end
  end

  def self.dummy_local(nvinfo : Nvinfo)
    new({
      nvinfo_id: nvinfo.id,

      zseed: 0,
      sname: "chivi",
      snvid: nvinfo.bhash,

      # status: nvinfo.status,
      # shield: nvinfo.shield,

      utime: nvinfo.utime,
      # bumped: nvinfo.bumped,

      chap_count: 0,
      last_schid: "",
    })
  end
end
