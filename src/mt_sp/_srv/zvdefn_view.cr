require "../data/pg_dict"

class SP::ZvdefnView
  def self.fetch_all(
    dict : String? = nil, zstr : String? = nil, cpos : String? = nil,
    vstr : String? = nil, attr : String? = nil, rank : Int16? = nil,
    user : String? = nil, lock : Int16? = nil,
    limit : Int32 = 50, offset : Int32 = 0
  )
    args = [] of String | Int32 | Int16

    where_stmt = String.build do |sql|
      sql << " where 1 = 1"

      if dict
        args << dict
        sql << " and dict = $1"
      end

      if zstr
        args << fix_query_str(zstr)
        sql << " and zstr like $" << args.size
      end

      if cpos
        args << cpos
        sql << " and cpos = $" << args.size
      end

      if vstr
        args << fix_query_str(vstr)
        sql << " and vstr like $" << args.size
      end

      if attr
        args << fix_query_str(attr)
        sql << " and attr like $" << args.size
      end

      if rank
        args << rank
        sql << " and rank like $" << args.size
      end

      if user
        args << user
        sql << " and _user = $" << args.size
      end

      if lock
        args << lock
        sql << " and _lock = $" << args.size
      end

      sql << " order by _time desc"

      args << limit
      sql << " limit $" << args.size

      args << offset
      sql << " offset $" << args.size
    end

    terms = PGDB.query_all("select * from zvdefns #{where_stmt}", args: args, as: Zvdefn)

    if terms.size < args[-2].as(Int32)
      count = terms.size
    else
      args[-2] = limit &* 3
      count = PGDB.query_all("select id from zvdefns #{where_stmt}", args: args, as: Int32).size
    end

    {terms, offset &+ count}
  end

  private def self.fix_query_str(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"
    str
  end
end
