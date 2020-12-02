require "json"
require "file_utils"
require "../mapper/*"
require "../../_utils/text_util"

module Chivi::BookMeta
  class Info
    include JSON::Serializable

    property bhash = ""
    property bslug = ""

    property title_zh = ""
    property title_hv = ""
    property title_vi = ""

    property author_zh = ""
    property author_vi = ""

    property intro_vi = ""
    property genres_vi = ""

    property cover_name = ""
    property yousuu_bid = ""
    property origin_url = ""

    property status : Int32 = 0
    property update : Int32 = 0

    property voters : Int32 = 0
    property rating : Int32 = 0
    property weight : Int32 = 0

    property seeds : Array(String) = [] of String

    def initialize(@bhash)
    end

    macro set_int_field(field)
      def {{field}}=(value : String)
        @{{field}} = value.to_i? || 0
      end
    end

    set_int_field status
    set_int_field update

    set_int_field voters
    set_int_field rating
    set_int_field weight

    def seeds=(input : String)
      @seeds = input.split("  ")
    end
  end

  extend self

  DIR = "_db/prime/serial/infos"
  FileUtils.mkdir_p(DIR)

  VALUES = {} of String => ValueMap
  TOKENS = {} of String => TokenMap
  ORDERS = {} of String => OrderMap

  private def load_value_map(name : String) : ValueMap
    VALUES[name] ||= ValueMap.new("#{DIR}/#{name}.tsv")
  end

  private def load_token_map(name : String) : TokenMap
    TOKENS[name] ||= TokenMap.new("#{DIR}/#{name}.tsv")
  end

  private def load_order_map(name : String) : OrderMap
    ORDERS[name] ||= OrderMap.new("#{DIR}/#{name}.tsv")
  end

  class_getter bhash_fs : ValueMap { load_value_map("bhash") }
  class_getter bslug_fs : ValueMap { load_value_map("bslug") }

  class_getter title_zh_fs : ValueMap { load_value_map("title_zh") }
  class_getter title_zh_ts : TokenMap { load_token_map("title_zh_ts") }

  class_getter title_hv_fs : ValueMap { load_value_map("title_hv") }
  class_getter title_hv_ts : TokenMap { load_token_map("title_hv_ts") }

  class_getter title_vi_fs : ValueMap { load_value_map("title_vi") }
  class_getter title_vi_ts : TokenMap { load_token_map("title_vi_ts") }

  class_getter author_zh_fs : ValueMap { load_value_map("author_zh") }
  class_getter author_zh_ts : TokenMap { load_token_map("author_zh_ts") }

  class_getter author_vi_fs : ValueMap { load_value_map("author_vi") }
  class_getter author_vi_ts : TokenMap { load_token_map("author_vi_ts") }

  class_getter genres_vi_fs : ValueMap { load_value_map("genres_vi") }
  class_getter genres_vi_ts : TokenMap { load_token_map("genres_vi_ts") }

  class_getter intro_zh_fs : ValueMap { load_value_map("intro_zh") }
  class_getter intro_vi_fs : ValueMap { load_value_map("intro_vi") }

  class_getter shield_fs : ValueMap { load_value_map("shield") }
  class_getter status_fs : ValueMap { load_value_map("status") }

  class_getter update_fs : OrderMap { load_order_map("update") }
  class_getter access_fs : OrderMap { load_order_map("access") }

  class_getter words_fs : ValueMap { load_value_map("words") }
  class_getter crits_fs : ValueMap { load_value_map("crits") }

  class_getter voters_fs : OrderMap { load_order_map("voters") }
  class_getter rating_fs : OrderMap { load_order_map("rating") }
  class_getter weight_fs : OrderMap { load_order_map("weight") }

  class_getter cover_name_fs : ValueMap { load_value_map("cover_name") }
  class_getter yousuu_bid_fs : ValueMap { load_value_map("yousuu_bid") }
  class_getter origin_url_fs : ValueMap { load_value_map("origin_url") }

  class_getter seeds_fs : TokenMap { load_token_map("seeds") }

  # class_getter seed_top : ValueMap { load_value_map("seed_top") }

  macro def_prop(field, type = :value)
    def get_{{field}}(bhash : String)
      {{field}}_fs.get_value(bhash)
    end

    def set_{{field}}(bhash : String, input, cache : Bool = false) : Nil
      mtime = cache ? TimeUtils.mtime : 0
      {{field}}_fs.upsert!(bhash, input.to_s, mtime: mtime)

      {% if type == :token %}
        {{field}}_ts.upsert!(bhash, TextUtil.tokenize(input), mtime: mtime)
      {% end %}

      return unless cache && (info = INFOS[bhash]?)
      info.{{field}} = input
    end
  end

  def_prop title_zh, :token
  def_prop title_hv, :token
  def_prop title_vi, :token

  def_prop author_zh, :token
  def_prop author_vi, :token

  def_prop genre_vi, :token
  def_prop genre_vi, :token

  def_prop cover_name, :value
  def_prop yousuu_bid, :value
  def_prop origin_url, :value

  def_prop status, :value
  def_prop shield, :value

  def_prop update, :order
  def_prop access, :order

  def_prop weight, :order
  def_prop rating, :value
  def_prop voters, :value

  INFOS = {} of String => Info

  def find_by_hash(bhash : String)
    info = Info.new(bhash)

    {% for ivar in Info.instance_vars %}
      {% if ivar.stringify != "bhash" %}
        info.{{ivar}} = {{ivar}}_fs.get_value(bhash) || ""
      {% end %}
    {% end %}

    info
  end

  def find_by_slug(bslug : String)
    return nil unless bhash = bhash_fs.get_value(bslug)
    find_by_hash(bhash)
  end

  def each_hash(order : String = "",
                title : String = "", author : String = "",
                genre : String = "", seed : String = "") : Void
    unless title.empty?
      bhash_map = filter_by_title(title)
      return if bhash_map.empty?
    end

    unless author.empty?
      bhash_map = filter_by_author(author, bhash_map)
      return if bhash_map.empty?
    end

    unless genre.empty?
      bhash_map = filter_by_genre(genre, bhash_map)
      return if bhash_map.empty?
    end

    unless seed.empty?
      bhash_map = filter_by_seed(seed, bhash_map)
      return if bhash_map.empty?
    end

    order_map = map_order_fs(order)

    if bhash_map && bhash_map.size < 1000
      bhash_map.keys.map { |bhash| {bhash, order_map.get_value(bhash) || 0} }
        .sort_by { |(_, val)| -val }
        .each { |(bhash, _)| yield bhash }
    else
      order_map.reverse_each do |bhash, _|
        next if bhash_map && !bhash_map.has_key?(bhash)
        yield bhash
      end
    end
  end

  def filter_by_title(title : String, prevs : TokenMap::Index? = nil)
    query = TextUtil.tokenize(title)

    output =
      if title =~ /\p{Han}/
        title_zh_ts.search(query)
      else
        title_hv_ts.search(query).merge(title_vi_ts.search(query))
      end

    merge_filters(output, prevs)
  end

  def filter_by_author(author : String, prevs : TokenMap::Index? = nil)
    query = TextUtil.tokenize(author)

    output =
      if author =~ /\p{Han}/
        author_zh_ts.search(query)
      else
        author_vi_ts.search(query)
      end

    merge_filters(output, prevs)
  end

  def filter_by_genre(genre : String, prevs : TokenMap::Index? = nil)
    query = TextUtil.slugify(genre)
    output = genres_vi_ts.search([query])
    merge_filters(output, prevs)
  end

  def filter_by_seed(seed : String, prevs : TokenMap::Index? = nil)
    output = seeds_fs.search(seed.split(" "))
    merge_filters(output, prevs)
  end

  def merge_filters(currs : TokenMap::Index, prevs : TokenMap::Index?) : TokenMap::Index
    return currs unless prevs
    currs.select { |bhash, _| prevs.includes?(bhash).as(Bool) }
  end

  def map_order_fs(type : String)
    case type
    when "access" then access_fs
    when "update" then update_fs
    when "rating" then rating_fs
    else               weight_fs
    end
  end
end
