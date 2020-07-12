# fix `var/label_maps/seeds/*` info after fix titles and authors

require "../../src/kernel/book_info"
require "../../src/kernel/token_map"

input = BookInfo.load_all!

# # reset content
# input.each_value do |info|
#   info.genres_zh.clear
#   info.genres_vi.clear
#   info.tags_zh.clear
#   info.tags_vi.clear

#   info.save!
# end

def map_genre(genre)
  case genre
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

def update(zh, vi, genres)
  genres.each do |genre|
    zh << genre
    vi << map_genre(genre).not_nil!
  end
end

input.values.each_with_index do |info, offset|
  genres_zh = [] of String
  genres_vi = [] of String

  info.genres_zh.each_with_index do |genre_zh, idx|
    if genre_vi = map_genre(genre_zh)
      genres_zh << genre_zh
      genres_vi << genre_vi
    else
      case genre_zh
      when "都市言情"
        update(genres_zh, genres_vi, ["都市", "言情"])
      when "科幻空间"
        update(genres_zh, genres_vi, ["科幻", "空间"])
      when "科幻灵异"
        update(genres_zh, genres_vi, ["科幻", "灵异"])
      when "游戏竞技"
        update(genres_zh, genres_vi, ["游戏", "竞技"])
      when "网游竞技"
        update(genres_zh, genres_vi, ["游戏", "竞技"])
      when "武侠仙侠"
        update(genres_zh, genres_vi, ["武侠", "仙侠"])
      when "修真武侠"
        update(genres_zh, genres_vi, ["修真", "武侠"])
      when "历史军事"
        update(genres_zh, genres_vi, ["历史", "军事"])
      when "幻想言情"
        update(genres_zh, genres_vi, ["幻想", "言情"])
      when "悬疑惊悚"
        update(genres_zh, genres_vi, ["悬疑", "惊悚"])
      when "玄幻魔法"
        update(genres_zh, genres_vi, ["幻想", "魔法"])
      when "玄幻奇幻"
        update(genres_zh, genres_vi, ["玄幻", "奇幻"])
      when "奇幻修真"
        update(genres_zh, genres_vi, ["奇幻", "修真"])
      when "架空历史"
        update(genres_zh, genres_vi, ["幻想", "历史"])
      when "官场职场"
        update(genres_zh, genres_vi, ["官场", "职场"])
      when "总裁豪门"
        update(genres_zh, genres_vi, ["都市", "言情"])
      when "衍生同人", "小说同人"
        update(genres_zh, genres_vi, ["同人"])
      when "女生频道"
        update(genres_zh, genres_vi, ["女生"])
      when "耽美纯爱"
        update(genres_zh, genres_vi, ["耽美"])
      when "青春校园"
        update(genres_zh, genres_vi, ["校园"])
      when "悬疑推理"
        update(genres_zh, genres_vi, ["悬疑"])
      when "仙侠奇缘"
        update(genres_zh, genres_vi, ["仙侠"])
      when "经典仙侠"
        update(genres_zh, genres_vi, ["仙侠"])
      when "穿越时空"
        update(genres_zh, genres_vi, ["穿越"])
      when "网游"
        update(genres_zh, genres_vi, ["游戏"])
      when "其他", "综合其他"
        if info.genres_zh.size < 2
          genres_zh << "其他"
          genres_vi << "Loại khác"
        end
      else
        puts "- #{offset + 1} / #{input.size}"
        puts info.to_json.colorize.cyan
        puts "All genres: #{info.genres_zh}"
        puts "Unknown genre: `#{genre_zh}`!"
        gets
      end
    end
  end

  if info.genres_zh.empty?
    genres_zh << "其他"
    genres_vi << "Loại khác"
  end

  info.genres_zh = genres_zh.uniq
  info.genres_vi = genres_vi.uniq

  changed = false

  info.genres_zh.each do |genre|
    if idx = info.tags_zh.index(genre)
      info.tags_zh.delete_at(idx)
      info.tags_vi.delete_at(idx)
      changed = true
    end
  end

  info.save! if info.changed? || changed
end
