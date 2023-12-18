require "../_base"

record CV::BookUser, uname : String, privi : Int32, track : Int16, ch_no : Int32 do
  include DB::Serializable
  include JSON::Serializable

  def self.of_book(wn_id : Int32)
    PGDB.query_all <<-SQL, wn_id, as: BookUser
    select
      u.uname as uname, u.privi as privi,
      m.rd_state as track, m.lc_ch_no as ch_no
    from rdmemos as m
      inner join viusers as u
      on u.id = m.vu_id
    where m.sn_id = $1
      and m.sname = '~avail'
      and u.privi > -2
    order by m.rtime desc, m.atime desc
  SQL
  end
end
