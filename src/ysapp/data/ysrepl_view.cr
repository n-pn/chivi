require "./_data"

struct YS::YsreplPeek
  include DB::Serializable
  include JSON::Serializable

  getter yu_id : Int32
  getter uname : String
  getter u_pic : String

  getter ctime : Int64
  getter vhtml : String

  @[JSON::Field(ignore: true)]
  getter ztext : String
  @[JSON::Field(ignore: true)]
  getter vi_bd : String?

  getter like_count : Int32
  getter repl_count : Int32

  def self.fetch_all(yscrit_id : Int32, limit = 100, offset = 0)
    PG_DB.query_all <<-SQL, yscrit_id, limit, offset, as: self
    select
      u.id as yu_id,
      u.vname as uname,
      u.y_avatar as u_pic,
      r.ztext,
      r.vhtml,
      r.vi_bd,
      extract(epoch from r.created_at)::bigint as ctime,
      r.like_count,
      r.repl_count
    from ysrepls as r
      inner join ysusers as u
      on u.id = r.ysuser_id
    where r.yscrit_id = $1
    order by r.created_at asc
    limit $2 offset $3
    SQL
  end

  def vhtml
    if vi_bd = @data.vi_bd
      to_html(vi_bd)
    elsif !@vhtml.blank?
      @vhtml
    else
      # TODO: call translation!
      to_html(@ztext)
    end
  end

  def to_html(input : String)
    input.lines.join('\n') { |line| "<p>#{line.gsub('<', "&gt;")}</p>" }
  end

  def self.get_ztext(repl_id : Int32)
    PG_DB.query_one <<-SQL, repl_id, as: String
    select coalesce(ztext, '') from ysrepls
    where id = $1
    SQL
  end
end
