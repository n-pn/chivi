require "json"
require "file_utils"

require "./chinfo/*"

require "../source/rm_info"
require "../engine/convert"

class CV::Chinfo
  DIR = "_db/chdata/chinfos"
  ::FileUtils.mkdir_p(DIR)

  getter sname : String
  getter snvid : String

  getter origs : ValueMap { ValueMap.new(map_path("origs"), mode: 1) }
  getter stats : ValueMap { ValueMap.new(map_path("stats"), mode: 1) }
  getter infos : ValueMap { ValueMap.new(map_path("infos"), mode: 1) }
  getter chaps : Array(Tuple(String, Array(String))) { infos.data.to_a }

  getter _atime : Int64 { @meta.get_atime(@snvid) }
  getter _utime : Int64 { @meta.get_utime(@snvid) }
  getter lastch : String { @meta.get_lastch(@snvid) }

  def initialize(@sname, @snvid)
    @meta = ChSource.load(@sname)
  end

  def chsize
    chaps.size
  end

  def fetch!(power = 3, force = false, expiry = Time.utc - 5.minutes) : Bool
    set_atime(Time.utc.to_unix)

    return false unless remote?(power)
    source = RmInfo.init(@sname, @snvid, expiry: expiry)

    # update last_chap
    changed = set_lastch(source.last_chid)
    return false unless changed || force

    source.chap_list.each do |entry|
      schid, title, label = entry
      origs.add(schid, label.empty? ? [title] : [title, label])
    end

    origs.save!(mode: :upds)
    changed && set_utime(source.updated_at.to_unix)
  rescue err
    puts "- Fetch chinfo error: #{err}".colorize.red
    false
  end

  def trans!(dname = "various", force = false) : Nil
    cvter = Convert.generic(dname)

    origs.each do |schid, values|
      next unless force || !infos.has_key?(schid)

      zh_title = values[0]
      vi_title = cvter.tl_title(zh_title)
      url_slug = TextUtils.tokenize(vi_title).first(12).join("-")

      zh_label = values[1]? || ""
      vi_label = zh_label.empty? ? "Chính văn" : cvter.tl_title(zh_label)

      infos.add(schid, [vi_title, vi_label, url_slug])
    end

    infos.save!(mode: :upds)
    @chaps = nil
  end

  def set_lastch(schid : String) : Bool
    raise "empty last_child!" if schid.empty?
    @meta.set_lastch(@snvid, schid).tap { |x| @lastch == schid if x }
  end

  def set_atime(mtime = Time.utc.to_unix) : Bool
    @meta.set_atime(@snvid, mtime).tap { |x| @_atime = mtime if x }
  end

  def set_utime(mtime = Time.utc.to_unix) : Bool
    @meta.set_utime(@snvid, mtime).tap { |x| @_utime = mtime if x }
  end

  private def remote?(u_power = 4)
    case @sname
    when "_chivi", "_miscs", "zxcs_me", "zadzs"
      false
    when "5200", "bqg_5200", "rengshu", "nofff"
      true
    when "xbiquge", "duokan8", "hetushu"
      u_power > 0
    when "zhwenpg", "69shu", "paoshu8"
      u_power > 1
    when "shubaow"
      u_power > 3
    else
      u_power > 3
    end
  end

  private def map_path(label : String)
    "#{DIR}/#{sname}/#{label}/#{snvid}.tsv"
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

  def json_each(json : JSON::Builder, skip : Int32, take : Int32, desc : Bool)
    json.array do
      each(skip, take, desc) do |idx, (schid, chinfo)|
        json.object do
          json.field "schid", schid
          json.field "chidx", idx + 1

          json.field "title", chinfo[0]
          json.field "label", chinfo[1]
          json.field "uslug", chinfo[2]
        end
      end
    end
  end

  def url_for(idx : Int32)
    return unless chap = chaps[idx]?
    "-#{chap[1][2]}-#{sname}-#{idx + 1}"
  end

  def save!(mode : Symbol = :full)
    @meta.save!(mode: :upds)

    @origs.try(&.save!(mode: mode))
    @infos.try(&.save!(mode: mode))
    @stats.try(&.save!(mode: mode))
  end

  CHINFOS = {} of String => self

  def self.load(sname : String, snvid : String) : self
    CHINFOS["#{sname}/#{snvid}"] ||= new(sname, snvid)
  end

  def self.save!(mode : Symbol = :full) : Nil
    CHINFOS.each(&.save!(mode: mode))
    ChSource.save!(mode: mode)
  end
end
