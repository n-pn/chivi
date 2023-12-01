require "json"
require "../../_data/_data"

struct RD::ViuserView
  include DB::Serializable
  include JSON::Serializable

  getter vu_id : Int32
  getter uname : String
  getter privi : Int32

  SELECT_SQL = <<-SQL
    select id as vu_id, uname, privi
    from viusers where id = any($1)
    SQL

  def self.get_all(ids : Enumerable(Int32))
    return [] of self if ids.empty?

    PGDB.query_all(SELECT_SQL, ids.to_a, as: self)
  rescue ex
    Log.error(exception: ex) { ids }
    [] of self
  end
end
