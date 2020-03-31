require "./my_util"
require "../../../src/models/vp_book"

class BookSource
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class BookInfo
  include JSON::Serializable

  property _id : Int32
  property title : String?
  property author : String?

  @[JSON::Field(key: "introduction")]
  property intro : String = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?
  property tags : Array(String)
  property cover : String = ""
  property status : Int32 = 0
  property shielded : Bool

  @[JSON::Field(key: "countWord")]
  property word_count : Float64 = 0

  @[JSON::Field(key: "commentCount")]
  property review_count : Int32 = 0

  @[JSON::Field(key: "scorerCount")]
  property votes : Int32
  property score : Float64 = 0.0

  @[JSON::Field(key: "updateAt")]
  property updated_at : Time = Time.utc(2020, 1, 1)

  property _sources : Array(String) = [] of String

  def slug
    "#{title}--#{author}"
  end

  def genre
    category ? category.not_nil![:className] : nil
  end

  def hidden
    shielded ? 2 : 0
  end

  def tally
    (votes * score * 2).round / 2
  end

  FIX_TITLES  = Hash(String, String).from_json(File.read("data/txt-inp/yousuu/fix-titles.json"))
  FIX_AUTHORS = Hash(String, String).from_json(File.read("data/txt-inp/yousuu/fix-authors.json"))

  alias Data = NamedTuple(bookInfo: BookInfo, bookSource: Array(BookSource))

  def self.from_json_file(data : String)
    json = NamedTuple(data: Data).from_json(data)

    info = json[:data][:bookInfo]
    info._sources = json[:data][:bookSource].map(&.link)

    if title = FIX_TITLES[info.title || ""]?
      info.title = title
    end

    if author = info.author
      if fixed_author = FIX_AUTHORS[info.title || ""]?
        info.author = fixed_author
      else
        info.author = author.sub(".QD", "").strip
      end
    end

    info
  end
end

class MyBook < VpBook
  def initialize(books : Array(BookInfo))
    books = books.sort_by { |x| {x.hidden, -x.updated_at.to_unix_ms} }
    first = books.first

    @zh_title = first.title.as(String)
    @zh_author = first.author.as(String)
    @zh_slug = first.slug.as(String)
    @hidden = first.hidden

    @word_count = first.word_count.round.to_i
    @review_count = first.review_count
    if first.updated_at > Time.utc
      @updated_at = Time.utc(2010, 1, 1).to_unix_ms
    else
      @updated_at = first.updated_at.to_unix_ms
    end

    books.each do |book|
      # next if book.hidden > 0
      @zh_intro = book.intro if @zh_intro.empty?

      if genre = book.genre
        if @zh_genre.empty?
          @zh_genre = genre
        else
          @zh_tags << genre
        end
      end

      if cover = book.cover
        @covers << cover if cover.starts_with?("http")
      end

      @votes += book.votes
      @tally += book.tally

      @yousuu_bids << book._id
      @source_urls.concat book._sources
    end

    @covers.uniq!
    @source_urls.uniq!

    if @votes > 0
      @score = (@tally * 10 / @votes).round / 10
    else
      @score = 0.0
    end
  end

  def initialize(input : CrInfo::Serial, @votes, @score, @word_count = 0)
    @zh_slug = "#{input.title}--#{input.author}"

    @zh_title = input.title
    @zh_author = input.author

    @zh_intro = input.intro || ""
    @zh_genre = input.genre

    @covers = [input.cover]
    @status = 0
    @hidden = 1

    @tally = (@votes * @score * 2).round / 2

    @word_count = word_count
    @chap_count = input.chap_count
    @updated_at = input.updated_at
  end

  def translate!
    @vi_title = map_title(@zh_title)
    @vi_author = CUtil.titlecase(MyUtil.hanviet(@zh_author))

    @vi_slug = pick_slug(@vi_title, @vi_author)

    format_intro!
    @vi_intro = @zh_intro.split("\n").map { |x| MyUtil.translate(x) }.join("\n")

    @vi_genre, move_to_tag = map_genre(@zh_genre)
    @zh_tags << @zh_genre if move_to_tag

    clean_tags!
    @vi_tags = @zh_tags.map { |x| MyUtil.translate(x) }
  end

  TITLES_MAP = Hash(String, Array(String)).from_json(File.read("data/txt-inp/titles-map.json"))

  def map_title(zh_title)
    if titles = TITLES_MAP[zh_title]?
      return titles[0]
    else
      CUtil.capitalize(MyUtil.hanviet(zh_title))
    end
  end

  GENRES_MAP = Hash(String, Tuple(String, Bool)).from_json File.read("data/txt-inp/genres-map.json")

  def map_genre(genre : String?)
    GENRES_MAP.fetch(genre || "", {"Loại khác", false})
  end

  USED_SLUGS = Set(String).new

  def pick_slug(vi_title, vi_author)
    title_slug = CUtil.slugify(vi_title, no_accent: true)
    author_slug = CUtil.slugify(vi_author, no_accent: true)
    full_slug = "#{title_slug}--#{author_slug}"

    if USED_SLUGS.includes?(title_slug) || title_slug.size < 5
      output = full_slug
    else
      output = title_slug
    end

    raise "ERROR!!!!" if USED_SLUGS.includes?(output)

    USED_SLUGS << output
    output
  end
end
