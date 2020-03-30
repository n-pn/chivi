require "../engine"
require "../models/*"

class Serials
  def initialize(@dir = "data/txt-out/")
    @books = {} of String => VpBook

    @tally = Array(Tuple(String, Float64)).from_json File.read(index_file("tally"))
    @score = Array(Tuple(String, Float64)).from_json File.read(index_file("score"))
    @votes = Array(Tuple(String, Int32)).from_json File.read(index_file("votes"))
    @update = Array(Tuple(String, Int64)).from_json File.read(index_file("update"))
  end

  def index_file(name)
    File.join(@dir, "indexes", "#{name}.json")
  end

  def [](vi_slug : String)
    get(vi_slug)
  end

  def []=(book : VpBook)
    save(book)
  end

  def get(vi_slug : String)
    @books[vi_slug] ||= load(vi_slug)
  end

  def load(vi_slug : String)
    file = File.join(@dir, "serials", "#{vi_slug}.json")
    VpBook.from_json(File.read(file))
  end

  def save(book : VpBook)
    file = File.join(@dir, "serials", "#{book.vi_slug}.json")
    File.write file, book.to_pretty_json

    @books[book.vi_slug] = book
    # TODO: recalculate indexes
  end

  def total
    load_dir! if @books.empty?
    @books.size
  end

  def list(limit = 20, offset = 0, sort_by = "updated_at")
    sort(sort_by)[offset, limit].map { |slug, _| get(slug) }
  end

  def sort(sort_by : String = "updated_at")
    case sort_by
    when "tally"
      @tally
    when "^tally"
      @tally.reverse
    when "score"
      @score
    when "^score"
      @score.reverse
    when "votes"
      @votes
    when "^votes"
      @votes.reverse
    when "updated_at"
      @update
    when "^updated_at"
      @update.reverse
    else
      @update
    end
  end
end
