ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"
require "../../src/mt_ai/data/pg_dict"

CORE = {
  {"essence", 0, 1, "Nền Tảng", "Các từ cơ bản như dấu câu, chữ latin, emoji, phiên âm từ đơn Hán Việt..."},
  {"word_hv", 0, 2, "Hán Việt", "Phiên âm các cụm từ Hán Việt đặc biệt có cách phát âm khác với HV đơn"},
  {"pin_yin", 0, 3, "Phanh Âm", "Sử dụng chữ cái Latinh để thể hiện cách phát âm các chữ Hán trong"},

  {"noun_vi", 0, 11, "Nghĩa Danh", "Các từ dùng để dịch danh từ mới"},
  {"verb_vi", 0, 12, "Nghĩa Động", "Các từ dùng để dịch động từ mới"},
  {"adjt_vi", 0, 13, "Nghĩa Tính", "Các từ dùng để dịch tính từ mới"},

  {"time_vi", 0, 15, "Thời Gian", "Các từ dùng để dịch cụm thời gian"},
  {"nqnt_vi", 0, 16, "Định Lượng", "Các từ dùng để dịch cụm số lượng"},

  {"name_hv", 0, 21, "Tên Trung", "Dịch họ tên tiếng Trung bằng Hán Việt"},
  {"name_ja", 0, 22, "Tên Nhật", "Dịch tên riêng từ Trung sang Nhật"},
  {"name_en", 0, 23, "Tên Tây", "Dịch tên riêng từ Trung sang tên Tây"},

  {"b_title", 0, 31, "Tên Truyện", "Áp dụng riêng khi dịch tên bộ truyện, tên tác phẩm"},
  {"c_title", 0, 32, "Tên Chương", "Áp dụng riêng khi dịch tên chương tiết, tập truyện"},

  {"regular", 1, 1, "Thông Dụng", "Từ điển nghĩa Trung Việt áp dụng chung cho các nguồn"},
  {"combine", 1, 2, "Trộn Chung", "Từ điển áp dụng khi nguồn truyện không có từ điển riêng"},
  {"suggest", 1, 3, "Gợi Ý Thêm", "Từ điển bổ sung nghĩa cho các cụm từ hiếm gặp"},

  {"m_n_pair", 1, 21, "Lượng + Danh", "Dịch song song lượng từ + danh từ"},
  {"m_v_pair", 1, 22, "Lượng + Động", "Dịch song song lượng từ + động từ"},
  {"v_n_pair", 1, 23, "Động + Danh", "Dịch song song động từ + tân ngữ"},
  {"v_v_pair", 1, 24, "Động + Động", "Dịch song song động từ liền kề"},
  {"v_c_pair", 1, 25, "Bổ ngữ + Động", "Dịch song song động từ + bổ ngữ phía sau"},
  {"p_v_pair", 1, 26, "Giới + Động", "Dịch song song giới từ + động từ phía sau"},
  {"d_v_pair", 1, 27, "Trạng + Động", "Dịch song song phó từ + động từ phía sau"},
}

def add_fixtures
  saved = MT::PgDict.fetch_all(:wnovel, limit: 999999).to_h { |x| {x.d_id // 10, x} }

  dicts = CORE.map do |name, kind, d_id, label, brief|
    kind = MT::DictKind.new(kind.to_i16)
    dict = MT::PgDict.find(name) || MT::PgDict.new(name, kind, d_id)
    dict.tap(&.set_label(label, brief))
  end

  puts "core dicts: #{dicts.size}"

  MT::PgDict.db.transaction do |db|
    dicts.each(&.upsert!(db: db.connection))
  end
end

def add_wn_dicts
  inputs = DB.open(CV_ENV.database_url) do |db|
    query = <<-SQL
    select id as wn_id, coalesce(nullif(btitle_vi, ''), btitle_hv) as vname
    from wninfos where id > 0 order by id asc
    SQL
    db.query_all(query, as: {Int32, String})
  end

  puts "wn dicts: #{inputs.size}"

  saved = MT::PgDict.fetch_all(:wnovel, limit: 999999).to_h { |x| {x.d_id // 10, x} }

  dicts = inputs.map do |wn_id, bname|
    dict = saved[wn_id]? || MT::PgDict.new("wn#{wn_id}", kind: :wnovel, d_id: wn_id)
    dict.tap(&.set_label(bname))
  end

  dicts.each_slice(2000) do |slice|
    MT::PgDict.db.transaction do |tx|
      slice.each(&.upsert!(db: tx.connection))
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
  saved = MT::PgDict.fetch_all(:userpj, limit: 999999).to_h { |x| {x.d_id // 10, x} }

  dicts = inputs.map do |up_id, bname|
    dict = saved[up_id]? || MT::PgDict.new("up#{up_id}", kind: :userpj, d_id: up_id)
    dict.tap(&.set_label(bname))
  end

  MT::PgDict.db.transaction do |tx|
    dicts.each(&.upsert!(db: tx.connection))
  end
end

# add_fixtures
add_up_dicts
add_wn_dicts
