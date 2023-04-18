# require "sqlite3"
# require "../../src/mtapp/service/btran_api"

# DIC = DB.open("sqlite3:var/dicts/hints/all_terms.dic")

# at_exit { DIC.close }

# def get_input(limit = 100)
#   DIC.query_all "select zh from terms where bi == '' and mark & 1 != 0 limit ?", limit, as: String
# end

# def add_btran(input : Array(String))
#   DIC.exec "begin"

#   TL::Btran.translate(input, no_cap: true).each do |zh, bi|
#     # puts "#{zh} => #{bi}"
#     DIC.exec "update terms set bi = ? where zh = ?", bi, zh
#   end

#   DIC.exec "commit"
# end

# # 1.upto(7) do |flag|
# #   DIC.exec "begin"
# #   DIC.exec "update terms set flag = flag + 1 where mark & ? != 0", 1 << flag
# #   DIC.exec "commit"
# # end

# words = DIC.query_all "select zh from terms where bi == '' and flag > 1 order by flag desc", as: String

# words.each_slice(500).each do |slice|
#   puts slice.first(10)
#   add_btran(slice)
#   sleep 5
# end
