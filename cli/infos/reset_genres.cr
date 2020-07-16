require "../../src/lookup/token_map"
require "../../src/models/book_info"

input = BookInfo.load_all!

# reset content
input.each do |info|
  info.zh_genres.clear
  info.vi_genres.clear
  info.zh_tags.clear
  info.vi_tags.clear

  info.save!
end

# moved to cv_book_info
# def map_genre(genre)
#   case genre
#   when "玄幻"  then "Huyền ảo"
#   when "奇幻"  then "Kỳ huyễn"
#   when "幻想"  then "Giả tưởng"
#   when "魔法"  then "Ma pháp"
#   when "历史"  then "Lịch sử"
#   when "军事"  then "Quân sự"
#   when "都市"  then "Đô thị"
#   when "现实"  then "Hiện thực"
#   when "职场"  then "Chức trường"
#   when "官场"  then "Quan trường"
#   when "校园"  then "Vườn trường"
#   when "商战"  then "Thương chiến"
#   when "仙侠"  then "Tiên hiệp"
#   when "修真"  then "Tu chân"
#   when "科幻"  then "Khoa viễn"
#   when "空间"  then "Không gian"
#   when "游戏"  then "Trò chơi"
#   when "体育"  then "Thể thao"
#   when "竞技"  then "Thi đấu"
#   when "悬疑"  then "Huyền nghi"
#   when "惊悚"  then "Kinh dị"
#   when "灵异"  then "Thần quái"
#   when "同人"  then "Đồng nhân"
#   when "武侠"  then "Võ hiệp"
#   when "耽美"  then "Đam mỹ"
#   when "女生"  then "Nữ sinh"
#   when "言情"  then "Ngôn tình"
#   when "穿越"  then "Xuyên việt"
#   when "二次元" then "Nhị thứ nguyên"
#   when "轻小说" then "Khinh tiểu thuyết"
#   end
# end

# def update(zh, vi, genres)
#   genres.each do |genre|
#     zh << genre
#     vi << map_genre(genre).not_nil!
#   end
# end

# input.values.each_with_index do |info, offset|
#   zh_genres = [] of String
#   vi_genres = [] of String

#   info.zh_genres.each_with_index do |genre_zh, idx|
#     if genre_vi = map_genre(genre_zh)
#       zh_genres << genre_zh
#       vi_genres << genre_vi
#     else
#       case genre_zh
#       when "都市言情"
#         update(zh_genres, vi_genres, ["都市", "言情"])
#       when "科幻空间"
#         update(zh_genres, vi_genres, ["科幻", "空间"])
#       when "科幻灵异"
#         update(zh_genres, vi_genres, ["科幻", "灵异"])
#       when "游戏竞技"
#         update(zh_genres, vi_genres, ["游戏", "竞技"])
#       when "网游竞技"
#         update(zh_genres, vi_genres, ["游戏", "竞技"])
#       when "武侠仙侠"
#         update(zh_genres, vi_genres, ["武侠", "仙侠"])
#       when "修真武侠"
#         update(zh_genres, vi_genres, ["修真", "武侠"])
#       when "历史军事"
#         update(zh_genres, vi_genres, ["历史", "军事"])
#       when "幻想言情"
#         update(zh_genres, vi_genres, ["幻想", "言情"])
#       when "悬疑惊悚"
#         update(zh_genres, vi_genres, ["悬疑", "惊悚"])
#       when "玄幻魔法"
#         update(zh_genres, vi_genres, ["幻想", "魔法"])
#       when "玄幻奇幻"
#         update(zh_genres, vi_genres, ["玄幻", "奇幻"])
#       when "奇幻修真"
#         update(zh_genres, vi_genres, ["奇幻", "修真"])
#       when "架空历史"
#         update(zh_genres, vi_genres, ["幻想", "历史"])
#       when "官场职场"
#         update(zh_genres, vi_genres, ["官场", "职场"])
#       when "总裁豪门"
#         update(zh_genres, vi_genres, ["都市", "言情"])
#       when "衍生同人", "小说同人"
#         update(zh_genres, vi_genres, ["同人"])
#       when "女生频道"
#         update(zh_genres, vi_genres, ["女生"])
#       when "耽美纯爱"
#         update(zh_genres, vi_genres, ["耽美"])
#       when "青春校园"
#         update(zh_genres, vi_genres, ["校园"])
#       when "悬疑推理"
#         update(zh_genres, vi_genres, ["悬疑"])
#       when "仙侠奇缘"
#         update(zh_genres, vi_genres, ["仙侠"])
#       when "经典仙侠"
#         update(zh_genres, vi_genres, ["仙侠"])
#       when "穿越时空"
#         update(zh_genres, vi_genres, ["穿越"])
#       when "网游"
#         update(zh_genres, vi_genres, ["游戏"])
#       when "其他", "综合其他"
#         if info.zh_genres.size < 2
#           zh_genres << "其他"
#           vi_genres << "Loại khác"
#         end
#       else
#         puts "- #{offset + 1} / #{input.size}"
#         puts info.to_json.colorize.cyan
#         puts "All genres: #{info.zh_genres}"
#         puts "Unknown genre: `#{genre_zh}`!"
#         gets
#       end
#     end
#   end

#   if info.zh_genres.empty?
#     zh_genres << "其他"
#     vi_genres << "Loại khác"
#   end

#   info.zh_genres = zh_genres.uniq
#   info.vi_genres = vi_genres.uniq

#   changed = false

#   info.zh_genres.each do |genre|
#     if idx = info.zh_tags.index(genre)
#       info.zh_tags.delete_at(idx)
#       info.vi_tags.delete_at(idx)
#       changed = true
#     end
#   end

#   info.save! if info.changed? || changed
# end
