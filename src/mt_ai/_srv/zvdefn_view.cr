require "../data/pg_dict"

class MT::ZvdefnView
  def self.fetch_all(
    d_id : Int32,
    zstr : String? = nil,
    vstr : String? = nil,
    cpos : String? = nil,
    attr : String? = nil,
    uname : String? = nil,
    plock : Int16? = nil,
    limit : Int32 = 50,
    offset : Int32 = 0
  )
    args = [d_id] of String | Int32 | Int16

    where_stmt = String.build do |sql|
      sql << " where d_id = $1"

      if cpos
        args << MtEpos.parse(cpos).value.to_i16
        sql << " and ipos = $" << args.size
      end

      if zstr
        args << fix_query_str(zstr)
        sql << " and zstr like $" << args.size
      end

      if vstr
        args << fix_query_str(vstr)
        sql << " and vstr like $" << args.size
      end

      if attr
        args << fix_query_str(attr)
        sql << " and attr like $" << args.size
      end

      if uname
        args << uname
        sql << " and uname = $" << args.size
      end

      if plock
        args << plock
        sql << " and plock = $" << args.size
      end

      sql << " order by mtime desc"

      args << limit
      sql << " limit $" << args.size

      args << offset
      sql << " offset $" << args.size
    end

    terms = PgDefn.db.query_all("select * from zvterm #{where_stmt}", args: args, as: PgDefn)

    if terms.size < args[-2].as(Int32)
      count = terms.size
    else
      args[-2] = limit &* 3
      count = PgDefn.db.query_all("select d_id from zvterm #{where_stmt}", args: args, as: Int32).size
    end

    {terms, offset &+ count}
  end

  private def self.fix_query_str(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"
    str
  end
end
