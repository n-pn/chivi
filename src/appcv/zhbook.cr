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

  # def unmatch?(nvinfo_id : Int64) : Bool
  #   nvinfo_id_column.value(0) != nvinfo_id
  # end

  def clink(schid : String) : String
    SiteLink.chtxt_url(sname, snvid, schid)
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

        if changed
          self.chap_count = parser.chap_infos.size
          self.last_schid = parser.last_schid

          self.utime = parser.mftime > 0 ? parser.mftime : self.atime
          nvinfo.update_utime(self.utime)
        end

        lastpg = nil
        pgmax, pgmin = ChList.save_many!(sname, snvid, parser.chap_infos, redo: mode > 2)
        purge_cache!(pgmin * 4, pgmax * 4 - 1)
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

  PG_PSIZE = 32
  PG_CACHE = RamCache(String, Array(ChInfo)).new(4096, 12.hours)

  def chpage(pgidx : Int32)
    PG_CACHE.get(page_uuid(pgidx)) do
      chlist = ChList.load!(sname, snvid, pgidx // 4)

      chmin = pgidx * PG_PSIZE + 1
      chmax = chmin + PG_PSIZE - 1
      chmax = self.chap_count if chmax > self.chap_count

      (chmin..chmax).map { |chidx| chlist.get(chidx).tap(&.trans!(cvmtl)) }
    end
  end

  getter lastpg : Array(ChInfo) do
    chmax = self.chap_count - 1
    chmin = chmax > 2 ? chmax - 3 : 0

    output = [] of ChInfo
    chmax.downto(chmin) do |index|
      output << (self.chinfo(index) || ChInfo.new(index + 1))
    end

    output
  end

  def purge_cache!(pgmin : Int32 = 0, pgmax : Int32 = chap_count % PG_PSIZE + 1)
    pgmin.upto(pgmax) { |pgidx| PG_CACHE.delete(page_uuid(pgidx)) }
  end

  private def page_uuid(pgidx : Int32)
    "#{sname}-#{snvid}-#{pgidx}"
  end

  def chinfo(index : Int32) # provide real chap index
    chpage(index // PG_PSIZE)[index % PG_PSIZE]?
  end

  # def get_schid(index : Int32)
  #   chinfo.get_info(index).try(&.first?) || (index + 1).to_s
  # end

  # def set_chap!(index : Int32, schid : String, title : String, label : String)
  #   chinfo.put_chap!(index, schid, title, label)
  # end

  # def chtext(index : Int32, schid : String? = get_schid(index))
  #   ChText.load(nvinfo.bhash, sname, snvid, index, schid)
  # end

  def chtext(chinfo : ChInfo, cpart = 0, mode = 0)
    return [] of String if chinfo.invalid?

    chtext = Chtext.load(sname, snvid, chinfo)
    lines, utime = chtext.load!(cpart)

    if mode > 1 || (mode == 1 && lines.empty?)
      lines, _ = chtext.fetch!(cpart, stale: mode > 1 ? 3.minutes : 30.years)
      update_stats!(chinfo)
    elsif chinfo.utime < utime || chinfo.parts == 0
      # check if text existed in zip file but not stored in index
      update_stats!(chinfo, chtext.remap!)
    end

    lines
  rescue
    [] of String
  end

  def update_stats!(chinfo : ChInfo, z_title : String? = nil) : Nil
    if z_title
      chinfo.z_title = z_title
      chinfo.trans!(cvmtl)
    end

    index = chinfo.chidx - 1

    chlist = ChList.load!(sname, snvid, index % ChList::PSIZE)
    chlist.update!(chinfo)

    PG_CACHE.delete page_uuid(index // PG_PSIZE)
    lastpg = nil if chap_count < index + 4
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
      case zseed
      when 99 then dummy_users_entry(nvinfo)
      when  0 then make_local_clone!(nvinfo)
      else         raise "Zhbook not found!"
      end
    end
  end

  def self.dummy_users_entry(nvinfo : Nvinfo)
    new({nvinfo: nvinfo, zseed: 99, sname: "users", snvid: nvinfo.bhash})
  end

  def self.make_local_clone!(nvinfo : Nvinfo)
    zhbook = new({nvinfo: nvinfo, zseed: 0, sname: "chivi", snvid: nvinfo.bhash})
    return zhbook unless zseed = nvinfo.zseed_ids.sort.first?

    source = load!(nvinfo, zseed)
    ChList.dup_to_local!(source.sname, source.snvid, nvinfo.bhash)

    zhbook.utime = source.utime
    zhbook.chap_count = source.chap_count

    zhbook.tap(&.save!)
  end
end
