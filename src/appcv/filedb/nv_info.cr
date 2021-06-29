require "json"
require "../../cutil/core_utils"
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

  def self.filter(opts : Hash, prev : Set(String)? = nil)
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
    elsif matched.size > 1000
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
  getter snames : Array(String) { NvChseed.get_list(@bhash) }

  def initialize(@bhash)
  end

  def inspect(io : IO, full : Bool = false)
    JSON.build(io) { |json| to_json(json, full) }
  end

  def get_chseed(sname : String) : Tuple(String, Int64, Int32)
    seed = NvChseed.get_seed(sname, @bhash) || [@bhash, "0", "0"]
    {seed[0], seed[1].to_i64, seed[2].to_i}
  end

  SEED_ORDERS = {
    "zxcs_me", "hetushu", "bxwxorg", "69shu",
    "xbiquge", "rengshu", "biqubao", "bqg_5200",
    "5200", "nofff", "paoshu8", "zhwenpg",
    "duokan8", "shubaow", "jx_la",
  }

  def set_chseed(sname : String, snvid : String, mtime = 0_i64, count = 0) : Nil
    # dirty hack to fix update_time for hetushu or zhwenpg...
    mtime = fix_seed_mtime(sname, mtime, count)

    @update = nil
    NvOrders.set_update!(@bhash, mtime)

    @snames = begin
      snames = self.snames.reject("chivi")

      if sname != "chivi"
        snames.push(sname) unless snames.includes?(sname)
        snames.sort_by! { |x| SEED_ORDERS.index(x) || 99 }
      end

      snames.size > 4 ? snames.insert(4, "chivi") : snames.push("chivi")
    end

    NvChseed.set_list!(@bhash, snames)
    NvChseed.set_seed!(sname, @bhash, [snvid, mtime.to_s, count.to_s])
  end

  WRONG_MTIMES = {"zhwenpg", "hetushu", "69shu", "bqg_5200"}

  private def fix_seed_mtime(sname : String, mtime : Int64, count : Int32)
    return mtime unless WRONG_MTIMES.includes?(sname)

    if old_value = get_chseed(sname)
      _svnid, old_mtime, old_count = old_value

      if count > old_count # if newer has more chapters
        if mtime <= old_mtime
          mtime = update > old_mtime ? update : old_mtime
        end
      else
        mtime = old_mtime > 0 ? old_mtime : update
      end
    elsif mtime < update
      mtime = update
    end

    mtime
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
