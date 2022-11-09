require "crorm"

class ZH::ZhBook
  include Crorm::Model
  self.table = "books"

  column s_bid : Int32, primary: true
  column bhash : String = ""

  column btitle : String = ""
  column author : String = ""

  column genres : String = ""
  column bcover : String = ""

  column status : Int32 = 0
  column mftime : Int64 = 0_i64

  column last_s_cid : Int32 = 0 # last chap origin id
  column chap_total : Int32 = 0 # total chapter/max chapter ch_no
  column chap_avail : Int32 = 0 # total chapters cached in disks

  column btime : Int64 = 0_i64 # birth time
  column mtime : Int64 = 0_i64 # modification time
  column ctime : Int64 = 0_i64 # crawl time

  property repo : Repo { Repo.load("=base") }

  def self.load(sname : String, s_bid : Int32)
    repo = Repo.load(sname)
    load(repo, s_bid)
  end

  def self.load(repo : Repo, s_bid : Int32)
    return new(repo, s_bid) unless entry = find(repo, s_bid)
    entry.tap(&.repo = repo)
  end

  def self.find(repo : Repo, s_bid : Int32)
    repo.db.query_one?("select * from books where s_bid = ?", args: [s_bid], as: self)
  end

  ###

  def initialize(@repo : Repo, @s_bid : Int32)
  end

  def add_intro(intro : String)
    prefix = @s_bid.not_nil! % 1000

    dir = "var/books/seeds/#{repo.sname}.db"
    zip_path = "#{dir}/intros/#{prefix}.zip"
    tmp_path = "#{dir}/intros.tmp/#{prefix}"

    Dir.mkdir_p(File.dirname(zip_path))
    Dir.mkdir_p(tmp_path)

    File.write("#{tmp_path}/#{s_bid}.txt", intro)
    Process.exec "zip", {"-rjuq", zip_path, tmp_path}
  end

  def save!
    @mtime = Time.utc.to_unix
    @btime = @mtime if @btime == 0

    fields, values = self.get_changes
    holder = Array.new(fields.size, "?").join(", ")

    repo.db.exec <<-SQL, args: values
      replace into books (#{fields.join(", ")}) values (#{holder})
    SQL
  end

  class Repo
    REPOS = {} of String => self

    def self.load(sname : String)
      REPOS[sname] ||= new(sname)
    end

    getter db : DB::Database
    getter sname : String

    def initialize(@sname : String)
      db_path = "var/books/seeds/#{sname}.db"
      init_db(db_path, reset: false) unless File.exists?(db_path)

      @db = DB.open("sqlite3://#{db_path}")
      at_exit { @db.close }
    end

    def init_db(db_path : String, reset : Bool = false)
      Log.info { "init zh_book database for seed: #{@sname}" }

      DB.open("sqlite3://#{db_path}") do |db|
        db.exec "drop table if exists books" if reset

        db.exec <<-SQL
          create table if not exists books (
            s_bid integer primary key,
            bhash varchar not null default "",

            author varchar not null default "",
            btitle varchar not null default "",

            genres varchar not null default "",
            bcover varchar not null default "",

            status integer not null default 0,
            mftime integer not null default 0,

            last_s_cid integer not null default 0,
            chap_total integer not null default 0,
            chap_avail integer not null default 0,

            btime integer not null default 0,
            mtime integer not null default 0,
            ctime integer not null default 0
          );
        SQL

        db.exec "create index if not exists lookup_idx on books(bhash);"
        db.exec "create index if not exists author_idx on books(author);"
        db.exec "create index if not exists btitle_idx on books(btitle);"
        db.exec "create index if not exists mftime_idx on books(mftime, status);"
      end
    end
  end
end
