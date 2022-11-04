require "crorm"

class ZH::ZhBook
  include Crorm::Model
  self.table = "books"

  column s_bid : Int32
  column bhash : String = ""

  column btitle : String = ""
  column author : String = ""

  column genres : String = ""
  column bcover : String = ""

  column status : Int32 = 0
  column update : Int64 = 0_i64

  column last_s_cid : Int32 = 0 # last chap origin id
  column chap_total : Int32 = 0 # total chapter/max chapter ch_no
  column chap_avail : Int32 = 0 # total chapters cached in disks

  column btime : Int64 = 0_i64 # birth time
  column mtime : Int64 = 0_i64 # modification time
  column ctime : Int64 = 0_i64 # crawl time

  def initialize(@s_bid, @btitle = "", @author = "")
  end

  #####

  def self.add_intro(sname : String, s_bid : Int32, intro : String)
    prefix = s_bid % 1000
    zip_path = "var/books/seeds/#{sname}/intros/#{prefix}.zip"
    tmp_path = "var/books/seeds/#{sname}/intros.tmp/#{prefix}"

    Dir.mkdir_p(File.dirname(zip_path))
    Dir.mkdir_p(tmp_path)

    File.write("#{tmp_path}/#{s_bid}.txt", intro)
    Process.exec "zip", {"-rjmq", zip_path, tmp_path}
  end

  def self.find_or_init(sname : String, s_bid : Int32) : ZhBook
    find(sname, s_bid) || new(s_bid)
  end

  def self.find(sname : String, s_bid : Int32) : ZhBook?
    open_db(sname) do |db|
      db.query_one?("select * from books where s_bid = ?", [s_bid], as: ZhBook)
    end
  end

  def self.save!(sname : String, entry : ZhBook)
    open_db(sname) do |db|
      entry.mtime = Time.utc.to_unix
      entry.btime = entry.mtime if entry.btime == 0

      fields, values = entry.get_changes
      holder = Array.new(fields.size, "?").join(", ")

      db.exec <<-SQL, args: values
        replace into books (#{fields.join(", ")}) values (#{holder})
      SQL
    end
  end

  def self.open_db(sname : String)
    db_path = "var/books/seeds/#{sname}.db"
    DB.open("sqlite3://./#{db_path}") { |x| yield x }
  end

  def self.init_db(db_path : String)
    open_db do |db|
      db.exec <<-SQL
        create table if not exists books (
          s_bid integer primary key,
          bhash varchar not null default "",

          author varchar not null default "",
          btitle varchar not null default "",

          genres varchar not null default "",
          bcover varchar not null default "",

          "status" integer not null default 0,
          "update" integer not null default 0,

          chap_count integer not null default 0,
          chap_total integer not null default 0,

          last_schid integer not null default 0,

          btime integer not null default 0,
          mtime integer not null default 0
          ctime integer not null default 0
        );
      SQL

      db.exec "create index lookup_idx on books (bhash);"
      db.exec "create index author_idx on books (author);"
      db.exec "create index btitle_idx on books (btitle);"
      db.exec "create index update_idx on books (update, status);"
    end
  end
end
