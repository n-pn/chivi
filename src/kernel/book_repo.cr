require "../models/book_info"
require "../_utils/string_utils"

module BookRepo
  extend self

  alias Index = Array(Tuple(String, Int64 | Float64))

  DIR = File.join("data", "indexing")

  def index_path(name : String, ext = ".json")
    File.join(DIR, name + ext)
  end

  @@cached = {} of String => BookInfo?

  def load(uuid : String)
    @@cached[uuid] ||= BookInfo.load(uuid)
  end

  def find(slug : String)
    @@cached[slug] ||=
      if uuid = mapping[slug]?
        BookInfo.load!(uuid)
      else
        nil
      end
  end

  @@mapping : Hash(String, String)? = nil

  def mapping
    @@mapping ||= Hash(String, String).from_json(File.read(index_path("mapping")))
  end

  def index(limit = 20, offset = 0, sort = "update")
    sort_by(sort)[offset, limit].compact_map { |uuid, _| load(uuid) }
  end

  @@sorted = {} of String => Index

  def sort_by(sort : String = "update")
    @@sorted[sort] ||= load_sort(sort, Index)
  end

  def load_sort(name, klass = Index)
    puts "- loading sort <#{name.colorize(:blue)}>"
    klass.from_json(File.read(index_path(name)))
  end

  def update_sort(type : String, info : BookInfo)
    sort = sort_by(type)
    uuid = info.uuid

    case type
    when "tally"
      value = info.tally
    when "score"
      value = info.score
    when "votes"
      value = info.votes.to_i64
    when "update"
      value = info.mftime
    else
      value = Time.utc.to_unix
    end

    if index = sort.index { |id, _| uuid == id }
      return if sort[index][1] == value
      sort[index] = {uuid, value}
    else
      sort << {uuid, value}
    end

    sort.sort_by!(&.[1])
    File.write(index_path(type), sort.to_json)
  end

  SORTS = {"access", "update", "score", "votes", "tally"}

  def save!(info : BookInfo) : Void
    update_sort("access", info)
    update_sort("update", info)

    @@cached[info.uuid] = info
    BookInfo.save!(info)
  end

  def glob(query : String = "", limit = 10, offset = 0)
    uuids = Set(String).new

    words = Utils.split_words(query)
    words.each do |word|
      array = lookup(word)

      return [] of BookInfo if array.empty?

      if uuids.empty?
        uuids = array
      else
        uuids &= array
      end

      break if uuids.empty?
    end

    uuids.to_a[offset, limit].compact_map { |uuid| load(uuid) }
  end

  def lookup(word : String)
    @@queries[word] ||= begin
      file = File.join(DIR, "queries", "#{word}.txt")
      if File.exists?(file)
        Set.new(File.read_lines(file))
      else
        Set(String).new
      end
    end
  end

  @@queries = Hash(String, Set(String)).new
end
