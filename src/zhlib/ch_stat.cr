require "crorm"

class ZH::ChStat
  DB_PATH = "var/chaps/infos/%{sname}/%{s_bid}-stats.db"

  include Crorm::Model
  self.table = "stats"

  column ch_no : Int32, primary: true # chaper index number
  column s_cid : Int32                # chapter file name

  column c_len : Int32 = 0 # char count
  column p_len : Int32 = 0 # part count

  column mtime : Int64 = 0   # last modification time
  column uname : String = "" # last user saved/edited the chapter

  def save!(repo : Crorm::Adapter)
    fields, values = self.get_changes
    repo.insert(self.class.table, fields, values, false)
  end

  def self.init_db(db_file : String)
    DB.open("sqlite3://./#{db_file}") do |db|
      db.exec <<-SQL
        create table if not exists stats (
          ch_no integer primary key,
          s_cid integer not null,

          c_len integer not null default 0,
          p_len integer not null default 0,

          mtime integer not null default 0,
          uname varchar not null default ''
        );
        create index if not exists lookup_idx on stats (s_cid);
      SQL
    end
  end
end
