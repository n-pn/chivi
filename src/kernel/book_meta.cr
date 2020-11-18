require "json"
require "file_utils"
require "../filedb/*"
require "../_utils/text_util"

module BookMeta
  class Info
    include JSON::Serializable

    property bhash = ""
    property bslug = ""

    property title_zh = ""
    property title_hv = ""
    property title_vi = ""

    property author_zh = ""
    property author_vi = ""

    property genre_vi = ""
    property intro_vi = ""

    property cover = ""
    property state : Int32 = 0
    property mtime : Int32 = 0

    property voters : Int32 = 0
    property rating : Int32 = 0
    property weight : Int32 = 0

    def initialize(@bhash)
    end

    macro set_int_field(field)
      def {{field}}=(value : String)
        @{{field}} = value.to_i? || 0
      end
    end

    set_int_field state
    set_int_field mtime

    set_int_field voters
    set_int_field rating
    set_int_field weight
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

  class_getter bhash_map : ValueMap { load_value_map("bhash") }
  class_getter bslug_map : ValueMap { load_value_map("bslug") }

  class_getter title_zh_map : ValueMap { load_value_map("title_zh") }
  class_getter title_zh_tks : TokenMap { load_token_map("title_zh_qs") }

  class_getter title_hv_map : ValueMap { load_value_map("title_hv") }
  class_getter title_hv_tks : TokenMap { load_token_map("title_hv_qs") }

  class_getter title_vi_map : ValueMap { load_value_map("title_vi") }
  class_getter title_vi_tks : TokenMap { load_token_map("title_vi_qs") }

  class_getter author_zh_map : ValueMap { load_value_map("author_zh") }
  class_getter author_zh_tks : TokenMap { load_token_map("author_zh_qs") }

  class_getter author_vi_map : ValueMap { load_value_map("author_vi") }
  class_getter author_vi_tks : TokenMap { load_token_map("author_vi_qs") }

  class_getter genre_vi_map : ValueMap { load_value_map("genre_vi") }
  class_getter genre_vi_tks : TokenMap { load_token_map("genre_vi_qs") }

  class_getter intro_zh_map : ValueMap { load_value_map("intro_zh") }
  class_getter intro_vi_map : ValueMap { load_value_map("intro_vi") }

  class_getter cover_map : ValueMap { load_value_map("cover") }
  class_getter state_map : ValueMap { load_value_map("state") }
  class_getter mtime_map : ValueMap { load_value_map("mtime") }

  class_getter words_map : ValueMap { load_value_map("words") }
  class_getter crits_map : ValueMap { load_value_map("crits") }

  class_getter voters_map : ValueMap { load_value_map("voters") }
  class_getter rating_map : ValueMap { load_value_map("rating") }
  class_getter weight_map : OrderMap { load_order_map("weight") }

  class_getter yousuu_map : ValueMap { load_value_map("yousuu") }
  class_getter origin_map : ValueMap { load_value_map("origin") }

  class_getter seeds_map : TokenMap { load_token_map("seeds") }
  # class_getter seed_top : ValueMap { load_value_map("seed_top") }

  INFOS = {} of String => Info

  def get_info(bhash : String)
    INFOS[bhash] ||= begin
      info = Info.new(bhash)

      {% for ivar in Info.instance_vars %}
        {% if ivar.stringify != "bhash" %}
          info.{{ivar}} = {{ivar}}_map.get_value(bhash) || ""
        {% end %}
      {% end %}

      info
    end
  end

  macro def_prop(field, type = :value)
    def get_{{field}}(bhash : String)
      {{field}}_map.get_value(bhash)
    end

    def set_{{field}}(bhash : String, input, cache : Bool = false) : Nil
      mtime = cache ? TimeUtils.mtime : 0
      {{field}}_map.upsert!(bhash, input.to_s, mtime: mtime)

      {% if type == :token %}
        {{field}}_tks.upsert!(bhash, TextUtil.tokenize(input), mtime: mtime)
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

  def_prop cover, :value
  def_prop state, :value
  def_prop mtime, :value
end

# BookMeta.set_title_zh("1", "a")
# BookMeta.set_genre_vi("1", "x")

# BookMeta.set_mtime("1", 10)
# puts BookMeta.get_mtime("1")

# puts BookMeta.get_info("1").to_pretty_json
