require "../engine"
require "../models/*"

class Serials
  def initialize(@dir = "data/txt-out/serials")
    @books = {} of String => VpBook

    @tally = Array(Tuple(String, Float64)).from_json File.read(index_file("tally"))
    @score = Array(Tuple(String, Float64)).from_json File.read(index_file("score"))
    @votes = Array(Tuple(String, Int32)).from_json File.read(index_file("votes"))
    @update = Array(Tuple(String, Int64)).from_json File.read(index_file("update"))
  end

  def [](vi_slug : String)
    get(vi_slug)
  end

  def []=(book : VpBook)
    save(book)
  end

  def get(name : String)
    @books[name] ||= load(name)
  end

  def load(vi_slug : String)
    VpBook.from_json(File.read(serial_file(vi_slug)))
  end

  def serial_file(vi_slug)
    File.join(@dir, "#{vi_slug}.json")
  end

  def index_file(name)
    File.join(@dir, "indexes", "#{name}.json")
  end

  def save(book : VpBook)
    File.write serial_file(book.vi_slug), book.to_pretty_json
    # TODO: recalculate indexes
    @books[book.vi_slug] = book
  end

  def total
    @tally.size
  end

  def list(limit = 20, offset = 0, sort = "updated_at")
    sort_by(sort)[offset, limit].map { |slug, _| get(slug) }
  end

  def sort_by(sort : String = "updated_at")
    case sort
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
