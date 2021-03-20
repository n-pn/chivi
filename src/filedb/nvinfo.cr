require "json"
require "./nvinfo/*"

class CV::Nvinfo
  # include JSON::Serializable

  getter bfile : String
  getter infos : ValueMap { ValueMap.load(@bfile) }

  getter bhash : String
  getter bslug : String { infos["bslug"].first }

  getter btitle : Array(String) { infos["btitle"] }
  getter author : Array(String) { infos["author"] }

  getter genres : Array(String) { infos["genres"] }
  getter bcover : String { infos["bcover"].first }
  getter bintro : String { NvBintro.get_bintro(@bhash, lang: "vi") }

  getter voters : Int32 { infos["voters"]?.try(&.first.to_i) || 0 }
  getter rating : Int32 { infos["rating"]?.try(&.first.to_i) || 0 }

  getter status : Int32 { infos["status"]?.try(&.first.to_i) || 0 }
  getter hidden : Int32 { infos["hidden"]?.try(&.first.to_i) || 0 }

  getter yousuu : String { infos["yousuu"]?.try(&.first) || "" }
  getter origin : String { infos["origin"]?.try(&.first) || "" }

  getter update : Array(String) { infos["update"]? || ["chivi", "0", "0"] }
  getter chseed : Array(NvChseed::Seed) { NvChseed.get_chseed(bhash) }

  DIR = "_db/nvdata/nvinfos"
  ::FileUtils.mkdir_p(DIR)

  def initialize(@bhash)
    @bfile = File.join(DIR, "#{@bhash}.tsv")
  end

  def inspect(io : IO, full : Bool = false)
    JSON.build(io) { |json| to_json(json, full) }
  end

  def to_json(json : JSON::Builder, full : Bool = false)
    json.object do
      json.field "bhash", bhash
      json.field "bslug", bslug

      json.field "btitle_zh", btitle[0]
      json.field "btitle_hv", btitle[1]? || btitle[0]
      json.field "btitle_vi", btitle[2]? || btitle[1]? || btitle[0]

      json.field "author_zh", author[0]
      json.field "author_vi", author[1]? || author[0]

      json.field "genres", genres
      json.field "bcover", bcover

      json.field "voters", voters
      json.field "rating", rating / 10

      json.field "update", update

      if full
        json.field "bintro", bintro
        json.field "status", status
        json.field "yousuu", yousuu
        json.field "origin", origin
        json.field "chseed", chseed
      end
    end
  end

  def bump_access!(atime : Time = Time.utc) : Nil
    @_atime = atime.to_unix
    return unless NvValues._atime.set!(bhash, @_atime)
    NvValues._atime.save!(clean: false) if NvValues._atime.unsaved > 5
  end

  def set_utime(mtime : Int64 = Time.utc.to_unix) : Bool
    @_utime = mtime unless @_utime.try(&.> mtime)
    NvValues.set_utime(bhash, mtime)
  end

  def put_chseed!(sname : String, snvid : String, mtime = 0, total = 0) : Nil
    # dirty hack to fix update_time for hetushu or zhwenpg...
    utime = _utime.//(60).to_i

    if old_value = chseed[sname]?
      _, old_mtime, old_total = old_value

      if total > old_total # if newer has more count
        if mtime <= old_mtime
          mtime = utime > old_mtime ? utime : Time.utc.to_unix.//(60).to_i
        end
      else
        mtime = old_mtime
      end
    elsif mtime < utime
      mtime = utime
    end

    NvValues.save!(clean: false) if set_utime(mtime.to_i64 * 60)

    chseed[sname] = {snvid, mtime, total}
    @chseed = chseed.to_a.sort_by { |_, v| -v[1] }.to_h

    NvChseed.set_snames(bhash, chseed.keys)
    NvChseed.put_chseed(bhash, sname, snvid, mtime, total)
  end

  def get_chseed(sname : String)
    snvid, mtime, total = chseed[sname]? || ["", "0", "0"]
    {snvid, mtime.to_i, total.to_i}
  end

  def save!(clean : Bool = false)
    @infos.try(&.save!(clean: clean))

    NvChseed.save!(clean: clean)
    NvTokens.save!(clean: clean)
  end

  def self.set!(zh_btitle : String, zh_author : String, fixed : Bool = false)
    unless fixed
      zh_btitle = NvHelper.fix_zh_btitle(zh_btitle)
      zh_author = NvHelper.fix_zh_author(zh_author)
    end

    bhash = CoreUtils.digest32("#{zh_btitle}--#{zh_author}")
    existed = NvValues._index.has_key?(bhash)

    unless existed
      set_author(bhash, zh_author)
      set_btitle(bhash, zh_btitle)

      bslug = NvTokens.btitle_hv.get(bhash).not_nil!.join("-")

      values = ["#{bslug}-#{bhash}"]
      values << bslug unless NvValues._index.has_val?(bslug)

      if vi_tokens = NvTokens.btitle_vi.get(bhash)
        vslug = vi_tokens.join("-")
        values << vslug unless NvValues._index.has_val?(vslug)
      end

      NvValues._index.set!(bhash, values.uniq)
    end

    {bhash, existed}
  end

  def self.set_btitle(bhash : String,
                      zh_btitle : String,
                      hv_btitle : String? = nil,
                      vi_btitle : String? = nil) : Nil
    hv_btitle ||= NvHelper.to_hanviet(zh_btitle)
    vi_btitle ||= NvHelper.fix_vi_btitle(zh_btitle)
    vi_btitle = nil if vi_btitle == hv_btitle

    vals = [zh_btitle, hv_btitle]
    vals << vi_btitle if vi_btitle

    NvValues.btitle.set!(bhash, vals)
    NvTokens.set_btitle_zh(bhash, zh_btitle)
    NvTokens.set_btitle_hv(bhash, hv_btitle)
    NvTokens.set_btitle_vi(bhash, vi_btitle) if vi_btitle
  end

  def self.set_author(bhash : String,
                      zh_author : String,
                      vi_author : String? = nil) : Nil
    vi_author ||= NvHelper.fix_vi_author(zh_author)

    NvValues.author.set!(bhash, [zh_author, vi_author])
    NvTokens.set_author_zh(bhash, zh_author)
    NvTokens.set_author_vi(bhash, vi_author)
  end

  def self.set_genres(bhash : String, input : Array(String), force = false) : Nil
    return unless force || !NvValues.genres.has_key?(bhash)

    NvValues.genres.set!(bhash, input)
    NvTokens.set_genres(bhash, input)
  end

  def self.save!(mode : Symbol = :full)
    NvValues.save!(mode: mode)
    NvTokens.save!(mode: mode)
  end

  def self.find_by_slug(bslug : String)
    NvValues._index.keys(bslug).first
  end

  def self.each(order_map = NvValues.weight, skip = 0, take = 24, matched : Set(String)? = nil)
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

  def self.get_order_map(order : String? = nil)
    case order
    when "access" then NvValues._atime
    when "update" then NvValues._utime
    when "rating" then NvValues.rating
    when "voters" then NvValues.voters
    else               NvValues.weight
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

# matched = CV::Nvinfo::NvTokens.glob(genre: "kinh di")
# CV::Nvinfo.each("weight", take: 10, matched: matched) do |bhash|
#   puts CV::Nvinfo.load(bhash)
# end
