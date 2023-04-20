require "../_base"

class CV::Wnlink
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

  UPSERT_STMT = <<-SQL
    insert into wnlinks (book_id, link, name, type)
    values ($1, $2, $3, $4)
    on conflict on constraint wnlink_unq do nothing
  SQL

  def self.upsert!(wn_id : Int32, link : String)
    name = self.extract_name(link)
    type = link.includes?("yousuu") ? 2 : 1
    PGDB.exec(UPSERT_STMT, wn_id, link, name, type)
  end

  def self.upsert!(wn_id : Int32, links : Array(String))
    links.each { |link| upsert!(wn_id, link) }
  end

  # USE_SUBDOMAIN = {"yunqi", "chuangshi", "huayu", "yuedu", "shenqi"}

  IGNORES = {"www", "book", "b", "novel", "shushan", "wenxue"}

  def self.extract_name(link : String)
    return "" unless host = URI.parse(link).host
    host.split('.').find!(&.in?(IGNORES).!)
  end
end
