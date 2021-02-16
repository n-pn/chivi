require "json"
require "file_utils"

require "./chinfo/*"

require "../source/rm_chinfo"

require "../engine/convert"

class CV::Chinfo
  DIR = "_db/chdata/chinfos"
  ::FileUtils.mkdir_p(DIR)

  getter sname : String
  getter snvid : String

  alias Chlist = Array(Array(String))
  getter origs : Chlist { load_list("origs") }
  getter infos : Chlist { load_list("infos") }

  getter stats : ValueMap { ValueMap.new(map_path("stats"), mode: 1) }

  getter _utime : Int64 { @meta.get_utime(@snvid) }
  getter lastch : String { @meta.get_lastch(@snvid) }

  def initialize(@sname, @snvid)
    @meta = ChSource.load(@sname)
  end

  def load_list(label : String)
    file = map_path(label)
    return Chlist.new unless File.exists?(file)

    puts "- <chap_#{label}> [#{@sname}/#{@snvid}] loaded".colorize.blue
    File.read_lines(file).map(&.split('\t'))
  end

  def save_list(label : String, data : Chlist) : Nil
    file = map_path(label)

    File.write(file, data.map(&.join('\t')).join('\n'))
    puts "- <chap_#{label}> [#{@sname}/#{@snvid}] saved (entries: #{data.size})".colorize.yellow
  end

  private def map_path(label : String)
    "#{DIR}/#{sname}/#{label}/#{snvid}.tsv"
  end

  def fetch!(power = 4, force = false, ttl = 5.minutes) : Bool
    return false unless remote?(power)
    puller = RmChinfo.new(@sname, @snvid, ttl: ttl)

    last_chid = origs.last?.try(&.first?)
    if puller.changed?(last_chid || "")
      set_utime(puller.updated_at.to_unix)
    else
      return false unless force
    end

    @origs = puller.chap_list
    save_list("origs", origs)
    true
  rescue err
    puts "- Fetch chinfo error: #{err}".colorize.red
    false
  end

  def trans!(dname = "various", force = false) : Nil
    cvter = Convert.generic(dname)

    infos.clear if force
    infos.size.upto(origs.size - 1) do |idx|
      row = origs.unsafe_fetch(idx)
      schid = row[0]

      zh_title = row[1]
      zh_label = row[2]? || ""

      vi_title = cvter.tl_title(zh_title)
      vi_label = zh_label.empty? ? "Chính văn" : cvter.tl_title(zh_label)
      url_slug = TextUtils.tokenize(vi_title).first(12).join("-")

      infos << [schid, vi_title, vi_label, url_slug]
    rescue
      next
    end

    save_list("infos", infos)
  end

  def chsize
    infos.size
  end

  # def set_lastch(schid : String) : Bool
  #   raise "empty last_child!" if schid.empty?
  #   @meta.set_lastch(@snvid, schid).tap { |x| @lastch == schid if x }
  # end

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
      u_power > 2
    else
      u_power > 3
    end
  end

  def each(skip : Int32 = 0, take : Int32 = 30, desc = false)
    return if skip >= infos.size

    upto = skip + take
    upto = infos.size if upto > infos.size

    while skip < upto
      idx = desc ? infos.size - skip - 1 : skip
      yield idx, infos.unsafe_fetch(idx)
      skip += 1
    end
  end

  def json_each(json : JSON::Builder, skip : Int32, take : Int32, desc : Bool)
    json.array do
      each(skip, take, desc) do |idx, row|
        json.object do
          json.field "chidx", idx + 1
          json.field "schid", row[0]
          json.field "title", row[1]
          json.field "label", row[2]
          json.field "uslug", row[3]
        end
      rescue err
        puts err
      end
    end
  end

  def url_for(idx : Int32)
    return unless chap = infos[idx]?
    "-#{chap[3]}-#{sname}-#{idx + 1}"
  end

  def save!(mode : Symbol = :full)
    @meta.save!(mode: :upds)
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
