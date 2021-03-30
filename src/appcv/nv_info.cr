require "json"
require "../utils/core_utils"
require "./nv_info/*"

class CV::NvInfo
  # include JSON::Serializable

  CACHE = {} of String => self

  def self.load(bhash : String)
    CACHE[bhash] ||= new(bhash)
  end

  def self.save!(clean = false)
    NvAuthor.save!(clean: clean)
    NvBtitle.save!(clean: clean)

    NvGenres.save!(clean: clean)
    NvBintro.save!(clean: clean)

    NvFields.save!(clean: clean)
    NvOrders.save!(clean: clean)

    NvChseed.save!(clean: clean)
  end

  def self.exists?(bhash : String)
    NvFields._index.has_key?(bhash)
  end

  def self.upsert!(btitle : String, author : String, fixed : Bool = false)
    unless fixed
      author = NvAuthor.fix_zh_name(author, btitle)
      btitle = NvBtitle.fix_zh_name(btitle, author)
    end

    bhash = CoreUtils.digest32("#{btitle}--#{author}")

    unless exists?(bhash)
      NvAuthor.set!(bhash, author)
      NvBtitle.set!(bhash, btitle)

      btitle_hv = NvBtitle.get(bhash).not_nil![1]
      half_slug = TextUtils.slugify(btitle_hv)
      full_slug = "#{half_slug}-#{bhash}"

      NvFields._index.set!(bhash, [full_slug, half_slug])
    end

    {bhash, btitle, author}
  end

  def self.find_by_slug(bslug : String)
    NvFields._index.keys(bslug).first?
  end

  def self.filter(opts, prev : Set(String)? = nil)
    {"btitle", "author", "genre", "sname"}.each do |type|
      next unless str = opts[type]?
      prev = filter(str, type, prev)
      break if prev.empty?
    end

    prev
  end

  def self.filter(str : String, type : String, prev : Set(String)? = nil)
    case type
    when "btitle" then NvBtitle.filter(str, prev)
    when "author" then NvAuthor.filter(str, prev)
    when "genre"  then NvGenres.filter(str, prev)
    when "sname"  then NvChseed.filter(str, prev)
    else               prev || Set(String).new
    end
  end

  def self.each(order : String, skip = 0, take = 25, matched : Set(String)? = nil)
    order_map = NvOrders.get(order)

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

  getter bhash : String
  getter bslug : String { NvFields._index.fval(@bhash) || bhash }

  getter btitle : Array(String) { NvBtitle.get(@bhash) || ["", "", ""] }
  getter author : Array(String) { NvAuthor.get(@bhash) || ["", ""] }

  getter genres : Array(String) { NvGenres.get(@bhash) || ["Loại khác"] }
  getter bintro : Array(String) { NvBintro.get(@bhash, "vi") }

  getter bcover : String { NvFields.bcover.fval(@bhash) || "" }
  getter yousuu : String { NvFields.yousuu.fval(@bhash) || "" }
  getter origin : String { NvFields.origin.fval(@bhash) || "" }

  getter status : Int32 { NvFields.status.ival(@bhash) }
  getter hidden : Int32 { NvFields.hidden.ival(@bhash) }

  getter voters : Int32 { NvOrders.voters.ival(@bhash) }
  getter rating : Float64 { NvOrders.rating.ival(@bhash) / 10 }

  getter update : Int64 { NvOrders.update.ival_64(@bhash) }
  getter chseed : Array(String) { NvChseed.get_list(@bhash) }

  def initialize(@bhash)
  end

  def inspect(io : IO, full : Bool = false)
    JSON.build(io) { |json| to_json(json, full) }
  end

  def to_json(json : JSON::Builder, full : Bool = false)
    json.object do
      json.field "bhash", bhash
      json.field "bslug", bslug

      json.field "btitle_zh", btitle[0]
      json.field "btitle_hv", btitle[1]
      json.field "btitle_vi", btitle[2]

      json.field "author_zh", author[0]
      json.field "author_vi", author[1]

      json.field "genres", genres
      json.field "bcover", bcover

      json.field "voters", voters
      json.field "rating", rating

      if full
        json.field "bintro", bintro

        json.field "update", update
        json.field "status", status

        json.field "yousuu", yousuu
        json.field "origin", origin

        json.field "chseed", chseed

        chseed.each do |sname|
          json.field "$#{sname}", get_chseed(sname)
        end
      end
    end
  end

  def get_chseed(sname : String) : Tuple(String, Int64, Int32)
    seed = NvChseed.get_seed(sname, @bhash) || [@bhash, "0", "0"]
    {seed[0], seed[1].to_i64, seed[2].to_i}
  end

  def set_chseed(sname : String, snvid : String, mtime = 0_i64, count = 0) : Nil
    # dirty hack to fix update_time for hetushu or zhwenpg...
    if old_value = get_chseed(sname)
      _svnid, old_mtime, old_count = old_value

      if count > old_count # if newer has more chapters
        if mtime <= old_mtime
          mtime = update > old_mtime ? update : Time.utc.to_unix
        end
      else
        mtime = old_mtime > 0 ? old_mtime : Time.utc.to_unix
      end
    elsif mtime < update
      mtime = update
    end

    @update = nil
    NvOrders.set_update!(@bhash, mtime)

    snames = chseed
    snames << sname

    snames = snames.uniq.map { |s| {s, -get_chseed(s)[1]} }
    @chseed = snames.sort_by(&.[1]).map(&.[0])

    NvChseed.set_list!(@bhash, chseed)
    NvChseed.set_seed!(sname, @bhash, [snvid, mtime.to_s, count.to_s])
  end
end

# puts CV::NvInfo.find_by_slug("quy-bi-chi-chu")
# pp CV::NvInfo.new("h6cxpsr4")

# CV::NvInfo.each("voters", take: 10) do |bhash|
#   puts CV::NvInfo.load(bhash)
# end

# CV::NvInfo.each("voters", skip: 5, take: 5) do |bhash|
#   puts CV::NvInfo.load(bhash).btitle
# end

# matched = CV::NvInfo::NvIndex.glob(genre: "kinh di")
# CV::NvInfo.each("weight", take: 10, matched: matched) do |bhash|
#   puts CV::NvInfo.load(bhash)
# end
