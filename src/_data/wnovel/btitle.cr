require "../_base"

class CV::Btitle
  include Crorm::Model
  schema "btitles", :postgres, strict: false

  field zname : String = "" # chinese title
  field hname : String = "" # hanviet title
  field vname : String = "" # localization

  timestamps # created_at and updated_at

  VNAMES = {} of String => {String, String}

  def self.get_names(zname : String) : {String, String}
    VNAMES[zname] ||= begin
      stmt = <<-SQL
        select coalesce(nullif(vname, ''), hname), hname
        from btitles where zname = $1 limit 1
        SQL

      PGDB.query_one?(stmt, zname, as: {String, String}) || {zname, zname}
    end
  end

  def self.upsert!(zname : String, vname : String?) : self
    hname = MT::QtCore.tl_hvname(zname)
    xname = vname || hname
    ctime = Time.utc

    PGDB.query_one <<-SQL, zname, xname, hname, ctime, ctime, vname, as: Btitle
      insert into btitles(zname, vname, hname, created_at, updated_at)
      values ($1, $2, $3, $4, $5)
      on conflict(zname) do update set
        hname = excluded.hname,
        vname = coalesce($6, btitles.vname),
        updated_at = excluded.updated_at
      returning *
      SQL
  end
end
