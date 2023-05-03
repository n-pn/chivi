require "./_data"

struct YS::WninfoPeek
  include DB::Serializable
  include JSON::Serializable

  getter bslug : String
  getter bname : String
  getter aname : String

  getter cover : String
  getter genre : String

  getter voters : Int32
  getter rating : Int32

  getter state : Int32
  getter utime : Int64

  def self.fetch_one(yscrit_id : Int32)
    PG_DB.query_one <<-SQL, yscrit_id, as: self
    select
      (b.id || '-' || b.bslug) as bslug,
      b.vname as bname,
      a.vname as aname,

      (case when b.bcover = '' then b.scover else b.bcover end) as cover,
      b.igenres[1] as genre,

      b.voters as voters,
      b.rating as rating,

      b.status as "state",
      b.utime as utime
    from  wninfos as b
      on b.id = c.nvinfo_id
      inner join authors as a
      on a.id = b.author_id
    where b.id = $1
    limit 1;
    SQL
  end

  # def self.fetch_all(yscrit_id : Int32)

  # end
end
