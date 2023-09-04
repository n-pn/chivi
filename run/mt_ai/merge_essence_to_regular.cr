require "../../src/_util/char_util"
require "../../src/mt_ai/data/mt_defn"

# missing:
# {"向著", "P", "hướng trứ"}, {"联同", "P", "liên đồng"}, {"不单止", "CC", "bất đơn chỉ"}, {"该些", "DT", "cai ta"}, {"之末", "LC", "chi mạt"}, {"艘次", "M", "tao thứ"}, {"驾次", "M", "giá thứ"}, {"组组", "M", "tổ tổ"}, {"畦畦", "M", "huề huề"}, {"Ｉｔａ", "PN", "Ita"}, {"位位", "M", "vị vị"}, {"到了", "P", "đáo liễu"}, {"幅幅", "M", "bức bức"}, {"批批", "M", "phê phê"}, {"较诸", "P", "giác chư"}, {"件件", "M", "kiện kiện"}, {"颗Ｄ", "M", "khoả D"}, {"ＶＳ．", "CC", "VS."}, {"只只", "M", "chích chích"}, {"具具", "M", "cụ cụ"}, {"篇篇", "M", "thiên thiên"}, {"若说", "CS", "nếu nói"}, {"了无", "VE", "Liễu Vô"}, {"堵堵", "M", "đổ đổ"}, {"球球", "M", "Cầu Cầu"}, {"英哩", "M", "anh lý"}, {"群群", "M", "quần quần"}, {"更天", "M", "canh thiên"}, {"只要是", "CS", "chỉ yếu thị"}, {"站站", "M", "trạm trạm"}, {"之为", "P", "chi vi"}, {"幕幕", "M", "mạc mạc"}, {"是为", "VC", "thị vi"}, {"窝蜂", "M", "tổ ong"}, {"部部", "M", "bộ bộ"}]

# MT::MtDefn.db("essence").open_ro do |db|
#   db_path = MT::MtDefn.db_path("essence").sub(".db3", ".tsv")

#   File.open(db_path, "w") do |file|
#     MT::MtDefn.get_all(db: db).each do |term|
#       file.puts({term.zstr, term.cpos, term.vstr, term.pecs}.join('\t'))
#     end
#   end
# end
