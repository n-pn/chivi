require "json"
require "colorize"

require "./book_info"
require "../common/text_util"

require "../lookup/label_map"
require "../lookup/order_map"
require "../lookup/token_map"

module BookRepo
  class Query
    include JSON::Serializable
    getter :query, :type, :genre, :order, :limit, :offset, :cursor

    def initialize(@query = "", @type = :fuzzy, @genre = "", @order = "weight", @offset = 0, @limit = 24, @cursor = "")
    end
  end

  extend self

  delegate get, to: BookInfo
  delegate get!, to: BookInfo

  def find(slug : String)
    return unless ubid = LabelMap.mapping.fetch(slug)
    BookInfo.get(ubid)
  end

  # query types: :fuzzy, :title, :author
  def find_by_query(query : String, type = :fuzzy)
    tokens = TextUtil.tokenize(query)
    output = Set(String).new

    is_hanzi = query =~ /\p{Han}/

    if type == :fuzzy || type == :title
      if is_hanzi
        output.concat TokenMap.title_zh.search(tokens)
      else
        output.concat TokenMap.title_vi.search(tokens)
        output.concat TokenMap.title_hv.search(tokens)
      end
    end

    if type == :fuzzy || type == :author
      if is_hanzi
        output.concat TokenMap.author_zh.search(tokens)
      else
        output.concat TokenMap.author_vi.search(tokens)
      end
    end

    output
  end

  def find_by_genre(genre : String)
    genre = TextUtil.slugify(genre)
    TokenMap.genres_vi.keys(genre) || Set(String).new
  end

  def order_by(order : String)
    case order
    when "access" then OrderMap.access
    when "update" then OrderMap.update
    when "rating" then OrderMap.rating
    when "weight" then OrderMap.weight
    else               OrderMap.weight
    end
  end

  def search(opts : Query)
    infos = [] of BookInfo

    if !opts.query.empty?
      ubids = find_by_query(opts.query, opts.type)
      ubids &= find_by_genre(opts.genre) unless opts.genre.empty?
      return infos if ubids.empty?
    elsif !opts.genre.empty?
      ubids = find_by_genre(opts.genre)
      return infos if ubids.empty?
    end

    orders = order_by(opts.order)
    offset = opts.offset

    unless node = orders.fetch(opts.cursor)
      node = orders.first

      while offset > 0
        break unless node = node.right
        next if ubids && !ubids.includes?(node.key)
        offset -= 1
      end

      return infos unless node
    end

    orders.each(node) do |item|
      next if ubids && !ubids.includes?(item.key)
      infos << BookInfo.get!(item.key)
      break unless infos.size < opts.limit
    end

    infos
  end

  def upsert!(source : YsSerial)
  end

  def upsert!(source : SeedInfo)
  end

  def update_order!(ubid : String, type = :access, value : Int64 = 0)
    ORDERS[type].upsert!(ubid, value)
  end

  def update_token!(ubid : String, type = :genres_vi, vals = [] of String)
    TOKENS[type].upsert!(ubid, vals)
  end
end
