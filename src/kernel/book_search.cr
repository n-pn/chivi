require "../common/text_util"
require "../lookup/token_map"
require "../lookup/order_map"
require "../bookdb/book_info"

# TODO: rewrite
class BookSearch
  struct Opts
    getter :query, :type, :genre, :order, :limit, :offset, :anchor

    def initialize(@query = "", @type = :fuzzy, @genre = "", @order = :weight, @limit = 24, @offset = 0, @anchor = "")
    end

    def filter_query?
      !@query.empty?
    end

    def filter_genre?
      !@genre.empty?
    end
  end

  def self.fetch!(opts : Opts)
    list = new

    list.filter_query(opts.query, opts.type) if opts.filter_query?
    list.filter_genre(opts.genre) if opts.filter_genre?

    list.fetch!(opts.order, opts.limit, opts.offset, opts.anchor)
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
    when :access then OrderMap.access
    when :update then OrderMap.update
    when :rating then OrderMap.rating
    when :weight then OrderMap.weight
    else              OrderMap.weight
    end
  end

  def seek_cursor(sorted : OrderMap, offset = 0)
    sorted.each do |node|
      next unless match?(node.key)
      return node if offset == 0
      offset -= 1
    end

    nil
  end

  def match?(ubid : String)
    !@filtered || @ubids.includes?(ubid)
  end
end
