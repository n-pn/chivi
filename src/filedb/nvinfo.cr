require "json"
require "./nvinfo/*"

class CV::Nvinfo
  # include JSON::Serializable

  getter b_hash : String
  getter b_slug : String { NvValues._index.fval(b_hash) || b_hash }

  getter btitle : Array(String) { NvValues.btitle.get(b_hash).not_nil! }
  getter author : Array(String) { NvValues.author.get(b_hash).not_nil! }

  getter genres : Array(String) { NvValues.genres.get(b_hash) || [] of String }
  getter bcover : String { NvValues.bcover.fval(b_hash) || "blank.png" }

  getter voters : Int32 { NvValues.voters.ival(b_hash) }
  getter rating : Int32 { NvValues.rating.ival(b_hash) }

  getter bintro : Array(String) { NvValues.get_bintro(b_hash) }
  getter status : Int32 { NvValues.status.ival(b_hash) }
  getter source : Hash(String, String) { NvValues.get_source(b_hash) }

  getter hidden : Int32 { NvValues.hidden.ival(b_hash) }
  getter yousuu : String { NvValues.yousuu.fval(b_hash) || "" }
  getter origin : String { NvValues.origin.fval(b_hash) || "" }

  getter _atime : Int64 { NvValues._atime.ival_64(b_hash) }
  getter _utime : Int64 { NvValues._utime.ival_64(b_hash) }

  def initialize(@b_hash)
  end

  def inspect(io : IO, full : Bool = false)
    JSON.build(io) { |json| to_json(json, full) }
  end

  def to_json(json : JSON::Builder, full : Bool = false)
    json.object do
      json.field "b_hash", b_hash
      json.field "b_slug", b_slug

      json.field "btitle", btitle
      json.field "author", author

      json.field "genres", genres
      json.field "bcover", bcover

      json.field "voters", voters
      json.field "rating", rating

      if full
        json.field "source", source
        json.field "bintro", bintro
        json.field "status", status

        json.field "yousuu", yousuu
        json.field "origin", origin

        json.field "_utime", _utime
      end
    end
  end

  def bump_access!(atime : Time = Time.utc) : Nil
    @_atime = atime.to_unix // 60
    return unless NvValues._atime.add(b_hash, @_atime)
    NvValues._atime.save!(mode: :upds) if NvValues._atime.unsaved > 10
  end

  def self.upsert!(zh_btitle : String, zh_author : String, fixed : Bool = false)
    unless fixed
      zh_btitle = NvHelper.fix_zh_btitle(zh_btitle)
      zh_author = NvHelper.fix_zh_author(zh_author)
    end

    b_hash = CoreUtils.digest32("#{zh_btitle}--#{zh_author}")
    existed = NvValues._index.has_key?(b_hash)

    unless existed
      set_author(b_hash, zh_author)
      set_btitle(b_hash, zh_btitle)

      b_slug = NvTokens.btitle_hv.get(b_hash).not_nil!.join("-")
      b_slug += "-#{b_hash}" if NvValues._index.has_val?(b_slug)

      slugs = [b_slug]
      if vi_tokens = NvTokens.btitle_vi.get(b_hash)
        vslug = vi_tokens.join("-")
        slugs << vslug unless NvValues._index.has_val?(vslug)
      end

      NvValues._index.add(b_hash, slugs)
    end

    {b_hash, existed}
  end

  def self.set_btitle(b_hash : String,
                      zh_btitle : String,
                      hv_btitle : String? = nil,
                      vi_btitle : String? = nil) : Nil
    hv_btitle ||= NvHelper.to_hanviet(zh_btitle)
    vi_btitle ||= NvHelper.fix_vi_btitle(zh_btitle)
    vi_btitle = nil if vi_btitle == hv_btitle

    vals = [zh_btitle, hv_btitle]
    vals << vi_btitle if vi_btitle

    if NvValues.btitle.add(b_hash, vals)
      NvTokens.set_btitle_zh(b_hash, zh_btitle)
      NvTokens.set_btitle_hv(b_hash, hv_btitle)
      NvTokens.set_btitle_vi(b_hash, vi_btitle) if vi_btitle
    end
  end

  def self.set_author(b_hash : String,
                      zh_author : String,
                      vi_author : String? = nil) : Nil
    vi_author ||= NvHelper.fix_vi_author(zh_author)

    if NvValues.author.add(b_hash, [zh_author, vi_author])
      NvTokens.set_author_zh(b_hash, zh_author)
      NvTokens.set_author_vi(b_hash, vi_author)
    end
  end

  def self.set_genres(b_hash : String, input : Array(String), regen = false) : Nil
    return unless regen || !NvValues.genres.has_key?(b_hash)
    if NvValues.genres.add(b_hash, input)
      NvTokens.set_genres(b_hash, input)
    end
  end

  def self.set_source(b_hash : String, s_name : String, s_nvid : String) : Nil
    source = NvValues.source.get(b_hash) || [] of String
    source = source.each_with_object({} of String => String) do |x, h|
      a, b = x.split("/")
      h[a] = b
    end

    return if source[s_name]? == s_nvid
    source[s_name] = s_nvid

    NvValues.source.add(b_hash, source.to_a.map { |a, b| "#{a}/#{b}" })
    NvTokens.set_source(b_hash, source.keys)
  end

  def self.save!(mode : Symbol = :full)
    NvValues.save!(mode: mode)
    NvTokens.save!(mode: mode)
  end

  def self.find_by_slug(b_slug : String)
    NvValues._index.keys(b_slug).first
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
      list = matched.to_a.sort_by { |b_hash| order_map.get_val(b_hash).- }
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

  def self.load(b_hash : String)
    CACHE[b_hash] ||= new(b_hash)
  end
end

# puts CV::Nvinfo.find_by_slug("quy-bi-chi-chu")
# pp CV::Nvinfo.new("h6cxpsr4")

# CV::Nvinfo.each("voters", take: 10) do |b_hash|
#   puts CV::Nvinfo.load(b_hash)
# end

# CV::Nvinfo.each("voters", skip: 5, take: 5) do |b_hash|
#   puts CV::Nvinfo.load(b_hash).btitle
# end

# matched = CV::Nvinfo::NvTokens.glob(genre: "kinh di")
# CV::Nvinfo.each("weight", take: 10, matched: matched) do |b_hash|
#   puts CV::Nvinfo.load(b_hash)
# end
