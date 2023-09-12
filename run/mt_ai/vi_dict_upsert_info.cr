ENV["CV_ENV"] = "production"
require "../../src/_data/_data"
require "../../src/mt_ai/data/vi_dict"

CORE = {
  {"regular", MT::ViDict::Dtype::Core, "Thông Dụng", "Từ điển chung cho tất cả các bộ truyện"},
  {"suggest", MT::ViDict::Dtype::Core, "Gợi Ý", "Tổng hợp nghĩa cho từ gộp từ tất cả các nguồn"},
  {"combine", MT::ViDict::Dtype::Core, "Tổng Hợp", "Từ điển tổng hợp dùng cho dịch nhanh"},
  {"essence", MT::ViDict::Dtype::Core, "Nền Tảng", "Lưu thông tin ngữ pháp cần thiết cho nhiều chế đọ dịch"},
  {"hv_word", MT::ViDict::Dtype::Core, "Hán Việt", "Từ điển phiên âm Hán Việt"},
  {"hv_name", MT::ViDict::Dtype::Core, "Tên Riêng HV", "Phiên âm tên riêng Hán Việt"},
  {"pin_yin", MT::ViDict::Dtype::Core, "Bính Âm", "Từ điển bính âm (pinyin)"},
}

MT::ViDict.db.open_tx do |db|
  CORE.each { |core| MT::ViDict.new(*core).upsert!(db: db) }
end

inputs = DB.open(CV_ENV.database_url) do |db|
  query = <<-SQL
    select id as wn_id, btitle_vi as vname
    from wninfos where id > 0 order by id asc
    SQL
  db.query_all(query, as: {Int32, String})
end

MT::ViDict.db.open_tx do |db|
  inputs.each do |wn_id, bname|
    MT::ViDict.init_book_dict!(wn_id, bname, db: db)
  end
end
