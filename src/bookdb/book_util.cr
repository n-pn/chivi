require "digest"
require "../lookup/label_map"
require "../lookup/value_set"

module BookUtil
  extend self

  CHARS = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k',
    'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x',
    'y', 'z',
  }

  def gen_ubid(title : String, author : String)
    digest = Digest::SHA1.hexdigest("#{title}--#{author}")
    number = digest[0, 10].to_i64(base: 16)

    String.build do |io|
      8.times do
        io << CHARS[number % 32]
        number //= 32
      end
    end
  end

  BLACKLIST   = ValueSet.load!("blacklist-titles")
  FIX_TITLES  = LabelMap.load!("override/title_zh")
  FIX_AUTHORS = LabelMap.load!("override/author_zh")

  def blacklist?(title : String)
    BLACKLIST.includes?(title)
  end

  def fix_title(title : String)
    title = replace_spaces(title)
    title = remove_trashes(title)
    FIX_TITLES.fetch(title, title)
  end

  def fix_author(author : String, title : String)
    author = replace_spaces(author)
    author = remove_trashes(author)
    author = author.sub(/\s*\.QD$/, "")

    return author unless match = FIX_AUTHORS.fetch(author)

    splits = match.split("¦")
    match_author = splits[0]

    return match_author unless match_title = splits[1]?
    match_title == title ? match_author : author
  end

  private def replace_spaces(input : String)
    input.gsub(/\p{Z}/, " ").strip
  end

  private def remove_trashes(input : String)
    input.sub(/\s*\(.+\)$/, "")
  end

  UNMAPPED_GENRES = ValueSet.load!("unmapped-genres")
  alias Genres = Array(Tuple(String, String))

  def map_genre(genre_zh : String) : Genres
    genre_zh = fix_genre(genre_zh)

    if genre_vi = map_genre_vi(genre_zh)
      return [{genre_zh, genre_vi}]
    end

    output = Genres.new

    unless genres = map_genre_zh(genre_zh)
      UNMAPPED_GENRES.upsert!(genre_zh) if genre_zh != "其他"
    else
      genres.each do |genre|
        output << {genre, map_genre_vi(genre).not_nil!}
      end
    end

    output
  end

  def fix_genre(genre : String)
    return genre if genre.empty? || genre == "轻小说"
    genre.sub(/小说$/, "")
  end

  def map_genre_vi(genre_zh)
    case genre_zh
    when "玄幻"  then "Huyền ảo"
    when "奇幻"  then "Kỳ huyễn"
    when "幻想"  then "Giả tưởng"
    when "魔法"  then "Ma pháp"
    when "历史"  then "Lịch sử"
    when "军事"  then "Quân sự"
    when "都市"  then "Đô thị"
    when "现实"  then "Hiện thực"
    when "职场"  then "Chức trường"
    when "官场"  then "Quan trường"
    when "校园"  then "Vườn trường"
    when "商战"  then "Thương chiến"
    when "仙侠"  then "Tiên hiệp"
    when "修真"  then "Tu chân"
    when "科幻"  then "Khoa viễn"
    when "空间"  then "Không gian"
    when "游戏"  then "Trò chơi"
    when "体育"  then "Thể thao"
    when "竞技"  then "Thi đấu"
    when "悬疑"  then "Huyền nghi"
    when "惊悚"  then "Kinh dị"
    when "灵异"  then "Thần quái"
    when "同人"  then "Đồng nhân"
    when "武侠"  then "Võ hiệp"
    when "耽美"  then "Đam mỹ"
    when "女生"  then "Nữ sinh"
    when "言情"  then "Ngôn tình"
    when "穿越"  then "Xuyên việt"
    when "二次元" then "Nhị thứ nguyên"
    when "轻小说" then "Khinh tiểu thuyết"
    end
  end

  def map_genre_zh(genre_zh)
    case genre_zh
    when "都市言情" then ["都市", "言情"]
    when "科幻空间" then ["科幻", "空间"]
    when "科幻灵异" then ["科幻", "灵异"]
    when "游戏竞技" then ["游戏", "竞技"]
    when "网游竞技" then ["游戏", "竞技"]
    when "武侠仙侠" then ["武侠", "仙侠"]
    when "修真武侠" then ["修真", "武侠"]
    when "历史军事" then ["历史", "军事"]
    when "幻想言情" then ["幻想", "言情"]
    when "悬疑惊悚" then ["悬疑", "惊悚"]
    when "玄幻魔法" then ["幻想", "魔法"]
    when "玄幻奇幻" then ["玄幻", "奇幻"]
    when "奇幻修真" then ["奇幻", "修真"]
    when "架空历史" then ["幻想", "历史"]
    when "官场职场" then ["官场", "职场"]
    when "总裁豪门" then ["都市", "言情"]
    when "耽美纯爱" then ["耽美", "女生"]
    when "青春校园" then ["校园", "都市"]
    when "衍生同人" then ["同人"]
    when "小说同人" then ["同人"]
    when "女生频道" then ["女生"]
    when "悬疑推理" then ["悬疑"]
    when "仙侠奇缘" then ["仙侠"]
    when "经典仙侠" then ["仙侠"]
    when "穿越时空" then ["穿越"]
    when "网游"   then ["游戏"]
    end
  end
end

# puts BookUtil.gen_ubid("aaa", "bbb")
