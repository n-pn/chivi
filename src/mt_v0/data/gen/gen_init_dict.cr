require "json"
require "../vp_init"

DIR = "var/texts/anlzs/out"

alias Counter = Hash(String, Int32)

ZPOS_SELECT = "select zstr, ztag, mrate from terms where \"type\" < 300 order by mrate desc"

ZPOS_UPSERT = <<-SQL
  insert into defns (zstr, zpos) values ($1, $2)
  on conflict (zstr) do update set zpos = excluded.zpos
SQL

def export_zpos(db_path : String)
  puts "ZPOS: #{db_path}"
  counters = {} of String => Counter

  DB.open("sqlite3:#{db_path}") do |db|
    db.query_each ZPOS_SELECT do |rs|
      zstr, zpos, occu = rs.read(String, String, Int32)
      counter = counters[zstr] ||= Counter.new
      counter[zpos] ||= occu
    end
  end

  wn_id = File.basename(db_path, ".db")

  repo = MT::VpInit.repo(wn_id)
  repo.db.exec "begin"

  counters.each do |zstr, counter|
    repo.db.exec ZPOS_UPSERT, zstr, counter.to_json
  end

  repo.db.exec "commit"
end

MAP_ENT_TYPE = begin
  {{ read_file("#{__DIR__}/map_ent_type.tsv").lines.reject!(&.blank?) }}.map do |line|
    key, val = line.split('\t')
    {key, val}
  end.to_h
end

def map_ent_type(inp_ent : String)
  group, subtype = inp_ent.split('.')
  case inp_ent
  when .starts_with?("adj.")                then "VA"
  when .starts_with?("adv.")                then "AD"
  when .starts_with?("verb.")               then "VV"
  when .starts_with?("activity.")           then "ACT"
  when .starts_with?("animal.")             then "ANI"
  when .starts_with?("writing_instrument.") then "OBJ"
  when .starts_with?("vehicle.")            then "OBJ"
  when .starts_with?("person.")             then "PER"
  when .starts_with?("ap.artist.")          then "PER"
  when .starts_with?("ap.work.character")   then "PER"
  when .starts_with?("loc.")                then "LOC"
  when .starts_with?("land_form.")          then "LOC"
  when .starts_with?("arc_structure.")      then "LOC"
  when .starts_with?("org.")                then "ORG"
  when .starts_with?("attr.")               then "ATTR"
  when .starts_with?("work.")               then "WORK"
  when .starts_with?("time.")               then "TIME"
  when .starts_with?("math.")               then "MATH"
  when .starts_with?("quantity.")           then "UNIT"
  else
    MAP_ENT_TYPE[inp_ent]? || inp_ent
  end
end

ZENT_SELECT = <<-SQL
  select zstr, ztag, mrate from terms
  where "type" >= 300
  order by mrate desc
SQL

ZENT_UPSERT = <<-SQL
  insert into defns (zstr, zent) values ($1, $2)
  on conflict (zstr) do update set zent = excluded.zent
SQL

def export_zent(db_path : String)
  puts "ZPOS: #{db_path}"
  counters = {} of String => Counter

  DB.open("sqlite3:#{db_path}") do |db|
    db.query_each ZENT_SELECT do |rs|
      zstr, zent, occu = rs.read(String, String, Int32)
      zent = map_ent_type(zent)
      counter = counters[zstr] ||= Counter.new(0)
      counter[zent] += occu
    end
  end

  wn_id = File.basename(db_path, ".db")

  repo = MT::VpInit.repo(wn_id)
  repo.db.exec "begin"

  counters.each do |zstr, counter|
    repo.db.exec ZENT_UPSERT, zstr, counter.to_json
  end

  repo.db.exec "commit"
end

Dir.glob("#{DIR}/*.db") do |db_path|
  # export_zpos(db_path)
  export_zent(db_path)
end

# INP = "var/dicts/inits/regular-terms-cv.tsv"
# MT::VpInit.repo.open_tx do |db|
#   db.exec "delete from terms"

#   sql = <<-SQL
#   insert into terms(id, zstr, tags, mtls, raw_tags, raw_mtls)
#   values(?, ?, ?, ?, ?, ?)
#   SQL

#   id = 0

#   File.each_line(INP) do |line|
#     rows = line.split('\t')
#     next if rows.size < 2

#     id += 1

#     zstr = rows[0]
#     tags = rows[1].split.flat_map(&.split(':').[0]).join(' ')

#     cv_mtls = rows[2]? || ""
#     bi_mtls = rows[3]? || ""
#     qt_mtls = rows[4]? || ""

#     mtls = cv_mtls
#     mtls = qt_mtls if mtls.blank?
#     mtls = bi_mtls if mtls.blank?
#     mtls = mtls.split('ǀ').first

#     raw_tags = {ts: rows[1]}.to_json
#     raw_mtls = {cv: cv_mtls || "", bi: bi_mtls || "", qt: qt_mtls || ""}.to_json

#     db.exec sql, id, zstr, tags, mtls, raw_tags, raw_mtls
#   end
# end
