require "../../_data/_data"
require "../data/tsrepo"

class RD::UpstemView
  class_getter db : DB::Database = PGDB

  ###

  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  getter sroot : String
  getter owner : Int32

  getter sn_id : Int32
  getter sname : String

  getter zname : String
  getter vname : String

  getter vintro : String
  getter labels : Array(String)

  getter multp : Int16
  getter guard : Int16

  getter wn_id : Int32?
  getter wndic : Bool

  getter chmax : Int32

  getter mtime : Int64
  getter rtime : Int64 = 0_i64

  getter view_count : Int32 = 0
  getter like_count : Int32 = 0
  getter star_count : Int32 = 0

  #####

  def self.find(id : Int32, sname : Nil = nil)
    query = "select * from upstems_view where sn_id = $1 limit 1"
    self.db.query_one?(query, id, as: self)
  end

  def self.find(id : Int32, sname : String)
    query = "select * from upstems_view where sn_id = $1 and sname = $2 limit 1"
  end

  def self.build_select_sql(uname : String? = nil,
                            wn_id : Int32? = nil, label : String? = nil,
                            title : String? = nil, liked : Int32? = nil,
                            order : String = "mtime")
    args = [guard] of String | Int32

    query = String.build do |sql|
      sql << "select * from upstems_view"

      if uname
        args << uname
        sql << " and sname = '@' || $2"
      end

      if wn_id
        args << wn_id
        sql << " and wn_id = $#{args.size}"
      end

      if label
        args << label
        sql << " and $#{args.size} = any(labels)"
      end

      if title
        args << title
        getter = title =~ /\p{Han}/ ? "zname" : "vname"
        sql << " and #{getter} ilike '%' || $#{args.size} || '%'"
      end

      if liked
        args << liked
        sql << <<-SQL
            and id in (
            select sn_id::int from rdmemos
            where vu_id = $#{args.size} and sname like 'up%' and rd_track > 0
          )
          SQL
      end

      case order
      when "mtime" then sql << " order by mtime desc"
      when "chaps" then sql << " order by chap_count desc"
      when "views" then sql << " order by view_count desc"
      else              sql << " order by sn_id desc"
      end

      sql << " limit $#{args.size &+ 1} offset $#{args.size &+ 2}"
    end

    {query, args}
  end
end
