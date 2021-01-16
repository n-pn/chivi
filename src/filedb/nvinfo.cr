require "json"
require "./nvinfo/*"

class CV::Nvinfo
  # include JSON::Serializable

  getter bhash : String
  getter bslug : String { NvFields._index.fval(bhash) || bhash }

  getter btitle : Array(String) { NvFields.btitle.get(bhash).not_nil! }
  getter author : Array(String) { NvFields.author.get(bhash).not_nil! }
  getter genres : Array(String) { NvFields.bgenre.get(bhash) || [] of String }

  getter bcover : String { NvFields.bcover.fval(bhash) || "blank.png" }
  getter voters : Int32 { NvFields.voters.ival(bhash) }
  getter rating : Int32 { NvFields.rating.ival(bhash) }

  getter chseed : Hash(String, String) { NvFields.get_chseed(bhash) }
  getter bintro : Array(String) { NvFields.get_bintro(bhash) }

  getter status : Int32 { NvFields.status.ival(bhash) }
  getter shield : Int32 { NvFields.shield.ival(bhash) }

  getter yousuu : String { NvFields.yousuu.fval(bhash) || "" }
  getter origin : String { NvFields.origin.fval(bhash) || "" }

  getter access_tz : Int64 { NvFields.access_tz.ival_64(bhash) }
  getter update_tz : Int64 { NvFields.update_tz.ival_64(bhash) }

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
        json.field "chseed", chseed
        json.field "bintro", bintro
        json.field "status", status

        json.field "yousuu", yousuu
        json.field "origin", origin

        json.field "update_tz", update_tz
      end
    end
  end

  def bump_access!(atime : Time = Time.utc) : Nil
    @access_tz = atime.to_unix // 60
    return unless NvFields.access_tz.add(bhash, @access_tz)
    NvFields.access_tz.save!(mode: :upds) if NvFields.access_tz.unsaved > 10
  end

  def self.upsert!(zh_btitle : String, zh_author : String, fixed : Bool = false)
    unless fixed
      zh_btitle = NvShared.fix_zh_btitle(zh_btitle)
      zh_author = NvShared.fix_zh_author(zh_author)
    end

    bhash = CoreUtils.digest32("#{zh_btitle}--#{zh_author}")
    existed = NvFields._index.has_key?(bhash)

    unless existed
      set_author(bhash, zh_author)
      set_btitle(bhash, zh_btitle)

      bslug = NvTokens.btitle_hv.get(bhash).not_nil!.join("-")
      bslug += "-#{bhash}" if NvFields._index.has_val?(bslug)

      slugs = [bslug]
      if vi_tokens = NvTokens.btitle_vi.get(bhash)
        vslug = vi_tokens.join("-")
        slugs << vslug unless NvFields._index.has_val?(vslug)
      end

      NvFields._index.add(bhash, slugs)
    end

    {bhash, existed}
  end

  def self.set_btitle(bhash : String,
                      zh_btitle : String,
                      hv_btitle : String? = nil,
                      vi_btitle : String? = nil) : Nil
    hv_btitle ||= NvShared.to_hanviet(zh_btitle)
    vi_btitle ||= NvShared.fix_vi_btitle(zh_btitle)
    vi_btitle = nil if vi_btitle == hv_btitle

    vals = [zh_btitle, hv_btitle]
    vals << vi_btitle if vi_btitle

    if NvFields.btitle.add(bhash, vals)
      NvTokens.set_btitle_zh(bhash, zh_btitle)
      NvTokens.set_btitle_hv(bhash, hv_btitle)
      NvTokens.set_btitle_vi(bhash, vi_btitle) if vi_btitle
    end
  end

  def self.set_author(bhash : String,
                      zh_author : String,
                      vi_author : String? = nil) : Nil
    vi_author ||= NvShared.fix_vi_author(zh_author)

    if NvFields.author.add(bhash, [zh_author, vi_author])
      NvTokens.set_author_zh(bhash, zh_author)
      NvTokens.set_author_vi(bhash, vi_author)
    end
  end

  def self.save!(mode : Symbol = :full)
    NvFields.save!(mode: mode)
    NvTokens.save!(mode: mode)
  end

  def self.find_by_slug(slug : String)
    NvFields._index.keys(slug).first
  end

  def self.each(order_map = NvFields.weight, skip = 0, take = 24, matched : Set(String)? = nil)
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
    when "access" then NvFields.access_tz
    when "update" then NvFields.update_tz
    when "rating" then NvFields.rating
    when "voters" then NvFields.voters
    else               NvFields.weight
    end
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
