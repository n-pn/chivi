require "colorize"

require "../../zroot/author"
require "../../mtapp/sp_core"
require "../../mtapp/service/btran_api"
require "../../mtapp/service/deepl_api"

def gen_name_hv
  output = [] of {String, Int32}

  ZR::Author.open_db do |db|
    db.query_each "select rowid, name_zh from authors where name_zh <> '' and name_mt == ''" do |rs|
      rowid, zname = rs.read(Int32, String)

      output << {MT::SpCore.tl_hvname(zname), rowid}
    end
  end

  puts "- #{output.size} entries translated to hanviet"
  return if output.empty?

  ZR::Author.open_tx do |db|
    output.each do |zname, rowid|
      db.exec "update authors set name_mt = $1 where rowid = $2", zname, rowid
    end
  end
end

def gen_name_bv(min_flag = 1)
  znames = ZR::Author.open_db do |db|
    stmt = "select name_zh from authors where name_zh <> '' and name_bv == '' and _flag >= $1"
    db.query_all stmt, min_flag, as: String
  end

  return if znames.empty?

  znames.each_slice(200) do |slice|
    puts slice

    ZR::Author.open_tx do |db|
      SP::Btran.translate(slice, target: "vi").each do |zname, vname|
        db.exec "update authors set name_bv = $1 where name_zh = $2", vname, zname
      rescue ex
        puts ex.colorize.red
      end
    end
  end

  puts "- #{znames.size} entries translated to viet by bing"
end

def gen_name_be(min_flag = 1)
  znames = ZR::Author.open_db do |db|
    stmt = "select name_zh from authors where name_zh <> '' and name_be == '' and _flag >= $1"
    db.query_all stmt, min_flag, as: String
  end

  return if znames.empty?

  znames.each_slice(200) do |slice|
    puts slice

    ZR::Author.open_tx do |db|
      SP::Btran.translate(slice, target: "en").each do |zname, vname|
        db.exec "update authors set name_be = $1 where name_zh = $2", vname, zname
      rescue ex
        puts ex.colorize.red
      end
    end
  end

  puts "- #{znames.size} entries translated to eng by bing"
end

def gen_name_de(min_flag = 1)
  znames = ZR::Author.open_db do |db|
    stmt = "select name_zh from authors where name_zh <> '' and name_de == '' and _flag >= $1"
    db.query_all stmt, min_flag, as: String
  end

  return if znames.empty?

  znames.each_slice(200) do |slice|
    puts slice

    ZR::Author.open_tx do |db|
      SP::Deepl.translate(slice, target: "en").each do |zname, vname|
        db.exec "update authors set name_de = $1 where name_zh = $2", vname, zname
      rescue ex
        puts ex.colorize.red
      end
    end
  end

  puts "- #{znames.size} entries translated to eng by deepl"
end

gen_name_hv
gen_name_bv(min_flag: 1)
gen_name_be(min_flag: 1)
gen_name_de(min_flag: 1)
