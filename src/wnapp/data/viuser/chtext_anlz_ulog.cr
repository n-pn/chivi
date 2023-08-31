require "crorm"

struct WN::ChtextAnlzUlog
  class_getter db_path = ""

  def self.db_path(wn_id : Int32 | String)
    # "var/wnapp/anlzlog/#{wn_id}.db"
    "var/wnapp/logging/#{wn_id}-anlz.db"
  end

  class_getter init_sql = <<-SQL
    create table if not exists ulogs (
      ch_no integer not null,
      p_idx integer not null,
      uname varchar not null,
      cksum varchar not null,
      _algo varchar not null default '',
      mtime integer not null default 0,
      primary key(ch_no, p_idx, uname, cksum)
    );
    SQL

  ###

  include Crorm::Model
  schema "ulogs", :sqlite, multi: true

  field ch_no : Int32
  field p_idx : Int32 = 0

  field uname : String = ""
  field cksum : String = ""

  field _algo : String = ""
  field mtime : Int64 = Time.utc.to_unix

  def initialize(@ch_no, @p_idx, @uname, @cksum,
                 @_algo = "electra_base", @mtime = Time.utc.to_unix)
  end

  def create!(wn_id : Int32 | String)
    create!(self.class.db(wn_id))
  end

  def create!(db : Crorm::SQ3 | DB::Database | DB::Connection)
    query = @@schema.insert_stmt.sub("insert into", "replace into")
    db.exec query, *self.db_values
  end
  ###
end
