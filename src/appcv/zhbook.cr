require "../cutil/core_utils"

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

  getter chinfo : ChInfo { ChInfo.new(cvbook.bhash, sname, snvid) }

  getter wlink : String do
    case sname
    when "chivi"    then "/"
    when "nofff"    then "https://www.nofff.com/#{snvid}/"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}.htm"
    when "zxcs_me"  then "http://www.zxcs.me/post/#{snvid}/"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/"
    when "biqubao"  then "https://www.biqubao.com/book/#{snvid}/"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/"
    when "zhwenpg"  then "https://novel.zhwenpg.com/b.php?id=#{snvid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/index.html"
    when "duokan8"  then "http://www.duokanba.info/#{prefixed_snvid}/"
    when "paoshu8"  then "http://www.paoshu8.com/#{prefixed_snvid}/"
    when "5200"     then "https://www.5200.tv/#{prefixed_snvid}/"
    when "shubaow"  then "https://www.shubaow.net/#{prefixed_snvid}/"
    when "bqg_5200" then "http://www.biquge5200.net/#{prefixed_snvid}/"
    else                 "/"
    end
  end

  def clink(schid : String)
    case sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/#{schid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}/#{schid}"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/#{schid}.html"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/#{schid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}/#{schid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/#{schid}.html"
    when "biqubao"  then "https://www.biqubao.com/book/#{snvid}/#{schid}.html"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/#{schid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{schid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/#{schid}.html"
    when "duokan8"  then "http://www.duokanba.info/#{prefixed_snvid}/#{schid}.html"
    when "paoshu8"  then "http://www.paoshu8.com/#{prefixed_snvid}/#{schid}.html"
    when "5200"     then "https://www.5200.tv/#{prefixed_snvid}/#{schid}.html"
    when "shubaow"  then "https://www.shubaow.net/#{prefixed_snvid}/#{schid}.html"
    when "bqg_5200" then "http://www.biquge5200.net/#{prefixed_snvid}/#{schid}.html"
    else                 "/"
    end
  end

  def prefixed_snvid
    "#{snvid.to_i // 1000}_#{snvid}"
  end

  def unmatch?(cvbook_id : Int64) : Bool
    cvbook_id_column.value(0) != cvbook_id
  end

  def refresh!(privi = 4, mode = 0, ttl = 5.minutes) : Tuple(Int64, Int32)
    chinfo.reset_trans!(rmin: 1) if privi > 2
    return {mftime, chap_count} unless mode > 0 && remote?(privi)

    RmInfo.mkdir!(sname)
    parser = RmInfo.new(sname, snvid, ttl: ttl)

    if mode > 1 || parser.last_schid != self.last_schid
      self.mftime = parser.mftime > 0 ? parser.mftime : Time.utc.to_unix

      self.chap_count = parser.chap_list.size
      self.last_schid = parser.last_schid
      self.bumped = Time.utc.to_unix

      chinfo.save_seeds!(parser.chap_list)
      chinfo.reset_trans!(rmin: 1)

      self.save!
      Cvbook.load!(self.cvbook_id).tap(&.set_mftime(self.mftime)).save!
    end

    {mftime, chap_count}
  end

  def remote?(privi : Int32 = 4)
    case sname
    when "chivi", "zxcs_me"
      false
    when "5200", "bqg_5200", "rengshu", "nofff"
      true
    when "hetushu", "biqubao", "bxwxorg", "xbiquge", "69shu"
      privi >= 0 || old_enough?
    when "zhwenpg", "paoshu8", "duokan8"
      privi >= 1 || old_enough?
    when "shubaow", "jx_la"
      privi > 3 && ENV["AMBER_ENV"]? != "production"
    else
      privi > 1
    end
  end

  def remote_text?(chidx : Int32, privi : Int32 = 4)
    case sname
    when "chivi", "zxcs_me"
      false
    when "5200", "bqg_5200", "rengshu", "nofff"
      true
    when "hetushu", "biqubao", "bxwxorg", "xbiquge", "69shu"
      privi >= 0 || public_chap?(chidx)
    when "zhwenpg", "paoshu8", "duokan8"
      privi >= 1 || (privi >= 0 && public_chap?(chidx))
    when "shubaow", "jx_la"
      privi > 3 && ENV["AMBER_ENV"]? != "production"
    else
      privi > 1 || (privi >= 0 && public_chap?(chidx))
    end
  end

  def old_enough?
    return false if Time.unix(self.bumped) >= Time.utc - 30.minutes
    Time.unix(self.mftime) < Time.utc - (status < 1 ? 3.days : 3.weeks)
  end

  def public_chap?(chidx : Int32)
    chidx <= 40 || chidx >= self.chap_count - 5
  end

  def reset_trans!(chmin : Int32, chmax = self.chap_count)
    pgmax = chinfo.get_page(chmax - 1)
    pgmin = chinfo.get_page(chmin - 1)
    chinfo.reset_trans!(pgmax, pgmin)
  end

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
      zseed == 0 ? dummy(cvbook) : raise "Zhbook not found!"
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

  def self.dummy(cvbook : Cvbook)
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
