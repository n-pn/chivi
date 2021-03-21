require "json"
require "./nvinfo/*"
require "../_utils/core_utils"

class CV::Nvinfo
  # include JSON::Serializable

  getter bhash : String
  getter infos : ValueMap

  DIR = "_db/nvdata/nvinfos"
  ::FileUtils.mkdir_p(DIR)

  def initialize(@bhash)
    info_file = File.join(DIR, "#{@bhash}.tsv")
    @infos = ValueMap.new(info_file)
  end

  def inspect(io : IO, full : Bool = false)
    JSON.build(io) { |json| to_json(json, full) }
  end

  def to_json(json : JSON::Builder, full : Bool = false)
    json.object do
      json.field "bhash", @bhash
      json.field "bslug", @infos.fval("bslug")

      json.field "btitle", @infos.get("btitle") || [bhash]
      json.field "author", @infos.get("author") || [bhash]

      json.field "genres", @infos.get("gemres") || ["Loại khác"]
      json.field "bcover", @infos.fval("bcover")

      json.field "voters", @infos.ival("voters")
      json.field "rating", @infos.ival("rating") // 10

      json.field "update", @infos.ival_64("voters")

      if full
        json.field "bintro", NvIntro.get_intro_vi(@bhash)

        json.field "status", @infos.ival("status")
        json.field "yousuu", @infos.fval("yousuu")
        json.field "origin", @infos.fval("origin")

        json.field "chseed", @infos.get("chseed")
      end
    end
  end

  def set_btitle!(zh_btitle : String,
                  hv_btitle = NvUtils.to_hanviet(zh_btitle),
                  vi_btitle = NvUtils.fix_btitle_vi(zh_btitle)) : Nil
    @infos.set!("btitle", [zh_btitle, hv_btitle, vi_btitle])

    NvIndex.set_btitle_zh(@bhash, zh_btitle)
    NvIndex.set_btitle_hv(@bhash, hv_btitle)
    NvIndex.set_btitle_vi(@bhash, vi_btitle) if vi_btitle != hv_btitle
  end

  def set_author!(zh_author : String, vi_author = NvUtils.fix_vi_author(zh_author)) : Nil
    @infos.set!("author", [zh_author, vi_author])
    NvIndex.set_author_zh(@bhash, zh_author)
    NvIndex.set_author_vi(@bhash, vi_author)
  end

  def set_genres(genres : Array(String)) : Nil
    @infos.set!("genres", genres)
    NvIndex.set_genres(@bhash, genres)
  end

  {% for field in {:status, :hidden} %}
    def set_{{field.id}}(value : Int32, force : Bool = false)
      return false unless force || value > @infos.ival({{field.stringify}})
      @infos.set!({{field.stringify}}, value)
    end
  {% end %}

  def set_access!(mftime : Int64 = Time.utc.to_unix) : Nil
    NvIndex.access.set!(@bhash, mftime // 60, flush: 5)
  end

  def set_update!(mftime : Int64 = Time.utc.to_unix) : Bool
    return false if @infos.ival_64("update") > mftime
    NvIndex.update.set!(@bhash, mftime // 60, flush: 5)
    @infos.set!("update", mftime)
  end

  def get_chseed(sname : String)
    return unless vals = @infs.get("$#{sname}")
    {vals[0], vals[1].to_i64, vals[2].to_i}
  end

  def set_chseed!(sname : String, snvid : String, mtime = 0_i64, count = 0) : Nil
    # dirty hack to fix update_time for hetushu or zhwenpg...
    seeds = @infos.get("chseed") || [] of String
    utime = @infos.ival_64("update")

    if old_value = get_chseed(sname)
      _svnid, old_mtime, old_count = old_value

      if count > old_count # if newer has more chapters
        if mtime <= old_mtime
          mtime = utime > old_mtime ? utime : Time.utc.to_unix
        end
      else
        mtime = old_mtime
      end
    elsif mtime < utime
      seeds << sname
      mtime = utime
    end

    @infos.set!("$#{sname}", [snvid, mtime.to_s, count.to_s], flush: 10)
    seeds = seeds.map { |sname| {sname, get_chseed(sname).not_nil![1]} }

    seeds = seeds.sort_by(&.[1].-).map(&.[0])
    @infos.set!("chseed", seeds)

    set_update!(mtime)
  end

  def save!(clean : Bool = false)
    @infos.save!(clean: clean)
    NvIndex.save!(clean: clean)
  end

  def self.upsert!(btitle : String, author : String, fixed : Bool = false)
    btitle, author = NvUtils.fix_labels(btitle, author) unless fixed
    bhash = CoreUtils.digest32("#{zh_btitle}--#{zh_author}")

    nvinfo = new(bhash)
    exists = nvinfo.infos.has_key?("bslug")

    unless exists
      nvinfo.set_author(zh_author)
      nvinfo.set_btitle(zh_btitle)

      half_slug = NvIndex.btitle_hv.get(bhash).not_nil!.join("-")
      full_slug = "#{half_slug}-#{bhash}"

      nvinfos.infos.set!("bslug", full_slug)

      values = [full_slug]
      values << half_slug unless NvIndex._index.has_val?(half_slug)
      NvIndex._index.set!(bhash, values)
    end

    {nvinfo, exists}
  end

  def self.find_by_slug(bslug : String)
    NvIndex._index.keys(bslug).first
  end

  def self.each(order_map = NvIndex.weight, skip = 0, take = 24, matched : Set(String)? = nil)
    if !matched
      iter = order_map._idx.reverse_each
      skip.times { return unless iter.next }

      take.times do
        return unless node = iter.next
        yield node.key
      end
    elsif matched.size > 512
      iter = order_map._idx.reverse_each

      while skip > 0
        return unless node = iter.next
        skip -= 1 if matched.includes?(node.key)
      end

      while take > 0
        return unless node = iter.next

        if matched.includes?(node.key)
          yield node.key
          take -= 1
        end
      end
    elsif matched.size > skip
      list = matched.to_a.sort_by { |bhash| order_map.get_val(bhash).- }
      upto = skip + take
      upto = list.size if upto > list.size
      skip.upto(upto - 1) { |i| yield list.unsafe_fetch(i) }
    end
  end

  CACHE = {} of String => self

  def self.load(bhash : String)
    CACHE[bhash] ||= new(bhash)
  end
end

# puts CV::Nvinfo.find_by_slug("quy-bi-chi-chu")
# pp CV::Nvinfo.new("h6cxpsr4")

# CV::Nvinfo.each("voters", take: 10) do |bhash|
#   puts CV::Nvinfo.load(bhash)
# end

# CV::Nvinfo.each("voters", skip: 5, take: 5) do |bhash|
#   puts CV::Nvinfo.load(bhash).btitle
# end

# matched = CV::Nvinfo::NvIndex.glob(genre: "kinh di")
# CV::Nvinfo.each("weight", take: 10, matched: matched) do |bhash|
#   puts CV::Nvinfo.load(bhash)
# end
