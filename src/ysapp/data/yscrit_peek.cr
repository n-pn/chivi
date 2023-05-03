require "./_data"

struct YS::YscritPeek
  include DB::Serializable
  include JSON::Serializable

  getter yc_id : Int32
  getter ctime : Int64
  getter utime : Int64

  getter stars : Int32
  getter btags : Array(String)
  getter vhtml : String

  getter like_count : Int32
  getter repl_count : Int32

  getter yu_id : Int32
  getter uname : String
  getter u_pic : String

  getter wn_slug : String

  getter yl_name : String?
  getter yl_slug : String?
  getter yl_bnum : Int32?

  def self.fetch_one(id : Int32)
    PG_DB.query_one <<-SQL, id, as: self
    select
      c.id as yc_id,
      extract(epoch from c.created_at)::bigint as ctime,
      extract(epoch from c.updated_at)::bigint as utime,

      c.stars as stars,
      c.vtags as btags,
      c.vhtml as vhtml,

      c.like_count as like_count,
      c.repl_count as repl_count,

      u.id as yu_id,
      u.vname as uname,
      u.y_avatar as u_pic,

      (b.id || '-' || b.bslug) as wn_slug,

      l.vname as yl_name,
      (l.id || l.vslug) as yl_slug,
      l.book_count as yl_bnum
    from yscrits as c
      inner join ysusers as u on u.id = c.ysuser_id
      inner join wninfos as b on b.id = c.nvinfo_id
       left join yslists as l on l.id = c.yslist_id
    where c.id = $1
    limit 1;
    SQL
  end

  # def self.fetch_all(yscrit_id : Int32)

  # end

  def self.get_ztext(crit_id : Int32)
    PG_DB.query_one <<-SQL, crit_id, as: String
    select coalesce(ztext, '') from yscrits
    where id = $1
    SQL
  end

  def self.get_ztext_and_wn_id(crit_id : Int32)
    PG_DB.query_one <<-SQL, crit_id, as: {String, Int32}
    select ztext, nvinfo_id from yscrits
    where id = $1
    SQL
  end
end
