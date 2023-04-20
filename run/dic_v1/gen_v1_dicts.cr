require "pg"

require "../../src/cv_env"
require "../../src/mt_v1/data/v1_dict"

# basics = {
#   {0, "combine", "Tổng hợp", "Từ điển tổng hợp dùng cho chế độ dịch nhanh", 1},
#   {-1, "regular", "Thông dụng", "Từ điển chung cho tất cả các bộ truyện", 2},
#   {-2, "essense", "Nền tảng", "Từ điển cơ sở chung cho các chế độ dịch", 3},
#   {-3, "fixture", "Khoá cứng", "Các từ nghĩa cố định dùng trong máy dịch", 3},
# }

# others = {
#   {-10, "hanviet", "Hán việt", "Từ điển phiên âm Hán Việt", 3},
#   {-11, "pin_yin", "Bính âm", "Từ điển bính âm (pinyin)", 3},
#   {-12, "surname", "Họ tiếng Trung", "Từ điển họ phổ biến tiếng Trung", 3},
# }

# cvmtls = {
#   {-20, "fix_nouns", "Sửa danh từ", "Nghĩa của từ khi nó là danh từ", 3},
#   {-21, "fix_verbs", "Sửa động từ", "Nghĩa của từ khi nó là động từ", 3},
#   {-22, "fix_adjts", "Sửa tính từ", "Nghĩa của từ khi nó là tính từ", 3},
#   {-23, "fix_advbs", "Sửa phó từ", "Nghĩa của từ khi nó là phó từ", 3},
#   {-24, "fix_u_zhi", "Sửa sau 之", "Đổi nghĩa của vế phải cụm từ kết hợp bởi 之", 3},
#   {-25, "qt_nouns", "Danh lượng từ", "Lượng từ dành riêng cho danh từ", 3},
#   {-26, "qt_verbs", "Động lượng từ", "Lượng từ dành riêng cho động từ", 3},
#   {-27, "qt_times", "Thời lượng từ", "Lượng từ chỉ thời gian", 3},
#   {-28, "v_dircom", "Bổ ngữ xu hướng", "Nghĩa của từ khi làm bổ ngữ xu hướng", 3},
#   {-29, "v_rescom", "Bổ ngữ kết quả", "Các loại bổ ngữ đứng sau động từ khác", 3},
#   {-30, "v_ditran", "Động từ 2 tân", "Động từ yêu cầu 2 tân ngữ, tân ngữ trước thường chỉ người", 3},
#   {-31, "verb_obj", "Động từ ly hợp", "Cụm động tân có thể tạo thành cấu trúc ly hợp, biểu hiện kỹ năng", 3},
# }

# basics.each { |x| M1::DbDict.new(*x, dtype: 0).save! }
# others.each { |x| M1::DbDict.new(*x, dtype: 1).save! }
# cvmtls.each { |x| M1::DbDict.new(*x, dtype: 2).save! }

dicts = [] of M1::DbDict

select_sql = <<-SQL
  select id::int, bslug, vname from nvinfos where id > 0 order by id asc
SQL

DB.open(CV_ENV.database_url) do |db|
  db.query_each(select_sql) do |rs|
    id, bslug, bname = rs.read(Int32, String, String)
    dicts << M1::DbDict.init_wn_dict(id, bslug, bname)
  end
end

M1::DbDict.repo.begin_tx

dicts.each do |dict|
  puts dict.dname
  dict.save!
end

M1::DbDict.repo.commit_tx
