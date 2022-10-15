require "crorm"

class ZH::ChName
  DB_PATH = "var/chaps/infos/%{sname}/%{s_bid}-names.db"

  include Crorm::Model
  self.table = "names"

  column ch_no : Int32, primary: true # chaper index number
  column s_cid : Int32                # chapter file name

  column chvol : String = "" # volume name
  column chnum : String = "" # chapter numering, eg: 第650章
  column title : String = "" # rest of chapter title

  def save!(repo : Crorm::Adapter)
    fields, values = self.get_changes
    repo.insert(self.class.table, fields, values, false)
  end

  def self.init_db(db_file : String)
    DB.open("sqlite3://./#{db_file}") do |db|
      db.exec <<-SQL
        create table if not exists names (
          ch_no integer primary key,
          s_cid integer not null,

          chvol varchar not null default "",
          chnum varchar not null default "",
          title varchar not null default ""
        );
        create index if not exists lookup_idx on names (s_cid);
      SQL
    end
  end
end
