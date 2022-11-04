require "colorize"

require "../../src/cvmtl/cv_data/*"

record Term, id : Int32, key : String, time : Int64, user : String, flag : Int32 do
  include DB::Serializable
end

def fix_dict_sizes!(type : String)
  MT::DbRepo.open_db(type) do |db|
    dict_ids = db.query_all "select id from dicts", as: Int32

    db.exec "begin transaction"

    dict_ids.each do |dic|
      args = [dic]
      total = db.scalar "select count(*) from terms where dic = ?", args: args
      active = db.scalar "select count(*) from terms where dic = ? and flag < 1", args: args

      last_time = db.scalar("select max(time) from terms where dic = ?", args: args) || 0_i64
      puts({dic: dic, total: total, active: active, last_time: last_time})

      db.exec <<-SQL, args: [total, active, last_time]
        update dicts set term_total = ?, term_count = ?, last_mtime = ?
        where id = ?
      SQL
    end

    db.exec "commit"
  end
end

# fix_dict_sizes!("core")
fix_dict_sizes!("book")
