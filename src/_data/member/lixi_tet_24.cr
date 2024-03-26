require "crorm"

class CV::LixiTet24
  class_getter db_path = "/src/chivi/users/lixi-tet-24.db3"

  class_getter init_sql = <<-SQL
    create table rolls(
      id integer primary key,
      vu_id integer not null,
      uname varchar not null,
      vcoin integer not null,
      mtime integer not null
    );

    create index user_idx on rolls (uname);
    create index best_idx on rolls (vcoin);
    SQL

  ###

  include Crorm::Model
  schema "rolls", :sqlite

  field id : Int32, pkey: true, auto: true

  field vu_id : Int32 = 0
  field uname : String = ""
  field vcoin : Int32 = 0
  field mtime : Int64 = Time.utc.to_unix

  def initialize(@vu_id, @uname, @vcoin)
  end

  def self.roll_count(uname : String)
    stmt = "select count(*) from rolls where uname = $1"
    @@db.open_ro(&.query_one(stmt, uname, as: Int32))
  end

  def self.get_rolls(limit : Int32, offset : Int32, uname : String?, sort : String = "")
    Log.info { [limit, offset, uname, sort] }
    @@db.open_ro do |db|
      args = [] of String | Int32

      query = String.build do |sql|
        sql << "select * from rolls"

        if uname
          args << uname
          sql << " where uname = $1"
        end

        case sort
        when "vcoin"  then sql << " order by vcoin asc"
        when "-vcoin" then sql << " order by vcoin desc"
        when "mtime"  then sql << " order by id asc"
        else               sql << " order by id desc"
        end

        sql << " limit $#{args.size + 1} offset $#{args.size + 2}"
        args << limit << offset
      end

      db.query_all query, args: args, as: self
    end
  end
end
