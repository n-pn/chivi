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
