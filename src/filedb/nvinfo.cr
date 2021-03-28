require "json"
require "./nvinfo/*"
require "../utils/core_utils"

class CV::Nvinfo
  # include JSON::Serializable

  getter bhash : String
  getter _meta : ValueMap

  getter btitle : Array(String) { @_meta.get("btitle") || [""] }
  getter author : Array(String) { @_meta.get("author") || [""] }
  getter genres : Array(String) { @_meta.get("genres") || ["Loại khác"] }
  getter bcover : String { @_meta.fval("bcover") }
  getter voters : Int32 { @_meta.ival("voters") }
  getter rating : Int32 { @_meta.ival("rating") // 10 }

  DIR = "_db/nvdata/nvinfos"
  ::FileUtils.mkdir_p(DIR)

  def initialize(@bhash)
    info_file = File.join(DIR, "#{@bhash}.tsv")
    @_meta = ValueMap.new(info_file)
  end

  def inspect(io : IO, full : Bool = false)
    JSON.build(io) { |json| to_json(json, full) }
  end

  def btitle_zh
    btitle[0]
  end

  def btitle_hv
    btitle[1]? || btitle[0]
  end

  def btitle_vi
    btitle[2]? || btitle[1]? || btitle[0]
  end

  def author_zh
    author[0]
  end

  def author_vi
    author[1]? || author[0]
  end

  def mftime
    @_meta.ival_64("update")
  end

  def to_json(json : JSON::Builder, full : Bool = false)
    json.object do
      json.field "bhash", @bhash
      json.field "bslug", @_meta.fval("bslug")

      json.field "btitle_zh", btitle_zh
      json.field "btitle_hv", btitle_hv
      json.field "btitle_vi", btitle_vi

      json.field "author_zh", author_zh
      json.field "author_vi", author_vi

      json.field "genres", genres
      json.field "bcover", bcover

      json.field "voters", voters
      json.field "rating", rating

      json.field "update", @_meta.ival_64("update")

      if full
        json.field "bintro", @_meta.get("bintro")

        json.field "status", @_meta.ival("status")
        json.field "yousuu", @_meta.fval("yousuu")
        json.field "origin", @_meta.fval("origin")

        chseed = @_meta.get("chseed") || ["chivi"]
        json.field "chseed", chseed

        chseed.each do |sname|
          json.field "$#{sname}", get_chseed(sname)
        end
      end
    end
  end

  def set_btitle(zh_btitle : String,
                 hv_btitle = NvUtils.to_hanviet(zh_btitle),
                 vi_btitle = NvUtils.fix_btitle_vi(zh_btitle)) : Nil
    @_meta.set!("btitle", [zh_btitle, hv_btitle, vi_btitle].uniq)

    NvIndex.set_btitle_zh(@bhash, zh_btitle)
    NvIndex.set_btitle_hv(@bhash, hv_btitle)
    NvIndex.set_btitle_vi(@bhash, vi_btitle) if vi_btitle != hv_btitle
  end

  def set_author(zh_author : String, vi_author = NvUtils.fix_author_vi(zh_author)) : Nil
    @_meta.set!("author", [zh_author, vi_author].uniq)
    NvIndex.set_author_zh(@bhash, zh_author)
    NvIndex.set_author_vi(@bhash, vi_author)
  end

  def set_genres(genres : Array(String), force : Bool = false) : Nil
    return unless force || !@_meta.has_key?("genres")

    @_meta.set!("genres", genres)
    NvIndex.set_genres(@bhash, genres)
  end

  def set_bintro(lines : Array(String), force : Bool = false)
    return unless force || !@_meta.has_key?("bintro")
    NvIntro.set_intro(@bhash, lines, force: force)

    cvmtl = Cvmtl.generic(@bhash)
    intro = lines.map { |line| cvmtl.tl_plain(line) }

    @_meta.set!("bintro", intro)
  end

  {% for field in {"status", "hidden"} %}
    def set_{{field.id}}(value : Int32, force : Bool = false)
      return false unless force || value > @_meta.ival({{field}})
      @_meta.set!({{field}}, value)
    end
  {% end %}

  def bump_access!(mftime : Int64 = Time.utc.to_unix) : Nil
    NvIndex.access.set!(@bhash, [mftime.//(60).to_s])
  end

  def set_update(mftime : Int64 = Time.utc.to_unix) : Bool
    return false if @_meta.ival_64("update") > mftime
    NvIndex.update.set!(@bhash, [mftime.//(60).to_s])
    @_meta.set!("update", mftime)
  end

  def set_scores(voters : Int32, rating : Int32) : Nil
    @_meta.set!("voters", voters)
    @_meta.set!("rating", rating)
    NvIndex.set_scores(@bhash, voters, rating)
  end

  {% for type in {"origin", "yousuu", "hidden"} %}
    def set_{{type.id}}(value)
      @_meta.set!({{type}}, value)
    end
  {% end %}

  def set_chseed(sname : String, snvid : String, mtime = 0_i64, count = 0) : Nil
    seeds = @_meta.get!("chseed") { ["chivi"] }
    utime = @_meta.ival_64("update")

    # dirty hack to fix update_time for hetushu or zhwenpg...
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
      mtime = utime
    end

    @_meta.set!("$#{sname}", [snvid, mtime.to_s, count.to_s])

    seeds << sname
    seeds = seeds.uniq.map { |s| {s, get_chseed(s)[1]} }

    chseed = seeds.sort_by(&.[1].-).map(&.[0])
    @_meta.set!("chseed", chseed)

    set_update(mtime)
  end

  def get_chseed(sname : String) : Tuple(String, Int64, Int32)
    meta = @_meta.get("$#{sname}") || [bhash, "0", "0"]
    {meta[0], meta[1].to_i64, meta[2].to_i}
  end

  def save!(clean : Bool = false)
    @_meta.save!(clean: clean)
  end

  def self.upsert!(btitle : String, author : String, fixed : Bool = false)
    btitle, author = NvUtils.fix_labels(btitle, author) unless fixed
    bhash = CoreUtils.digest32("#{btitle}--#{author}")

    nvinfo = new(bhash)
    exists = nvinfo._meta.has_key?("bslug")

    unless exists
      nvinfo.set_author(author)
      nvinfo.set_btitle(btitle)

      half_slug = TextUtils.slugify(nvinfo.btitle_hv)
      full_slug = "#{half_slug}-#{bhash}"

      nvinfo._meta.set!("bslug", full_slug)
      NvIndex._index.set!(bhash, [full_slug, half_slug])
    end

    {nvinfo, exists}
  end

  def self.find_by_slug(bslug : String)
    NvIndex._index.keys(bslug).first?
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
