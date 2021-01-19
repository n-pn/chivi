require "file_utils"

require "./stores/*"
require "./chinfo/*"

require "./_inits/rm_info"
require "../engine/convert"

class CV::Chinfo
  DIR = "_db/chdata/chinfos"
  ::FileUtils.mkdir_p(DIR)

  getter s_name : String
  getter s_nvid : String

  getter origs : ValueMap { ValueMap.new(map_path("origs"), mode: 1) }
  getter stats : ValueMap { ValueMap.new(map_path("stats"), mode: 1) }
  getter infos : ValueMap { ValueMap.new(map_path("infos"), mode: 1) }
  getter chaps : Array(Tuple(String, Array(String))) { infos.data.to_a }

  getter _atime : Int64 { @meta._atime.ival_64(@s_nvid) }
  getter _utime : Int64 { @meta._utime.ival_64(@s_nvid) }
  getter l_chid : String { @meta.l_chid.fval(@s_nvid) || "" }

  def initialize(@s_name, @s_nvid)
    @meta = ChSource.load(@s_name)
  end

  def fetch!(power = 3, regen = false, expiry = Time.utc - 5.minutes) : Nil
    set_atime

    return unless remote?(power)
    source = RmInfo.init(@s_name, @s_nvid, expiry: expiry)

    # update last_chap
    return unless regen || set_last_chid(source.last_chap)
    set_utime(source.updated_at.to_unix)

    source.chap_list.each do |entry|
      scid, title, label = entry
      vals = label.empty? ? [title] : [title, label]
      next unless origs.add(scid, vals)
    end
  end

  def trans!(dname = "various", regen = false) : Nil
    cvter = Convert.generic(dname)

    origs.each do |scid, vals|
      next unless regen || !infos.has_key?(scid)

      zh_title = vals[0]
      vi_title = cvter.tl_title(zh_title)
      url_slug = TextUtils.tokenize(vi_title).first(12).join("-")

      zh_label = vals[1]? || ""
      vi_label = zh_label.empty? ? "Chính văn" : cvter.tl_title(zh_label)

      infos.add(scid, [vi_title, vi_label, url_slug])
    end

    @chaps = nil
  end

  def set_last_chid(scid : String)
    return unless @meta.last_chap.add(@s_nvid, scid)
    @last_chap = scid
  end

  def set_update_tz(mftime = Time.utc.to_unix)
    return unless @meta.update_tz.add(sbid, mftime)
    @update_tz = mftime
  end

  def set_atime(mftime = Time.utc.to_unix)
    return unless @meta.atime.add(sbid, mftime)
    @atime = mftime
  end

  private def remote?(power = 3)
    case @s_name
    when "rengshu", "xbiquge",
         "nofff", "5200",
         "biquge5200", "duokan8"
      power > 0
    when "hetushu", "zhwenpg"
      power > 1
    when "shubaow", "69shu", "paoshu8"
      power > 2
    else
      false
    end
  end

  private def map_path(name : String)
    "#{DIR}/#{seed}/#{name}/#{sbid}.tsv"
  end

  def each(skip : Int32 = 0, take : Int32 = 30, desc = false)
    return if skip >= chaps.size

    upto = skip + take
    upto = chaps.size if upto > chaps.size

    while skip < upto
      idx = desc ? chaps.size - skip - 1 : skip
      yield idx, chaps.unsafe_fetch(idx)
      skip += 1
    end
  end

  def url_for(idx : Int32, b_slug : String)
    return unless chap = chaps[idx]?
    uslug = chap[1][2]
    "/~#{b_slug}/-#{uslug}-#{seed}-#{idx + 1}"
  end

  def save!(mode : Symbol = :full)
    @meta.save!(mode: mode)

    @origs.try(&.save!(mode: mode))
    @stats.try(&.save!(mode: mode))
    @infos.try(&.save!(mode: mode))
  end

  CHINFOS = {} of String => self

  def self.load(seed : String, sbid : String) : self
    CHINFOS["#{seed}/#{sbid}"] ||= new(seed, sbid)
  end

  def self.save!(mode : Symbol = :full) : Nil
    CHINFOS.each(&.save!(mode: mode))
    ChSource.save!(mode: mode)
  end
end
