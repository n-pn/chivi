require "colorize"

require "./models/ys_info"
require "./models/zh_info"
require "./models/zh_stat"

class YousuuInfo
  def self.load!(file : String)
    text = File.read(file)

    return nil if text.includes?("未找到该图书")
    return new(text) if text.includes?("{\"success\":true,")

    puts "- [#{file}] malformed!".colorize(:red)
    File.delete(file)
    nil
  end

  getter ys_info : YsInfo

  alias Data = NamedTuple(bookInfo: YsInfo, bookSource: Array(Source))

  def initialize(json : String)
    data = NamedTuple(data: Data).from_json(json)
    @ys_info = data[:data][:bookInfo]
    @zh_info = ZhInfo.new("yousuu", @ys_info._id.to_s)
    @zh_stat = ZhStat.new
  end

  def get_info!
    get_title! if @zh_info.title.empty?
    get_author! if @zh_info.author.empty?
    get_intro! if @zh_info.intro.empty?
    get_cover! if @zh_info.cover.empty?
    get_genre! if @zh_info.genre.empty?
    get_tags! if @zh_info.tags.empty?
    get_state! if @zh_info.state == 0
    get_mtime! if @zh_info.mtime == 0

    @zh_info
  end

  DIR = "src/crawls/fixes"
  MAP = Hash(String, String)

  TITLES  = MAP.from_json(File.read("#{DIR}/fix-titles.json"))
  AUTHORS = MAP.from_json(File.read("#{DIR}/fix-authors.json"))

  def get_title!
    title = @ys_info.title || ""
    @zh_info.title = TITLES.fetch(title, title)
  end

  def get_author!
    author = @ys_info.author || ""
    @zh_info.author = AUTHORS.fetch(author, author)
  end

  def get_intro!
    @zh_info.intro = @ys_info.intro.tr("　 ", " ")
      .gsub("&lt;", "<")
      .gsub("&gt;", ">")
      .gsub("<br>", "\n")
      .gsub("<br/>", "\n")
      .gsub("&nbsp;", " ")
  end

  def get_cover!
    case cover = @ys_info.cover
    when .starts_with?("http://image.qidian.com")
      @zh_info.cover = cover
        .sub("http://image.qidian.com/books", "https://qidian.qpic.cn/qdbimg")
        .sub("/300", "/300.jpg")
    when .starts_with?("http")
      @zh_info.cover = cover
    else
      @zh_info.cover
    end
  end

  def get_genre!
    if genre = @ys_info.category
      @zh_info.genre = genre[:className]
    else
      @zh_info.genre
    end
  end

  def get_tags!
    @zh_info.tags = @ys_info.tags.map(&.split("-")).flatten.reject do |tag|
      tag == @zh_info.genre || tag == @zh_info.title || tag == @zh_info.author
    end
  end

  def get_state!
    @zh_info.state = @ys_info.status
  end

  def get_mtime!
    @zh_info.mtime = @ys_info.updated_at.to_unix_ms
  end

  def get_stat!
    @zh_stat.title = get_title!
    @zh_stat.author = get_author!

    @zh_stat.votes = @ys_info.votes
    @zh_stat.score = (@ys_info.score * 10).round / 10
    @zh_stat.tally = (@zh_stat.votes * @zh_stat.score * 2).round / 2

    @zh_stat.status = @ys_info.status
    @zh_stat.shield = @ys_info.shielded ? 2 : 0

    @zh_stat.word_count = @ys_info.word_count.round.to_i
    @zh_stat.crit_count = @ys_info.crit_count

    @zh_stat
  end
end
