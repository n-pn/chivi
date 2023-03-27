require "db"
require "sqlite3"
require "colorize"

index_db = DB.open("sqlite3://var/dicts/index.db")
core_dic = DB.open("sqlite3://var/dicts/core.dic")
book_dic = DB.open("sqlite3://var/dicts/book.dic")
at_exit { index_db.close; core_dic.close; book_dic.close }

record Term, id : Int32, key : String, time : Int64, user : String, flag : Int32 do
  include DB::Serializable
end

def fix_dict_sizes!(index_db : DB::Database, inp_db : DB::Database, d_id : Int32)
  args = [d_id, -d_id]
  dsize = inp_db.scalar "select count(*) from terms where dic = ? or dic = ?", args: args
  mtime = inp_db.scalar "select max(time) from terms where dic = ? or dic = ?", args: args

  puts({d_id: d_id, dsize: dsize, mtime: mtime})

  index_db.exec <<-SQL, args: [dsize, mtime || 0, d_id]
    update dicts set dsize = ?, mtime = ?
    where id = ?
  SQL
end

index_db.exec "begin transaction"

fix_dict_sizes!(index_db, core_dic, 1)

book_ids = index_db.query_all "select id from dicts where id < 0", as: Int32
book_ids.each { |id| fix_dict_sizes!(index_db, book_dic, id) }

index_db.exec "commit"
index_db.exec "vacuum"
