require "crorm/model"
require "crorm/sqlite"

struct WN::ChtextAnlzUlog
  class_getter db_path = "var/wnapp/chtext-anlz-ulog.db"

  class_getter init_sql = <<-SQL
    create table if not exists anlz_ulogs (
      wn_id varchar not null,
      ch_no integer not null,
      cksum varchar not null default '',
      p_idx integer not null default 0,
      uname varchar not null default '',
      _algo varchar not null default '',
      ctime integer not null default 0
    );

    create index if not exists book_idx on anlz_ulogs(wn_id, ch_no);
    create index if not exists user_idx on anlz_ulogs(uname, _algo);
    SQL

  ###

  include Crorm::Model
  schema "anlz_ulogs", :sqlite

  # field id : Int32, pkey: true, auto: true

  field wn_id : Int32
  field ch_no : Int32 = 0

  field cksum : String = ""
  field p_idx : Int32 = 0

  field uname : String = ""
  field _algo : String = ""
  field ctime : Int64 = Time.utc.to_unix

  def initialize(@wn_id, @ch_no, @cksum, @p_idx, @uname, @_algo)
  end

  ###
end
