require "json"
require "colorize"

require "../_utils/unique_ids"

class VpInfo
  include JSON::Serializable

  property uuid = ""
  property slug = ""

  property zh_title = ""
  property vi_title = ""
  property hv_title = ""

  property zh_author = ""
  property vi_author = ""

  property zh_genre = ""
  property vi_genre = ""

  property zh_tags = [] of String
  property vi_tags = [] of String

  property zh_intro = ""
  property vi_intro = ""

  property covers = [] of String

  property votes = 0_i32
  property score = 0_f64
  property tally = 0_f64

  property status = 0_i32
  property shield = 0_i32
  property mftime = 0_i64

  property yousuu = ""
  property origin = ""

  property word_count = 0_i32
  property crit_count = 0_i32

  property cr_anchors = {} of String => String
  property cr_mftimes = {} of String => Int64
  property cr_site_df = ""

  def initialize
  end

  def initialize(@zh_title : String, @zh_author : String, @uuid = "")
    reset_uuid if @uuid.empty?
  end

  def reset_uuid
    @uuid = VpInfo.uuid_for(@zh_title, @zh_author)
  end

  def zh_intro=(intro : String)
    return if intro.empty? || intro == @zh_intro

    @zh_intro = intro.tr("　 ", " ")
      .gsub("&amp;", "&")
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("&nbsp;", " ")
      .gsub(/<br\s*\/?>/, "\n")
      .split(/\s{2,}|\n+/)
      .map(&.strip)
      .reject(&.empty?)
      .join("\n")
    @vi_intro = ""
  end

  def zh_genre=(genre : String)
    genre = fix_tag(genre)
    return if genre.empty? || genre == @zh_genre

    @zh_genre = genre
    @vi_genre = ""
  end

  def zh_tag=(tags : Array(String))
    @zh_tags.clear
    @vi_tags.clear
    add_tags(tags)
  end

  def add_tags(tags : Array(String))
    return if tags.empty?
    tags.each { |tag| add_tag(tag) }
  end

  def add_tag(tag : String)
    return if tag.empty?

    case tag = fix_tag(tag)
    when @zh_genre, @zh_author, @zh_title
      return
    else
      return if @zh_tags.includes?(tag)

      @zh_tags << tag
      @vi_tags << ""
    end
  end

  def fix_tag(tag : String)
    return tag if tag.empty? || tag == "轻小说"
    tag.sub("小说", "")
  end

  def add_cover(cover : String)
    return if cover.empty? || @covers.includes?(cover)
    @covers << cover
  end

  def set_status(status : Int32) : Void
    @status = status if status > @status
  end

  def set_mftime(mftime : Int64) : Void
    @mftime = mftime if mftime > @mftime
  end

  def reset_tally
    @tally = (@votes * @score * 2).round / 2
  end

  def to_s(io : IO)
    to_pretty_json(io)
  end

  # class methods

  DIR = File.join("data", "vp_infos")

  def self.path_for(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def self.uuid_for(title : String, author : String) : String
    Utils.book_uid(title, author)
  end

  def self.load(title : String, author : String) : VpInfo
    uuid = uuid_for(title, author)
    load(uuid) || new(title, author, uuid)
  end

  def self.load(uuid : String) : VpInfo?
    file = path_for(uuid)
    read!(file) if File.exists?(file)
  end

  def self.load!(uuid : String) : VpInfo
    read!(path_for(uuid))
  end

  def self.read!(file : String) : VpInfo
    from_json(File.read(file))
  end

  def self.save!(info : VpInfo) : Void
    # puts "- [BOOK_INFO] #{info.zh_title.colorize(:blue)}--#{info.zh_author.colorize(:blue)} saved"
    File.write(path_for(info.uuid), info.to_pretty_json)
  end

  def self.load_all(reset : Bool = false)
    infos = {} of String => VpInfo
    count = 0

    files = Dir.glob(File.join(DIR, "*.json"))
    files.each do |file|
      uuid = File.basename(file, ".json")
      next if !reset && infos.has_key?(uuid)

      count += 1
      infos[uuid] = read!(file)
    end

    # puts "- [BOOK_INFO] loaded #{count.colorize(:blue)} entries"
    infos
  end
end

module BookRepo
  extend self

  DIR = File.join("data", "indexing")

  def index_path(name : String, ext = ".json")
    File.join(DIR, name + ext)
  end

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

  def index(limit = 20, offset = 0, sort = "update")
    output = [] of VpInfo

    sort_by(sort).reverse_each do |uuid, _|
      if offset > 0
        offset -= 1
      else
        output << VpInfo.load!(uuid)
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

  def update_sort(type : String, info : VpInfo)
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

  def save!(info : VpInfo) : Void
    update_sort("access", info)
    update_sort("update", info)

    @@cached[info.uuid] = info
    VpInfo.save!(info)
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
