require "json"
require "colorize"

require "../models/book_info"
require "../models/book_crit"

require "../lookup/label_map"
require "../lookup/order_map"
require "../lookup/token_map"

require "../_utils/text_utils"

module BookRepo
  extend self

  delegate get, to: BookInfo

  def find(slug : String)
    return unless uuid = LabelMap.preload!("slug--ubid").fetch(slug)
    get(uuid)
  end

  def list_by_order(type = "access", limit = 24, offset = 0, cursor = "")
    infos = [] of BookInfo
    order_map = OrderMap.preload!("ubid--#{type}")

    unless node = order_map.fetch(cursor)
      node = order_map.first

      while offset > 0
        break unless node = node.right
        offset -= 1
      end

      return infos unless node
    end

    order_map.each(node.not_nil!) do |item|
      infos << BookInfo.get!(item.key)
      break unless infos.size < limit
    end

    infos
  end

  def list_by_token(type, list : Array(String), limit = 12, offset = 0)
    token_map = TokenMap.preload!("ubid--#{type}")
    token_map.fuzzy_search(list)[0, 12].map { |ubid| BookInfo.get!(ubid) }
    # uuids =
  end

  # @@cached = {} of String => BookInfo?

  # def load(ubid : String)
  #   @@cached[ubid] ||= BookInfo.load(ubid)
  # end

  # def find(slug : String)
  #   @@cached[slug] ||=
  #     if ubid = mapping[slug]?
  #       BookInfo.load!(ubid)
  #     else
  #       nil
  #     end
  # end

  # def index(limit = 20, offset = 0, order = "update")
  #   output = [] of BookInfo

  #   BookOrderIndex.load!(order).fetch(limit, offset) do |ubid|
  #     output << BookInfo.load!(ubid)
  #   end

  #   output
  # end

  # def update_order(info : BookInfo, order_type : String) : Void
  #   case type
  #   when "tally", "weight"
  #     value = info.weight
  #   when "score", "rating"
  #     value = info.rating
  #   when "update", "mftime"
  #     value = info.mftime.to_f
  #   else # when "access"
  #     value = Time.utc.to_unix_ms.to_f
  #   end

  #   order = BookOrderIndex.load!(order_type)
  #   order.upsert(info.ubid, info.vi_genre, value, reorder: true)
  #   order.save! if order.changed?
  # end

  # COUNT_ZH = {"zh_titles", "zh_authors"}
  # COUNT_VP = {"vi_titles", "hv_titles", "vi_authors"}

  # def glob(query : String = "")
  #   result = [] of Tuple(String, Float64)

  #   words = Utils.split_words(query)

  #   if query =~ /[\p{Han}\p{Hiragana}\p{Katakana}]/
  #     COUNT_ZH.each do |type|
  #       next unless list = shortest_list(words, type)
  #       list.each do |ubid, label, tally|
  #         result << {ubid, tally} if label.includes?(query)
  #       end
  #     end
  #   else
  #     query = Utils.slugify(query)

  #     COUNT_VP.each do |type|
  #       next unless list = shortest_list(words, type)
  #       list.each do |ubid, label, tally|
  #         result << {ubid, tally} if label =~ /\b#{query}\b/
  #       end
  #     end
  #   end

  #   result.uniq.sort_by(&.[1].-).map(&.[0]) # sort result by tally
  # end

  # alias Counters = Hash(String, Hash(String, Float64))
  # @@counters : Counters? = nil

  # private def counters : Counters
  #   @@counter ||= Counters.from_json(File.read(index_path("wordmap")))
  # end

  # private def shortest_list(words, type)
  #   return unless counter = counters[type]?

  #   best_word = words.first
  #   return nil unless best_size = counter[best_word]?

  #   words.each do |word|
  #     return nil unless size = counter[word]?
  #     if size < best_size
  #       best_size = size
  #       best_word = word
  #     end
  #   end

  #   load_wordmap(type, best_word)
  # end

  # alias Mapping = Tuple(String, String, Float64)
  # @@wordmaps = Hash(String, Array(Mapping)).new

  # def load_wordmap(type : String, word : String)
  #   @@wordmaps["#{type}-#{word}"] ||= begin
  #     file = File.join(DIR, type, "#{word}.txt")
  #     list = Array(Mapping).new

  #     if File.exists?(file)
  #       File.read_lines(file).each do |line|
  #         ubid, label, tally = line.split("ǁ")
  #         list << {ubid, label, tally.to_f}
  #       end
  #     end

  #     list
  #   end
  # end
end

puts BookRepo.get("4avvz9sx").try(&.title_vi)
puts BookRepo.get("gbzfa3em").try(&.title_vi)
puts BookRepo.find("nhat-quyen-tay-lai").try(&.title_vi)
BookRepo.list_by_order("weight", offset: 30000, cursor: "s0fvndb7").each do |info|
  puts [info.ubid, info.title_vi, info.author_vi]
end

BookRepo.list_by_token("author_vi", Utils.split_words("Cơ Xoa")).each do |info|
  puts [info.ubid, info.title_vi, info.title_zh]
  # puts info
end

BookRepo.list_by_token("genres_vi", [Utils.slugify("Huyen ao")]).each do |info|
  puts [info.ubid, info.title_vi, info.title_zh]
  # puts info
end
