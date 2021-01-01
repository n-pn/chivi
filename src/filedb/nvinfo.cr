require "json"
require "file_utils"

require "./nvinfo/*"

module CV::Nvinfo
  extend self

  class_getter _index : TokenMap { load_token_map("_index") }

  class_getter btitle : ValueMap { load_value_map("btitle") }
  class_getter btitle_zh : TokenMap { load_token_map("btitle_zh") }
  class_getter btitle_hv : TokenMap { load_token_map("btitle_hv") }
  class_getter btitle_vi : TokenMap { load_token_map("btitle_vi") }

  class_getter bgenre : ValueMap { load_value_map("bgenre") }
  class_getter bgenre_tsv : TokenMap { load_token_map("bgenre") }

  class_getter chseed : TokenMap { load_token_map("chseed") }
  class_getter chsbid : TokenMap { load_token_map("chsbid") }

  class_getter bcover : ValueMap { load_value_map("bcover") }
  class_getter yousuu : ValueMap { load_value_map("yousuu") }
  class_getter origin : ValueMap { load_value_map("origin") }

  class_getter shield : ValueMap { load_value_map("shield") }
  class_getter status : ValueMap { load_value_map("status") }

  class_getter rating : OrderMap { load_order_map("rating") }
  class_getter weight : OrderMap { load_order_map("weight") }

  class_getter access_tz : OrderMap { load_order_map("tz_access") }
  class_getter update_tz : OrderMap { load_order_map("tz_update") }

  macro def_prop(field, type = :value)
    def get_{{field}}(zh_slug : String)
      {{field}}.get(zh_slug)
    end

    def set_{{field}}(zh_slug : String, input) : Nil
      {{field}}.set(zh_slug, input.to_s)

      {% if type == :token %}
        {{field}}_tsv.set(zh_slug, TextUtils.tokenize(input))
      {% end %}
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
    query = SeedUtils.tokenize(title)

    output =
      if title =~ /\p{Han}/
        title_zh_ts.search(query)
      else
        title_hv_ts.search(query).merge(title_vi_ts.search(query))
      end

    merge_filters(output, prevs)
  end

  def filter_by_author(author : String, prevs : TokenMap::Index? = nil)
    query = SeedUtils.tokenize(author)

    output =
      if author =~ /\p{Han}/
        author_zh_ts.search(query)
      else
        author_vi_ts.search(query)
      end

    merge_filters(output, prevs)
  end

  def filter_by_genre(genre : String, prevs : TokenMap::Index? = nil)
    query = SeedUtils.slugify(genre)
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
