require "db"
require "log"
require "crorm"
require "sqlite3"
require "colorize"

class MT::CvDict
  include Crorm::Model
  self.table = "dicts"

  column id : Int32

  column name : String
  column slug : String = ""

  column label : String = ""
  column intro : String = ""

  column dsize : Int32 = 0
  column mtime : Int64 = 0

  def ininitialize(@id, @name, @slug, @label = "", @intro = "")
  end

  def save!
    self.class.open_db do |db|
      db.exec <<-SQL, args: [@id, @name, @slug, @label, @intro]
        insert into dicts(id, name, slug, label, intro)
        values (?, ?, ?, ?, ?)
        on conflict (name) do update set
          slug = excluded.slug,
          label = excluded.label,
          intro = excluded.intro
        where id == excluded.id
      SQL
    end
  end

  def bump!(@dsize, @mtime)
    self.class.open_db do |db|
      db.exec <<-SQL, args: [dsize, mtime, id]
        update dicts set dsize = ?, mtime = ? where id = ?
      SQL
    end
  end

  def tuple
    {@name, @label, @dsize, @intro}
  end

  ######

  def self.get!(id : Int32)
    open_db do |db|
      db.query_one("select * from dicts where id = ?", args: [id], as: CvDict)
    end
  end

  def self.find(name : String)
    find!(name)
  rescue
    nil
  end

  def self.find!(name : String)
    open_db do |db|
      db.query_one(%{select * from dicts where name = ?}, args: [name], as: CvDict)
    end
  end

  def self.open_db
    DB.open("sqlite3:var/dicts/index.db") { |db| yield db }
  end

  def self.total_books
    open_db do |db|
      db.query_one "select count(*) from dicts where dsize > 0 and id < 0", as: Int32
    end
  end

  def self.fetch_books(limit : Int32, offset = 0)
    open_db do |db|
      query = <<-SQL
        select * from dicts where id < 0 and dsize > 0
        order by mtime desc
        limit ? offset ?
      SQL

      db.query_all query, args: [limit, offset], as: CvDict
    end
  end
end
