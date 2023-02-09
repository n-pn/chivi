require "crorm"
require "crorm/sqlite3"

class CV::DlTran
  include Crorm::Model
  @@table = "dltrans"

  field id : Int32, primary: true

  field wn_id : Int32 = 0
  field sname : String = ""
  field s_bid : Int32 = 0

  field from_ch_no : Int32 = 0
  field upto_ch_no : Int32 = 0

  field texsmart_pos : Bool = false
  field texsmart_ner : Bool = false

  field mt_version : Int32 = 1

  field init_word_count : Int32 = 0
  field real_word_count : Int32 = 0

  field uname : String
  field privi : Int32 = 0

  field mtime : Int64 = Time.utc.to_unix
  field _flag : Int32 = 0

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  def initialize(@wn_id, @sname, @s_bid,
                 @from_ch_no, @upto_ch_no, @texsmart_pos, @texsmart_ner,
                 @mt_version, @init_word_count,
                 @uname, @privi, @_flag = 0)
  end

  @[AlwaysInline]
  def self.db_path
    "var/users/dltrans.db"
  end

  def self.init_sql
    <<-SQL
    create table dltrans(
      id integer primary key,
      --
      wn_id integer not null,
      sname varchar not null,
      s_bid integer not null,
      --
      from_ch_no integer not null,
      upto_ch_no integer not null,
      --
      texsmart_pos boolean not null default 'f',
      texsmart_ner boolean not null default 'f',
      --
      mt_version integer not null,
      --
      init_word_count integer not null,
      real_word_count integer not null,
      --
      uname varchar not null default 0,
      privi integer not null default 0,
      --
      mtime integer not null default 0,
      _flag integer not null default 0
    );
    --
    create index seed_idx on dltrans (wn_id, sname);
    create index rank_idx on dltrans (_flag, privi);
    --
    pragma journal_mode = WAL;
    SQL
  end
end
