require "json"
require "./nvinfo/*"
require "./chinfo/ch_source"

class CV::Nvinfo
  # include JSON::Serializable

  getter bhash : String
  getter bslug : String { NvValues._index.fval(bhash) || bhash }

  getter btitle : Array(String) { NvValues.btitle.get(bhash).not_nil! }
  getter author : Array(String) { NvValues.author.get(bhash).not_nil! }

  getter genres : Array(String) { NvValues.genres.get(bhash) || [] of String }
  getter bcover : String { NvValues.bcover.fval(bhash) }

  getter voters : Int32 { NvValues.voters.ival(bhash) }
  getter rating : Int32 { NvValues.rating.ival(bhash) }

  getter bintro : Array(String) { NvValues.get_bintro(bhash) }
  getter status : Int32 { NvValues.status.ival(bhash) }
  getter source : Hash(String, String) { NvValues.get_source(bhash) }

  getter hidden : Int32 { NvValues.hidden.ival(bhash) }
  getter yousuu : String { NvValues.yousuu.fval(bhash) || "" }
  getter origin : String { NvValues.origin.fval(bhash) || "" }

  getter _atime : Int64 { NvValues._atime.ival_64(bhash) }
  getter _utime : Int64 { NvValues._utime.ival_64(bhash) }

  def initialize(@bhash)
  end

  def inspect(io : IO, full : Bool = false)
    JSON.build(io) { |json| to_json(json, full) }
  end

  def to_json(json : JSON::Builder, full : Bool = false)
    json.object do
      json.field "bhash", bhash
      json.field "bslug", bslug

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
    return unless NvValues._atime.add(bhash, @_atime)
    NvValues._atime.save!(mode: :upds) if NvValues._atime.unsaved > 10
  end

  def set_utime(mtime : Int64 = Time.utc.to_unix) : Bool
    NvValues.set_utime(bhash, mtime).tap { |x| @_utime = mtime if x }
  end

  def fix_source! : Hash(String, String)
    chseed = source.to_a.sort_by { |sname, snvid| -source_order(sname, snvid) }
    NvValues.source.add(bhash, chseed.map { |a, b| "#{a}/#{b}" })
    source = chseed.to_h
  end

  def save!(mode = :upds)
    NvValues.save!(mode: :upds)
    NvTokens.save!(mode: :upds)
  end

  private def source_order(sname : String, snvid : String)
    case sname
    when "jx_la", "shubaow", "69shu"
      0_i64
    else
      ChSource.get_utime(sname, snvid)
    end
  rescue
    -1_i64
  end

  def self.upsert!(zh_btitle : String, zh_author : String, fixed : Bool = false)
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

      NvValues._index.add(bhash, values.uniq)
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

    NvValues.btitle.add(bhash, vals)
    NvTokens.set_btitle_zh(bhash, zh_btitle)
    NvTokens.set_btitle_hv(bhash, hv_btitle)
    NvTokens.set_btitle_vi(bhash, vi_btitle) if vi_btitle
  end

  def self.set_author(bhash : String,
                      zh_author : String,
                      vi_author : String? = nil) : Nil
    vi_author ||= NvHelper.fix_vi_author(zh_author)

    NvValues.author.add(bhash, [zh_author, vi_author])
    NvTokens.set_author_zh(bhash, zh_author)
    NvTokens.set_author_vi(bhash, vi_author)
  end

  def self.set_genres(bhash : String, input : Array(String), force = false) : Nil
    return unless force || !NvValues.genres.has_key?(bhash)

    NvValues.genres.add(bhash, input)
    NvTokens.set_genres(bhash, input)
  end

  def self.set_source(bhash : String, sname : String, snvid : String) : Nil
    source = NvValues.source.get(bhash) || [] of String
    source = source.each_with_object({} of String => String) do |x, h|
      a, b = x.split("/")
      h[a] = b
    end

    return if source[sname]? == snvid
    source[sname] = snvid

    NvValues.source.add(bhash, source.to_a.map { |a, b| "#{a}/#{b}" })
    NvTokens.source.add(bhash, source.keys)
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
