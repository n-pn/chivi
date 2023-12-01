ENV["CV_ENV"] ||= "production"
# ENV["MT_DIR"] ||= "/2tb/app.chivi/var/mt_db"

require "../../src/_data/_data"
require "../../src/mt_ai/data/zv_dict"

CORE = {
  {"essence", 0, 0, "Nền Tảng", "Các từ cơ bản như dấu câu, chữ latin, emoji, phiên âm hán việt..."},
  # {"word_hv", 0, 1, "Hán Việt", "Phiên âm Hán Việt dùng cho dịch nghĩa Hán Việt hoặc dịch từ mới"},
  {"pin_yin", 0, 2, "Phanh Âm", "Sử dụng chữ cái Latinh để thể hiện cách phát âm các chữ Hán trong"},

  {"noun_vi", 0, 11, "Nghĩa Danh", "Các từ dùng để dịch danh từ mới"},
  {"verb_vi", 0, 12, "Nghĩa Động", "Các từ dùng để dịch động từ mới"},
  {"adjt_vi", 0, 13, "Nghĩa Tính", "Các từ dùng để dịch tính từ mới"},

  {"time_vi", 0, 15, "Thời Gian", "Các từ dùng để dịch cụm thời gian"},
  {"nqnt_vi", 0, 16, "Định Lượng", "Các từ dùng để dịch cụm số lượng"},

  {"name_hv", 0, 21, "Tên Trung", "Dịch họ tên tiếng Trung bằng Hán Việt"},
  {"name_ja", 0, 22, "Tên Nhật", "Dịch tên riêng từ Trung sang Nhật"},
  {"name_en", 0, 23, "Tên Tây", "Dịch tên riêng từ Trung sang tên Tây"},

  {"b_title", 0, 41, "Tên Truyện", "Áp dụng riêng khi dịch tên bộ truyện, tên tác phẩm"},
  {"c_title", 0, 42, "Tên Chương", "Áp dụng riêng khi dịch tên chương tiết, tập truyện"},

  {"m_n_pair", 0, 101, "Lượng + Danh", "Dịch song song lượng từ + danh từ"},
  {"m_v_pair", 0, 102, "Lượng + Động", "Dịch song song lượng từ + động từ"},
  {"v_n_pair", 0, 103, "Động + Danh", "Dịch song song động từ + tân ngữ"},
  {"v_v_pair", 0, 104, "Động + Động", "Dịch song song động từ liền kề"},
  {"v_c_pair", 0, 105, "Bổ ngữ + Động", "Dịch song song động từ + bổ ngữ phía sau"},
  {"p_v_pair", 0, 106, "Giới + Động", "Dịch song song giới từ + động từ phía sau"},
  {"d_v_pair", 0, 107, "Trạng + Động", "Dịch song song phó từ + động từ phía sau"},

  {"regular", 1, 0, "Thông Dụng", "Từ điển nghĩa Trung Việt áp dụng chung cho các nguồn"},
  {"combine", 1, 1, "Trộn Chung", "Từ điển áp dụng khi nguồn truyện không có từ điển riêng"},
  {"suggest", 1, 2, "Gợi Ý Thêm", "Từ điển bổ sung nghĩa cho các cụm từ hiếm gặp"},
}

def add_fixtures
  MT::ZvDict.db.open_tx do |db|
    CORE.each do |name, kind, d_id, label, brief|
      dict = MT::ZvDict.find(name, db: db) || MT::ZvDict.new(name, kind, d_id)
      dict.label = label
      dict.brief = brief
      dict.upsert!(db: db)
    end
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

# add_fixtures
add_up_dicts
add_wn_dicts
