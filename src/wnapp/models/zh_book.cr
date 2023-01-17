require "crorm"

class ZH::ZhRepo
  REPOS = {} of String => self

  def self.load(sname : String, group : Int32)
    REPOS["#{sname}/#{group}"] ||= new(sname, group)
  end

  getter db : DB::Database
  forward_missing_to @db

  def initialize(sname : String, group = 0, reset = false)
    db_path = "var/books/seeds/#{sname}/#{group}.db"
    existed = File.exists?(db_path)

    @db = DB.open("sqlite3:#{db_path}")
    at_exit { @db.close }

    init_db(reset: reset) if reset || !existed
  end

  def init_db(reset : Bool = false)
    @db.exec "drop table if exists books" if reset

    @db.exec <<-SQL
      create table if not exists books (
        id integer primary key,

        author varchar default '',
        btitle varchar default '',

        genres varchar default '',
        bcover varchar default '',
        bintro text default '',

        ccount integer default 0,
        lastch integer default 0,

        status integer default 0,
        mftime integer default 0
      );
    SQL

    db.exec "create index if not exists author_idx on books(author);"
    db.exec "create index if not exists btitle_idx on books(btitle);"
  end
end

class ZH::ZhBook
  include Crorm::Model

  @@table = "books"

  field id : Int32, primary: true

  field btitle : String = ""
  field author : String = ""

  field genres : String = ""
  field bcover : String = ""
  field bintro : String = ""

  field ccount : Int32 = 0
  field lastch : Int32 = 0

  field status : Int32 = 0
  field mftime : Int64 = 0_i64 # modification time

  property repo : ZhRepo { ZhRepo.load("=base", 0) }

  def initialize(@repo : ZhRepo, @id : Int32)
  end

  def save!(repo = self.repo, @mftime = Time.utc.to_unix)
    fields, values = self.get_changes
    holder = Array.new(fields.size, "?").join(", ")

    repo.exec <<-SQL, args: values
      replace into books (#{fields.join(", ")}) values (#{holder})
    SQL
  end

  ##########

  def self.group_of(s_bid : Int32)
    (s_bid &- 1) // 1028
  end

  def self.load(sname : String, s_bid : Int32)
    repo = ZhRepo.load(sname, group_of(s_bid))
    self.load(repo, s_bid)
  end

  def self.load(repo : ZhRepo, s_bid : Int32)
    if entry = find(repo, s_bid)
      entry.tap(&.repo = repo)
    else
      new(repo, s_bid)
    end
  end

  def self.find(sname : String, s_bid : Int32)
    find(ZhRepo.load(sname, group_of(s_bid)))
    repo.query_one?("select * from books where id = ?", s_bid, as: self)
  end

  def self.find(repo : ZhRepo, s_bid : Int32)
    repo.query_one?("select * from books where id = ?", s_bid, as: self)
  end
end
