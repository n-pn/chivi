require "colorize"

ENV["CV_ENV"] ||= "production"
require "../../_data/_data"

require "../../mt_ai/core/*"
require "../../mt_sp/util/*"
require "../../mt_v1/core/tl_util"

def gen_names_from_hviet
  query = "select id, bt_zh from btitles where bt_hv = ''"
  inputs = PGDB.query_all query, as: {Int32, String}
  return if inputs.empty?

  hvcore = MT::QtCore.hv_name

  inputs.each_slice(1000).with_index do |slice, index|
    puts "- #{index * 1000} / #{inputs.size}"

    PGDB.transaction do |tx|
      db = tx.connection

      slice.each do |bt_id, bt_zh|
        bt_hv = hvcore.translate(bt_zh, cap: true)
        db.exec "update btitles set bt_hv = $1 where id = $2", bt_hv, bt_id
      end
    end
  end

  puts "- #{inputs.size} entries translated to hanviet"
end

def gen_names_from_qt_v1
  query = "select id, bt_zh from btitles where vi_qt = ''"
  inputs = PGDB.query_all query, as: {Int32, String}
  return if inputs.empty?

  inputs.each_slice(1000).with_index do |slice, index|
    puts "- #{index * 1000} / #{inputs.size}"

    PGDB.transaction do |tx|
      db = tx.connection

      slice.each do |bt_id, bt_zh|
        vi_qt = M1::TlUtil.tl_btitle(bt_zh)
        db.exec "update btitles set vi_qt = $1 where id = $2", vi_qt, bt_id
      end
    end
  end

  puts "- #{inputs.size} entries translated by qt_v1"
end

def gen_names_from_ms_tran
  query = <<-SQL
    select id, bt_zh from btitles
    where bt_zh <> '' and (vi_ms = '' or en_ms = '')
    order by id asc
  SQL

  input = PGDB.query_all query, as: {Int32, String}
  return if input.empty?

  update_sql = "update btitles set vi_ms = $1, en_ms = $2 where id = $3"

  input.each_slice(500) do |slice|
    words = slice.map(&.[1])
    trans = SP::MsTran.free_translate(words, tl: "vi&to=en")

    PGDB.transaction do |tx|
      db = tx.connection

      slice.zip(trans).each do |(bt_id, bt_zh), tran|
        vi_ms, en_ms = tran
        puts "[#{bt_id}] #{bt_zh} => #{vi_ms} | #{en_ms}"
        db.exec update_sql, vi_ms, en_ms, bt_id
      end
    end
  rescue ex
    return if ex.message == "no more available keys"
    puts ex
  end

  puts "- #{input.size} entries translated by ms bing"
end

def gen_names_from_bd_tran
  query = <<-SQL
    select id, bt_zh from btitles
    where bt_zh <> '' and vi_bd = ''
  SQL

  input = PGDB.query_all(query, as: {Int32, String})
  return if input.empty?

  puts "calling baidu: #{input.size}"
  update_sql = "update btitles set vi_bd = $1 where id = $2"

  input.shuffle!.each_slice(200).with_index(1) do |slice, index|
    puts "- #{index * 200} / #{input.size}"

    words = slice.map(&.[1])
    trans = SP::BdTran.web_translate(words.join('\n'), sl: "auto", tl: "vie", retry: true)

    PGDB.transaction do |tx|
      db = tx.connection
      trans.zip(slice).each do |vi_bd, (bt_id, bt_zh)|
        puts "[#{bt_id}] #{bt_zh} => #{vi_bd}"
        db.exec update_sql, vi_bd, bt_id
      end
    end

    sleep 1.seconds
  rescue ex
    Log.warn { ex.message.colorize.red }
    sleep 3.seconds
  end

  puts "- #{input.size} entries translated by baidu"
end

def gen_names_from_dl_tran
  query = <<-SQL
    select id, bt_zh from btitles
    where bt_zh <> '' and en_dl = ''
    order by id desc
  SQL

  input = PGDB.query_all query, as: {Int32, String}
  return if input.empty?

  puts "calling deepl: #{input.size}"

  update_sql = "update btitles set en_dl = $1 where id = $2"

  input.each_slice(500).with_index(1) do |slice, index|
    words = slice.map(&.[1])
    trans = SP::DlTran.translate(words)
    next if words.size != trans.size

    PGDB.transaction do |tx|
      db = tx.connection
      trans.zip(slice).each do |en_dl, (bt_id, bt_zh)|
        puts "[#{bt_id}] #{bt_zh} => #{en_dl}"
        db.exec update_sql, en_dl, bt_id
      end
    end

    puts "- #{index * 500} / #{input.size}"
    sleep 1.seconds
  rescue ex
    return if ex.message == "no more available keys"
    Log.warn { ex.message.colorize.red }
  end

  puts "- #{input.size} entries translated to eng by deepl"
end

gen_names_from_hviet
gen_names_from_qt_v1
gen_names_from_ms_tran
# gen_names_from_bd_tran
gen_names_from_dl_tran

# btitles = ZR::Btitle.db.open_ro do |db|
#   db.query_all "select * from btitles where name_vi = ''", as: ZR::Btitle
# end

# ZR::Btitle.db.open_tx do |db|
#   btitles.each do |btitle|
#     name_hv = btitle.name_hv.downcase
#     name_bv = btitle.name_bv.downcase
#     name_mt = btitle.name_mt.downcase

#     case
#     when name_mt == name_hv then name_vi = btitle.name_mt
#     when name_mt == name_bv then name_vi = btitle.name_mt
#     when name_hv == name_bv then name_vi = btitle.name_hv
#     end

#     next unless name_vi && !name_vi.empty?

#     puts "#{btitle.name_zh} => #{name_vi}"
#     db.exec "update btitles set name_vi = $1 where name_zh = $2", name_vi, btitle.name_zh
#   end
# end
