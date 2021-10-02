require "../cutil/core_utils"
require "../cutil/site_link"
require "../libcv/mt_core"
require "../seeds/rm_info"

class CV::Zhbook
  include Clear::Model

  self.table = "zhbooks"
  primary_key

  belongs_to cvbook : Cvbook

  column zseed : Int32 # seed name
  getter sname : String { Zhseed.sname(zseed) }

  column snvid : String # seed book id

  column status : Int32 = 0 # same as Cvinfo#status
  column shield : Int32 = 0 # same as Cvinfo#shield

  column bumped : Int64 = 0 # last fetching time as total minutes since the epoch
  column mftime : Int64 = 0 # seed page update time as total seconds since the epoch

  column chap_count : Int32 = 0   # total chapters
  column last_schid : String = "" # seed's latest chap id

  timestamps

  getter wlink : String { SiteLink.binfo_url(sname, snvid) }
  getter cvmtl : MtCore { MtCore.generic_mtl(cvbook.bhash) }

  def clink(schid : String) : String
    SiteLink.chtxt_url(sname, snvid, schid)
  end

  getter cvbook : Cvbook { Cvbook.load!(self.cvbook_id) }

  def unmatch?(cvbook_id : Int64) : Bool
    cvbook_id_column.value(0) != cvbook_id
  end

  def outdated?(privi = 0)
    duration = Time.utc - Time.unix(zhbook.bumped)
    case status
    when 0 then duration > 2.hours ** (4 - privi)
    when 1 then duration > 2.month * (4 - privi)
    else        false
    end
  end

  def refresh!(privi = 4, mode = 0, ttl = 5.minutes) : Tuple(Int64, Int32)
    unless mode > 0 && remote?(privi)
      reset_pages!(chmin: 1) if privi > 1
      return {mftime, chap_count}
    end

    RmInfo.mkdir!(sname)
    parser = RmInfo.init(sname, snvid, ttl: ttl)

    if mode > 1 || parser.last_schid != self.last_schid
      self.mftime = parser.mftime if parser.mftime > 0

      old_chap_count = chap_count
      self.chap_count = parser.chap_list.size

      self.last_schid = parser.last_schid
      self.bumped = Time.utc.to_unix

      Chlist.save!(sname, snvid, parser.chap_list, redo: privi > 0)
      Chpage.forget!(sname, snvid, -1)
      reset_pages!(chmin: old_chap_count)

      self.save!
      cvbook.tap(&.set_mftime(self.mftime)).save! # unless sname == "hetushu"
    else
      reset_pages!(chmin: 1) if privi > 1
    end

    {mftime, chap_count}
  end

  def remote?(privi = 4)
    Zhseed.remote?(sname, privi, old_enough?)
  end

  def old_enough?
    return false if Time.unix(self.bumped) >= Time.utc - 30.minutes
    Time.unix(self.mftime) < Time.utc - (status < 1 ? 2.days : 4.weeks)
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
    Chpage.load!(sname, snvid, pgidx) do
      chlist = self.chlist(pgidx // 4)
      Chpage.init!(chlist, cvmtl, pgidx)
    end
  end

  def lastpg
    Chpage.load!(sname, snvid, -1) do
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
    chidx < 40 || chidx >= self.chap_count - 5
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
    upsert!(Zhseed.index(sname), snvid)
  end

  CACHE = {} of Int64 => self

  def self.find(cvbook_id : Int64, zseed : Int32)
    find({cvbook_id: cvbook_id, zseed: zseed})
  end

  def self.load!(cvbook_id : Int64, zseed : Int32) : self
    load!(Cvbook.load!(cvbook_id), zseed)
  end

  def self.load!(cvbook : Cvbook, zseed : Int32) : self
    CACHE[cvbook.id << 6 | zseed] ||= find(cvbook.id, zseed) || begin
      zseed == 0 ? dummy_local(cvbook) : raise "Zhbook not found!"
    end
  end

  def get_schid(index : Int32)
    chinfo.get_info(index).try(&.first?) || (index + 1).to_s.rjust(4, '0')
  end

  def set_chap!(index : Int32, schid : String, title : String, label : String)
    chinfo.put_chap!(index, schid, title, label)
  end

  def chtext(index : Int32, schid : String? = get_schid(index))
    ChText.load(cvbook.bhash, sname, snvid, index, schid)
  end

  def self.dummy_local(cvbook : Cvbook)
    new({
      cvbook_id: cvbook.id,

      zseed: 0,
      snvid: cvbook.bhash,

      # status: cvbook.status,
      # shield: cvbook.shield,

      mftime: cvbook.mftime,
      # bumped: cvbook.bumped,

      chap_count: 0,
      last_schid: "",
    })
  end
end
