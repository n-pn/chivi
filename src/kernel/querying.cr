require "../models/book_info"
require "../_utils/string_utils"

module Querying
  extend self

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
    output = [] of BookInfo

    sort_by(sort).reverse_each do |uuid, _|
      if offset > 0
        offset -= 1
      else
        output << BookInfo.load!(uuid)
        break if output.size == limit
      end
    end

    output
  end

  alias Sorting = Array(Tuple(String, Float64))

  @@sorted = {} of String => Sorting

  def sort_by(sort : String = "update")
    @@sorted[sort] ||= load_sort(sort)
  end

  def load_sort(name)
    puts "- loading sort <#{name.colorize(:blue)}>"
    Sorting.from_json(File.read(index_path(name)))
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
      value = info.votes.to_f
    when "update"
      value = info.mftime.to_f
    else # when "access"
      value = Time.utc.to_unix_ms.to_f
    end

    if index = sort.index { |key, _| uuid == key }
      return if sort[index][1] == value
      sort[index] = {uuid, value}
    else
      sort << {uuid, value}
    end

    puts "- sort type #{type} is changed, updating..."
    @@sorted[type] = sort.sort_by!(&.[1])
    File.write(index_path(type), sort.to_json)
  end

  SORTS = {"access", "update", "score", "votes", "tally"}

  def save!(info : BookInfo) : Void
    update_sort("access", info)
    update_sort("update", info)

    @@cached[info.uuid] = info
    BookInfo.save!(info)
  end

  COUNT_ZH = {"zh_titles", "zh_authors"}
  COUNT_VP = {"vi_titles", "hv_titles", "vi_authors"}

  def glob(query : String = "")
    result = [] of Tuple(String, Float64)

    words = Utils.split_words(query)

    if query =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
      COUNT_ZH.each do |type|
        next unless list = shortest_list(words, type)
        list.each do |uuid, label, tally|
          result << {uuid, tally} if label.includes?(query)
        end
      end
    else
      query = Utils.slugify(query)

      COUNT_VP.each do |type|
        next unless list = shortest_list(words, type)
        list.each do |uuid, label, tally|
          result << {uuid, tally} if label =~ /\b#{query}\b/
        end
      end
    end

    result.uniq.sort_by(&.[1].-).map(&.[0]) # sort result by tally
  end

  alias Counters = Hash(String, Hash(String, Float64))
  @@counters : Counters? = nil

  private def counters : Counters
    @@counter ||= Counters.from_json(File.read(index_path("wordmap")))
  end

  private def shortest_list(words, type)
    return unless counter = counters[type]?

    best_word = words.first
    return nil unless best_size = counter[best_word]?

    words.each do |word|
      return nil unless size = counter[word]?
      if size < best_size
        best_size = size
        best_word = word
      end
    end

    load_wordmap(type, best_word)
  end

  alias Mapping = Tuple(String, String, Float64)
  @@wordmaps = Hash(String, Array(Mapping)).new

  def load_wordmap(type : String, word : String)
    @@wordmaps["#{type}-#{word}"] ||= begin
      file = File.join(DIR, type, "#{word}.txt")
      list = Array(Mapping).new

      if File.exists?(file)
        File.read_lines(file).each do |line|
          uuid, label, tally = line.split("ǁ")
          list << {uuid, label, tally.to_f}
        end
      end

      list
    end
  end
end
