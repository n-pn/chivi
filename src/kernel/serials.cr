require "../engine"
require "../models/*"

class Serials
  alias Index = Array(Tuple(String, Int64 | Float64))

  class Mapping
    include JSON::Serializable

    property title : Array(String)
    property author : Array(String)
  end

  def initialize(@dir = "data/txt-out/serials")
    @books = {} of String => VpBook?

    @sorts = {
      access: Index.from_json(File.read(index_file("update"))),
      update: Index.from_json(File.read(index_file("update"))),
      score:  Index.from_json(File.read(index_file("score"))),
      votes:  Index.from_json(File.read(index_file("votes"))),
      tally:  Index.from_json(File.read(index_file("tally"))),
    }

    @mapping = Hash(String, Mapping).from_json(File.read(index_file("mapping")))
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

  def bump(book : VpBook)
    @sorts[:access].reject!(&.[0].==(book.vi_slug))
    @sorts[:access].unshift({book.vi_slug, book.updated_at})
  end

  def load(vi_slug : String)
    file = serial_file(vi_slug)
    return nil unless File.exists?(file)
    VpBook.from_json(File.read(file))
  end

  def serial_file(vi_slug)
    File.join(@dir, "#{vi_slug}.json")
  end

  def index_file(name)
    File.join(@dir, "indexes", "#{name}.json")
  end

  def save(book : VpBook)
    slug = book.vi_slug
    File.write(serial_file(slug), book.to_pretty_json)

    # TODO: recalculate indexes
    if idx = @sorts[:update].index(&.[0].==(slug))
      @sorts[:update][idx] = {slug, book.updated_at}
      @sorts[:update].sort_by!(&.[1].-)
      File.write(index_file("update"), @sorts[:update].to_pretty_json)
    end

    @books[slug] = book
  end

  def total
    @sorts[:tally].size
  end

  def list(limit = 20, offset = 0, sort = "update")
    sort_by(sort)[offset, limit].map { |slug, _| get(slug) }
  end

  def glob(title : String = "", author : String = "")
    title = CUtil.slugify(title, no_accent: true)
    author = CUtil.slugify(author, no_accent: true)

    res = [] of VpBook

    @mapping.each do |slug, data|
      next unless data.title.find(&.includes?(title))
      next unless data.author.find(&.includes?(author))
      res << get(slug).not_nil!
      break unless res.size < 20
    end

    res
  end

  def sort_by(sort : String = "update")
    case sort
    when "tally"
      @sorts[:tally]
    when "score"
      @sorts[:score]
    when "votes"
      @sorts[:votes]
    when "update"
      @sorts[:update]
    else
      @sorts[:access]
    end
  end
end
