require "sqlite3"
require "colorize"
require "../../src/_data/_data"
require "../../src/_util/book_util"

# require "../../src/_data/wnovel/wnseed"
# require "../../src/_data/member/ubmemo"

record Wnsterm, id : Int32, sname : String, chap_total : Int32 do
  include DB::Serializable
end

def find_all_seeds(wn_id : Int32)
  PGDB.query_all(<<-SQL, wn_id, as: Wnsterm)
    select id, sname, chap_total from wnseeds where wn_id = $1
  SQL
end

def transfer_wnseeds(from_id : Int32, to_id : Int32)
  from_seeds = find_all_seeds(from_id)
  to_seeds = find_all_seeds(to_id).map { |x| {x.sname, x} }.to_h

  success_all = true

  from_seeds.each do |from_seed|
    if !(to_seed = to_seeds[from_seed.sname]?)
      puts "- changed id for seed #{from_seed.sname}: #{from_id} to #{to_id}"
      PGDB.exec "update wnseeds set wn_id = $1 where id = $2", to_id, from_seed.id
    else
      puts "- existed (#{from_seed.sname}) #{to_seed.id}: #{from_seed.chap_total} => #{to_seed.chap_total}"

      if from_seed.chap_total <= to_seed.chap_total
        # just remove it if current seed has less chapters
        PGDB.exec "delete from wnseeds where id = $1", from_seed.id
        next
      else
        #
        success_all = false
        PGDB.exec "delete from wnseeds where id = $1", to_seed.id
      end
    end
  end

  success_all
rescue ex
  puts ex
  false
end

def find_all_memos(wn_id : Int32)
  PGDB.query_all(<<-SQL, wn_id, as: {Int32, Int32})
    select viuser_id, id from ubmemos where nvinfo_id = $1
  SQL
end

def transfer_ubmemos(from_id : Int32, to_id : Int32)
  from_memos = find_all_memos(from_id)
  to_memos = find_all_memos(to_id).to_h

  from_memos.each do |user_id, memo_id|
    if to_memo_id = to_memos[user_id]?
      puts "#{to_memo_id} memo existed"
      PGDB.exec "delete from ubmemos where id = $1", memo_id
    else
      puts "transfer memo of [#{user_id}] from [#{from_id}] to [#{to_id}]"
      PGDB.exec "update ubmemos set nvinfo_id = $1 where id = $2", to_id, memo_id
    end
  end

  true
end

def transfer(from_id : Int32, to_id : Int32)
  success_all = true

  PGDB.exec "update ysbooks set nvinfo_id = $1 where nvinfo_id = $2", to_id, from_id
  PGDB.exec "update yscrits set nvinfo_id = $1 where nvinfo_id = $2", to_id, from_id

  success_all &&= transfer_wnseeds(from_id, to_id)
  success_all &&= transfer_ubmemos(from_id, to_id)

  DB.open("sqlite3:var/mtapp/v1dic/v1_defns.dic") do |db|
    db.exec "update defns set dic = $1 where dic = $2", to_id, from_id
  end

  PGDB.exec "delete from wninfos where id = $1", from_id
  puts "book #{from_id} deleted"
end

existed = {} of String => Int32

inputs = PGDB.query_all <<-SQL, as: {Int32, String, String}
  select id, author_zh, btitle_zh from wninfos order by id asc
  SQL

inputs.each do |wn_id, author, btitle|
  author, btitle = BookUtil.fix_names(author, btitle)

  label = "#{author}---#{btitle}".downcase

  if older_id = existed[label]?
    puts "#{wn_id} => #{older_id} (#{label})"
    transfer(wn_id, older_id)
  else
    existed[label] = wn_id
  end
end
