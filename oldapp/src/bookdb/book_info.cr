require "json"
require "colorize"

require "./models/vp_info"

require "./indexes/BookOrderIndex"

module BookRepo
  extend self

  @@cached = {} of String => VpInfo?

  def load(uuid : String)
    @@cached[uuid] ||= VpInfo.load(uuid)
  end

  def find(slug : String)
    @@cached[slug] ||=
      if uuid = mapping[slug]?
        VpInfo.load!(uuid)
      else
        nil
      end
  end

  @@mapping : Hash(String, String)? = nil

  def mapping
    @@mapping ||= Hash(String, String).from_json(File.read(index_path("mapping")))
  end

  def index(limit = 20, offset = 0, order = "update")
    output = [] of VpInfo

    BookOrderIndex.load!(order).fetch(limit, offset) do |uuid|
      output << VpInfo.load!(uuid)
    end

    output
  end

  def update_order(info : VpInfo, order_type : String) : Void
    case type
    when "tally", "weight"
      value = info.weight
    when "score", "rating"
      value = info.rating
    when "update", "mftime"
      value = info.mftime.to_f
    else # when "access"
      value = Time.utc.to_unix_ms.to_f
    end

    order = BookOrderIndex.load!(order_type)
    order.upsert(info.uuid, info.vi_genre, value, reorder: true)
    order.save! if order.changed?
  end

  def save!(info : VpInfo) : Void
    @@cached[info.uuid] = info
    update_order(info, update)
    info.save!
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
