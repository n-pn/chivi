ENV["CV_ENV"] ||= "production"
ENV["MT_DIR"] ||= "var/mt_db"

require "../../src/_data/_data"
require "../../src/mt_ai/data/zv_dict"

CORE = {
  {"essence", 0, 0, "Nền Tảng", "Các từ áp dụng cho tất cả các chế độ dịch như dấu câu, chữ latin, emoji..."},
  {"word_hv", 0, 1, "Hán Việt", "Phiên âm Hán Việt dùng cho dịch nghĩa Hán Việt hoặc dịch từ mới"},
  {"pin_yin", 0, 2, "Phanh Âm", "Sử dụng chữ cái Latinh để thể hiện cách phát âm các chữ Hán trong"},

  {"noun_vi", 0, 11, "Dịch Danh", "Các từ dùng để dịch danh từ mới"},
  {"verb_vi", 0, 12, "Dịch Động", "Các từ dùng để dịch động từ mới"},
  {"adjt_vi", 0, 13, "Dịch Tính", "Các từ dùng để dịch tính từ mời"},

  {"name_hv", 0, 21, "Tên Trung", "Dịch họ tên tiếng Trung bằng Hán Việt"},
  {"name_ja", 0, 22, "Tên Nhật", "Dịch tên riêng từ Trung sang Nhật"},
  {"name_en", 0, 23, "Tên Tây", "Dịch tên riêng từ Trung sang tên Tây"},

  {"regular", 1, 0, "Thông Dụng", "Từ điển nghĩa Trung Việt áp dụng chung cho các nguồn"},
  {"combine", 1, 1, "Trộn Chung", "Từ điển áp dụng khi nguồn truyện không có từ điển riêng"},
  {"suggest", 1, 2, "Gợi Ý Thêm", "Từ điển bổ sung nghĩa cho các cụm từ hiếm gặp"},
}

def add_fixtures
  MT::ZvDict.db.open_tx do |db|
    CORE.each { |core| MT::ZvDict.new(*core).upsert!(db: db) }
  end
end

def add_wn_dicts
  inputs = DB.open(CV_ENV.database_url) do |db|
    query = <<-SQL
    select id as wn_id, btitle_vi as vname
    from wninfos where id > 0 order by id asc
    SQL
    db.query_all(query, as: {Int32, String})
  end

  puts "wn dicts: #{inputs.size}"

  MT::ZvDict.db.open_tx do |db|
    inputs.each do |wn_id, bname|
      MT::ZvDict.init_wn_dict!(wn_id, bname, db: db)
    end
  end
end

def add_up_dicts
  inputs = DB.open(CV_ENV.database_url) do |db|
    query = <<-SQL
    select id as up_id, vname
    from upstems order by id asc
    SQL
    db.query_all(query, as: {Int32, String})
  end

  puts "up dicts: #{inputs.size}"

  MT::ZvDict.db.open_tx do |db|
    inputs.each do |up_db, bname|
      MT::ZvDict.init_up_dict!(up_db, bname, db: db)
    end
  end
end

add_fixtures
add_up_dicts
add_wn_dicts
