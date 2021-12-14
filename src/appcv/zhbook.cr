require "../_util/ukey_util"
require "../_util/site_link"
require "../cvmtl/mt_core"
require "../seeds/rm_info"

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

    case status
    when 0 then Time.utc - 2.**(4 - privi).hours > utime
    when 1 then Time.utc - 2.*(4 - privi).months > utime
    else        false
    end
  end

  def refresh!(privi = 4, mode = 0, ttl = 5.minutes) : Tuple(Int64, Int32)
    unless mode > 0 && remote?(privi)
      reset_pages!(chmin: 1) if privi > 1
      return {utime, chap_count}
    end

    FileUtils.mkdir_p(PathUtil.cache_dir(sname, "infos"))

    parser = RmInfo.init(sname, snvid, ttl: ttl)

    if mode > 1 || parser.last_schid != self.last_schid
      if parser.mftime > 0
        self.utime = parser.mftime
      else
        self.utime = Time.utc.to_unix if parser.last_schid != self.last_schid
      end

      old_chap_count = chap_count
      self.chap_count = parser.chap_list.size

      self.last_schid = parser.last_schid
      self.atime = Time.utc.to_unix

      Chlist.save!(sname, snvid, parser.chap_list, redo: privi > 0)
      Chpage.forget!(sname, snvid, -1)
      reset_pages!(chmin: old_chap_count)

      if self.status < parser.istate || self.status == 3
        self.status = parser.istate
        nvinfo.set_status(parser.istate, force: self.status == 3)
      end

      self.save!
      nvinfo.tap(&.set_utime(self.utime)).save! unless sname == "hetushu"
    else
      reset_pages!(chmin: 1) if privi > 1
    end

    {utime, chap_count}
  rescue err
    Log.error { err.inspect_with_backtrace }
    {utime, chap_count}
  end

  def remote?(privi = 4)
    Zhseed.remote?(sname, privi, old_enough?)
  end

  def old_enough?
    return false if Time.unix(self.atime) >= Time.utc - 30.minutes
    Time.unix(self.utime) < Time.utc - (status < 1 ? 2.days : 4.weeks)
  end

  def reset_pages!(chmax = self.chap_count, chmin = chmax - 1)
    pgmin = Chpage.pgidx(chmin - 1)
    pgmax = Chpage.pgidx(chmax - 1)
    (pgmin..pgmax).each { |pgidx| Chpage.forget!(sname, snvid, pgidx) }
  end

  def chlist(group : Int32)
    Chlist.load!(sname, snvid, group)
  end

  def chpage(pgidx : Int32)
    Chpage.load_page!(sname, snvid, pgidx) do
      chlist = self.chlist(pgidx // 4)
      Chpage.init_page!(chlist, cvmtl, pgidx)
    end
  end

  def lastpg
    Chpage.load_last!(sname, snvid, chap_count) do
      chpage = [] of Chpage
      chidx = chap_count

      4.times do
        break if chidx < 0
        chlist = self.chlist((chidx - 1) // 128)

        break unless chinfo = chlist.get(chidx.to_s)
        chpage << Chpage.new(chinfo, chidx).trans!(cvmtl)

        chidx -= 1
      end

      chpage
    end
  end

  def chinfo(index : Int32) # provide real chap index
    chpage(Chpage.pgidx(index))[index % Chpage::PSIZE]?
  end

  def chtext(index : Int32, cpart : Int32 = 0, privi : Int32 = 4, reset : Bool = false)
    return [] of String unless chinfo = self.chinfo(index)

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
    Zhseed.remote?(sname, privi, public_chap?(chidx))
  end

  def public_chap?(chidx : Int32)
    chidx <= 40 || chidx >= self.chap_count - 5
  end

  def update_stats!(chinfo : Chpage, chtitle : String? = nil) : Nil
    chlist = self.chlist(Chlist.pgidx(chinfo.chidx - 1))

    index = chinfo.chidx.to_s
    stats = chlist.get(index).try(&.first(3)) || [chinfo.schid, chtitle, ""]
    stats << chinfo.utime.to_s << chinfo.chars.to_s << chinfo.parts.to_s

    chlist.set!(index, stats)
    return unless chlist.unsaved > 0

    chlist.save!

    Chpage.forget!(sname, snvid, Chpage.pgidx(chinfo.chidx - 1))
    Chpage.forget!(sname, snvid, -1) if chinfo.chidx > chap_count - 4
  end

  def chap_url(chidx : Int32, part = 0)
    return unless chinfo = self.chinfo(chidx - 1)
    chap_url = "#{chinfo.uslug}-#{chidx}"

    case part
    when  0 then chap_url
    when -1 then chinfo.parts > 1 ? "#{chap_url}.#{chinfo.parts - 1}" : chap_url
    else         "#{chap_url}.#{part}"
    end
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

  def get_schid(index : Int32)
    chinfo.get_info(index).try(&.first?) || (index + 1).to_s.rjust(4, '0')
  end

  def set_chap!(index : Int32, schid : String, title : String, label : String)
    chinfo.put_chap!(index, schid, title, label)
  end

  def chtext(index : Int32, schid : String? = get_schid(index))
    ChText.load(nvinfo.bhash, sname, snvid, index, schid)
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
