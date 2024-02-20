require "crorm"

class DbDefn
  class_getter db_path = "var/mt_db/v1_defns.db3"
  class_getter init_sql : String = <<-SQL
    create table defns(
      d_id integer not null,
      zstr text not null,
      --
      vstr text not null default '',
      ptag text not null default '',
      rank integer not null default 0,
      --
      primary key(d_id, zstr)
    ) strict, without rowid;
  SQL

  include Crorm::Model
  schema "defns", :sqlite, strict: false

  ######

  field d_id : Int32 = 0, pkey: true
  field zstr : String = "", pkey: true
  field vstr : String = ""
  field ptag : String = ""
  field rank : Int32 = 2

  def initialize(@d_id, @zstr, vstr, @ptag = "", @rank = 2)
    @vstr = vstr.split(/[|ǀ]/, 2).first.strip
  end

  def initialize(rs : DB::ResultSet)
    @d_id = rs.read(Int32)
    @zstr = rs.read(String)
    @vstr = rs.read(String).split(/[|ǀ]/, 2).first.strip
    @ptag = rs.read(String)
    @rank = rs.read(Int32)
  end
end

# inputs = DB.open("sqlite3:/2tb/app.chivi/var/mt_db/v1_defns.dic?immutable=1") do |db|
#   db.query_all "select dic, key, val, ptag, prio from defns order by id asc", as: DbDefn
# end

inputs = [] of DbDefn

File.each_line "/2tb/var.chivi/mtdic/inits/vietphrase/lol-names.txt" do |line|
  next if line.empty?
  zstr, vstr = line.split('=', 2)
  inputs << DbDefn.new(15542, zstr, vstr, "Nr")
  inputs << DbDefn.new(15542, zstr.sub('.', '·'), vstr, "Nr") if zstr.includes?('.')
end

puts inputs.size

DbDefn.db.open_tx do |db|
  inputs.each(&.upsert!(db: db))
end

# DbDefn.db.open_tx do |db|
#   # delete entry in regular that existed in fixture
#   db.exec <<-SQL
#     delete from defns
#     where d_id = -1 and zstr in (select zstr from defns where d_id = -3)
#   SQL

#   # move from fixture to regular
#   db.exec <<-SQL
#     update defns set d_id = -1 where d_id = -3
#   SQL

#   # delete entry in essence that existed in regular
#   db.exec <<-SQL
#     delete from defns
#     where d_id = -2 and zstr in (select zstr from defns where d_id = -1)
#   SQL

#   # move from essence to regular
#   db.exec <<-SQL
#    update defns set d_id = -1 where d_id = -2
#  SQL
# end
