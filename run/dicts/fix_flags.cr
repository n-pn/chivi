require "colorize"

require "../../src/cvmtl/cv_data/*"

record Term, id : Int32, key : String, time : Int64, user : String, flag : Int32 do
  include DB::Serializable
end

def fix_flags_for_base_dict!(type : String)
  MT::DbRepo.open_db(type) do |db|
    dict_ids = db.query_all "select id from dicts where id % 3 == 0", as: Int32

    db.exec "begin transaction"

    select_query = "select id, key, time, user, flag from terms where dic = ?"
    update_query = "update terms set flag = 1 where dic = ? and key = ? and id <> ?"

    dict_ids.each do |dic|
      terms = db.query_all select_query, args: [dic], as: Term

      terms.group_by(&.key).each_value do |group|
        next if group.size < 2

        group.sort_by! { |x| {x.flag, -x.time} }
        first = group.first

        db.exec update_query, args: [dic, first.key, first.id]
        puts "#{group.size - 1} entries affected!"
      end
    end

    db.exec "commit"
  end
end

def fix_flags_for_temp_dict!(type : String)
  MT::DbRepo.open_db(type) do |db|
    dict_ids = db.query_all "select id from dicts where id % 3 == 1", as: Int32

    db.exec "begin transaction"

    select_query = "select id, key, time, user, flag from terms where dic = ?"
    update_query = "update terms set flag = 1 where dic = ? and key = ? and id <> ?"

    maxtime_query = "select max (time) from terms where dic = ? and key = ? and flag < 1"

    dict_ids.each do |dic|
      terms = db.query_all select_query, args: [dic], as: Term

      terms.group_by(&.key).each do |key, group|
        group.sort_by! { |x| {x.flag, -x.time} }
        first = group.first

        max_time = db.query_one?(maxtime_query, args: [dic - 1, key], as: Int64?) || -1i64

        id = first.time < max_time ? -1 : first.id
        next if id != -1 && group.size == 1

        db.exec update_query, args: [dic, key, id]
        puts "#{group.size} entries affected!"
      end
    end

    db.exec "commit"
  end
end

def fix_flags_for_user_dict!(type : String)
  MT::DbRepo.open_db(type) do |db|
    dict_ids = db.query_all "select id from dicts where id % 3 == 1", as: Int32

    db.exec "begin transaction"

    select_query = "select id, key, time, user, flag from terms where dic = ?"
    update_query = "update terms set flag = 1 where dic = ? and key = ? and user = ? and id <> ?"

    dict_ids.each do |dic|
      terms = db.query_all select_query, args: [dic], as: Term

      terms.group_by(&.key).each do |key, group|
        group.group_by(&.user).each do |user, items|
          next if items.size < 2

          items.sort_by! { |x| {x.flag, -x.time} }
          first = items.first

          db.exec update_query, args: [dic, key, user, first.id]
          puts "#{items.size - 1} entries affected!"
        end
      end
    end

    db.exec "commit"
  end
end

fix_flags_for_base_dict!("core")
fix_flags_for_base_dict!("book")

fix_flags_for_temp_dict!("core")
fix_flags_for_temp_dict!("book")

fix_flags_for_user_dict!("core")
fix_flags_for_user_dict!("book")
