require "../engine"
require "../models/*"

class Serials
  def initialize(@dir = "data/txt-out/serials/", preload = true)
    @books = {} of String => VpBook
    @sorts = {} of String => Array(VpBook)

    load_dir! if preload
  end

  def load_dir!
    files = Dir.glob(File.join(@dir, "*.json"))
    files.each do |file|
      name = File.basename(file, ".json")
      @books[name] = load(name)
    end
  end

  def [](name : String)
    get(name)
  end

  def []=(book : VpBook)
    save(book)
  end

  def get(name : String)
    @books[name] ||= load(name)
  end

  def load(name : String)
    file = File.join(@dir, "#{name}.json")
    VpBook.from_json(File.read(file))
  end

  def save(book : VpBook)
    file = File.join(@dir, "#{book.vi_slug}.json")
    File.write file, book.to_pretty_json

    @books[book.vi_slug] = book
    # TODO: recalculate indexes
  end

  def sort(sort_by : String = "updated_at")
    load_dir! if @books.empty?
    books = @books.values

    case sort_by
    when "tally"
      books.sort_by(&.tally.-)
    when "^tally"
      books.sort_by(&.tally)
    when "score"
      books.sort_by(&.score.-)
    when "^score"
      books.sort_by(&.score)
    when "votes"
      books.sort_by(&.votes.-)
    when "^votes"
      books.sort_by(&.votes)
    when "updated_at"
      books.sort_by(&.updated_at.-)
    when "^updated_at"
      books.sort_by(&.updated_at)
    else
      books
    end
  end

  def total
    load_dir! if @books.empty?
    @books.size
  end

  def list(limit = 20, offset = 0, sort_by = "updated_at")
    sort(sort_by)[offset, limit]
  end

  include Enumerable(VpBook)

  def each
    load_dir! if @books.empty?
    @books.each_value do |value|
      yield value
    end
  end
end
