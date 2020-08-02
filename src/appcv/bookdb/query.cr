require "../../utils/text_util"
require "../lookup/token_map"
require "../lookup/order_map"
require "../models/book_info"

# TODO: change class to module?
require "json"

class BookDB::Query
  struct Opts
    include JSON::Serializable

    getter :query, :type, :genre, :order, :limit, :offset, :anchor

    def initialize(@query = "", @type = :fuzzy, @genre = "", @order = :weight, @limit = 24, @offset = 0, @anchor = "")
    end

    def query?
      !@query.empty?
    end

    def genre?
      !@genre.empty?
    end
  end

  class_getter book_count : Int32 { OrderMap.book_weight.size }

  def self.fetch!(opts : Opts)
    query = new

    query.filter_query(opts.query, opts.type) if opts.query?
    query.filter_genre(opts.genre) if opts.genre?

    infos = query.fetch!(opts.order, opts.limit, opts.offset, opts.anchor)
    total = query.filtered ? query.ubids.size : book_count
    {infos, total}
  end

  getter ubids = Set(String).new

  getter filtered = false
  getter no_match = false

  def filter_genre(genre : String) : Void
    return if @no_match

    genre = TextUtil.slugify(genre)
    unless ubids = TokenMap.vi_genres.keys(genre)
      @no_match = true
    else
      @ubids = @filtered ? @ubids & ubids : ubids
      @no_match = @ubids.empty?
    end

    @filtered = true
  end

  # query types: :title, :author or :fuzzy (both :title and :author)
  def filter_query(query : String, type = :fuzzy) : Void
    return if @no_match
    @filtered = true

    is_hanzi = /\p{Han}/.match(query)
    tokens = TextUtil.tokenize(query)

    if type == :fuzzy || type == :title
      if is_hanzi
        @ubids.concat TokenMap.zh_title.search(tokens)
      else
        @ubids.concat TokenMap.vi_title.search(tokens)
        @ubids.concat TokenMap.hv_title.search(tokens)
      end
    end

    if type == :fuzzy || type == :author
      if is_hanzi
        @ubids.concat TokenMap.zh_author.search(tokens)
      else
        @ubids.concat TokenMap.vi_author.search(tokens)
      end
    end

    @no_match = @ubids.empty?
  end

  def fetch!(sort : Symbol, limit = 24, offset = 0, anchor = "")
    output = [] of BookInfo
    return output if @no_match

    sorted = order_map(sort)

    unless @filtered && @ubids.size < 1000
      return scan_sorted(sorted, limit, offset, anchor)
    end

    sorted_ubids = @ubids.to_a.sort_by do |ubid|
      -(sorted.value(ubid) || 0_i64)
    end

    sorted_ubids[offset, limit].each do |ubid|
      output << BookInfo.get!(ubid)
    end

    output
  end

  def scan_sorted(sorted : OrderMap, limit = 24, offset = 0, anchor = "")
    output = [] of BookInfo

    cursor = sorted.fetch(anchor) || seek_cursor(sorted, offset)
    return output unless cursor

    sorted.each(cursor) do |node|
      next unless match?(node.key)
      output << BookInfo.get!(node.key)
      break if output.size >= limit
    end

    output
  end

  def order_map(sort : Symbol)
    case sort
    when :access then OrderMap.book_access
    when :update then OrderMap.book_update
    when :rating then OrderMap.book_rating
    when :weight then OrderMap.book_weight
    else              OrderMap.book_weight
    end
  end

  def seek_cursor(sorted : OrderMap, offset = 0)
    return sorted.first if offset == 0

    sorted.each do |node|
      next unless match?(node.key)
      offset -= 1
      return node if offset == 0
    end

    nil
  end

  def match?(ubid : String)
    !@filtered || @ubids.includes?(ubid)
  end
end
