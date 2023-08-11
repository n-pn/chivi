require "crorm/model"

class CV::DlTran
  class_getter db_path = "var/users/dltrans.db"

  class_getter init_sql = <<-SQL
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
      mt_version integer not null,
      smart_opts integer not null default 0,
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
    SQL

  ####

  include Crorm::Model
  schema "dltrans", :sqlite

  field id : Int32, pkey: true, auto: true

  field wn_id : Int32 = 0
  field sname : String = ""
  field s_bid : Int32 = 0

  field from_ch_no : Int32 = 0
  field upto_ch_no : Int32 = 0

  field mt_version : Int32 = 1
  field smart_opts : Int32 = 0

  field init_word_count : Int32 = 0
  field real_word_count : Int32 = 0

  field uname : String = "-"
  field privi : Int32 = 0

  field mtime : Int64 = Time.utc.to_unix
  field _flag : Int32 = 0

  def initialize(@wn_id, @sname, @s_bid,
                 @from_ch_no, @upto_ch_no,
                 @mt_version, @smart_opts,
                 @init_word_count,
                 @uname, @privi, @_flag = 0)
  end

  def failed?
    return true if @_flag == -1
    return false unless @_flag == 1
    Time.utc - Time.unix(self.mtime) > 10.minutes
  end

  def reset_flag!
    stmt = "update dltrans set _flag = 0 where id = $1"
    self.class.db.open_tx(&.exec(stmt, self.id))
  end

  ###

  def self.all(wn_id : Int32, uname : String)
    self.all(wn_id, uname) { |sql| sql << " where wn_id = $1 and uname = $2 " }
  end

  def self.get(id : Int32, uname : String)
    self.get(id, uname) { |sql| sql << " where id = $1 and uname = $2 " }
  end
end
