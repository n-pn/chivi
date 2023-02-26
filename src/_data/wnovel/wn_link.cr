require "../_base"

class CV::WnLink
  include DB::Serializable
  include JSON::Serializable

  getter link : String
  getter name : String
  getter type : Int32

  def self.all_origs(wn_id : Int32)
    stmt = <<-SQL
      select "link", "name", "type" from wnlinks
      where "type" < 3 and book_id = $1
      order by "type" desc
    SQL

    PGDB.query_all(stmt, wn_id, as: self)
  end
end
