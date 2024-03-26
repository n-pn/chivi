require "sqlite3"
require "crorm"

class Mapping
  class_getter init_sql : String = <<-SQL
    create table mapping (
      sname text not null,
      sn_id int not null,

      au_zh text not null,
      bt_zh text not null,

      primary key(sname, sn_id)
    ) strict, without rowid;
  SQL

  class_getter db_path = "/srv/chivi/zroot/mapping.db3"

  include Crorm::Model
  schema "mapping", :sqlite

  field sname : String, pkey: true
  field sn_id : Int32, pkey: true

  field au_zh : String
  field bt_zh : String

  def initialize(@sname, @sn_id, @au_zh, @bt_zh)
  end
end

def import_older
  paths = Dir.glob "/www/var.chivi/zbook/*.db"

  paths.each do |path|
    sname = File.basename(path, ".db")

    items = DB.open("sqlite3:#{path}") do |db|
      db.query_all "select '#{sname}' as sname, id as sn_id, author as au_zh, btitle as bt_zh from books", as: Mapping
    end

    Mapping.db.open_tx { |db| items.each(&.upsert!(db: db)) }

    puts "#{path}: #{items.size}"
  rescue ex
    puts path, ex
  end
end

def import_newer
  paths = Dir.glob "/www/chivi/xyz/books/infos/*.db"

  paths.each do |path|
    sname = File.basename(path, ".db")

    items = DB.open("sqlite3:#{path}") do |db|
      db.query_all "select '#{sname}' as sname, cast(snvid as integer) as sn_id, author as au_zh, btitle as bt_zh from zhbooks", as: Mapping
    end

    Mapping.db.open_tx { |db| items.each(&.upsert!(db: db)) }

    puts "#{path}: #{items.size}"
  rescue ex
    puts path, ex
  end
end

ENV["CV_ENV"] = "production"
require "../src/_data/_data"

def import_latest
  rsnames = PGDB.query_all("select distinct(sname) from rmstems", as: String)

  rsnames.each do |sname|
    items = PGDB.query_all <<-SQL, sname, as: Mapping
      select '#{sname.lchop('!')}' as sname, sn_id, author_zh as au_zh, btitle_zh as bt_zh from rmstems where sname = $1
    SQL

    puts "#{sname}: #{items.size}"
    Mapping.db.open_tx { |db| items.each(&.upsert!(db: db)) }
  end
end

# import_older
# import_newer
# import_latest
