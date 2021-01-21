require "file_utils"

require "./chinfo/*"

require "../source/rm_info"
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

  def fetch!(power = 3, force = false, expiry = Time.utc - 5.minutes) : Bool
    return false unless remote?(power)
    source = RmInfo.init(@s_name, @s_nvid, expiry: expiry)

    # update last_chap
    return false unless force || set_last_chid(source.last_chid)
    changed = set_utime(source.updated_at.to_unix)

    source.chap_list.each do |entry|
      s_chid, title, label = entry
      values = label.empty? ? [title] : [title, label]
      next unless origs.add(s_chid, values)
    end

    set_atime(Time.utc.to_unix)
    changed
  end

  def trans!(dname = "various", force = false) : Nil
    cvter = Convert.generic(dname)

    origs.each do |s_chid, values|
      next unless force || !infos.has_key?(s_chid)

      zh_title = values[0]
      vi_title = cvter.tl_title(zh_title)
      url_slug = TextUtils.tokenize(vi_title).first(12).join("-")

      zh_label = values[1]? || ""
      vi_label = zh_label.empty? ? "Chính văn" : cvter.tl_title(zh_label)

      infos.add(s_chid, [vi_title, vi_label, url_slug])
    end

    @chaps = nil
  end

  def set_last_chid(s_chid : String) : Bool
    return false unless @meta.l_chid.add(@s_nvid, s_chid)
    @l_chid = s_chid
    true
  end

  def set_atime(mtime = Time.utc.to_unix) : Bool
    return false unless @meta._atime.add(s_nvid, mtime)
    @_atime = mtime
    true
  end

  def set_utime(mtime = Time.utc.to_unix) : Bool
    return false unless @meta._utime.add(s_nvid, mtime)
    @_utime = mtime
    true
  end

  private def remote?(power = 3)
    case @s_name
    when "rengshu", "xbiquge",
         "nofff", "5200",
         "bqg_5200", "duokan8"
      power > 0
    when "hetushu", "zhwenpg"
      power > 1
    when "shubaow", "69shu", "paoshu8"
      power > 2
    else
      false
    end
  end

  private def map_path(label : String)
    "#{DIR}/#{s_name}/#{label}/#{s_nvid}.tsv"
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
    "/~#{b_slug}/-#{uslug}-#{s_name}-#{idx + 1}"
  end

  def save!(mode : Symbol = :full)
    @meta.save!(mode: :upds)

    @origs.try(&.save!(mode: mode))
    @infos.try(&.save!(mode: mode))
    @stats.try(&.save!(mode: mode))
  end

  CHINFOS = {} of String => self

  def self.load(s_name : String, s_nvid : String) : self
    CHINFOS["#{s_name}/#{s_nvid}"] ||= new(s_name, s_nvid)
  end

  def self.save!(mode : Symbol = :full) : Nil
    CHINFOS.each(&.save!(mode: mode))
    ChSource.save!(mode: mode)
  end
end
