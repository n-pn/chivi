require "./_mt_ctrl_base"

require "../data/vi_dict"
require "../data/vi_term"

class MT::ViDictCtrl < AC::Base
  base "/_ai/dicts"

  @[AC::Route::GET("/")]
  def index(dtype : ViDict::Dtype = ViDict::Dtype::None)
    pg_no, limit, offset = _paginate(min: 10, max: 100)

    total = ViDict.count(dtype)
    dicts = ViDict.get_all(dtype, limit, offset)
    output = {
      dicts: dicts,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/:dname")]
  def show(dname : String)
    dname = dname.sub(':', '/')

    dict = ViDict.find(dname) || begin
      raise NotFound.new("từ điển không tồn tại") unless dname.starts_with?("book/")
      ViDict.new(dname, :book, dname, dname)
    end

    json = {
      dname: dict.dname,
      dtype: dict.dtype.to_s.downcase,
      label: dict.label,
      descs: dict.descs,
      total: dict.total,
      mtime: ViTerm.utime(dict.mtime),
      users: dict.users.split(',', remove_empty: true),
      terms: ViTerm.get_all(db: ViTerm.db(dname), &.<< "order by mtime limit 10")
    }

    render json: json
  end

  @[AC::Route::GET("/:dname/terms")]
  def terms(dname : String,
            zstr : String? = nil,
            vstr : String? = nil,
            cpos : String? = nil,
            prop : String? = nil,
            uname : String? = nil,
            privi : Int32? = nil)
    pg_no, limit, offset = _paginate(min: 10, max: 100)

    args = [] of String | Int32

    where_stmt = String.build do |sql|
      sql << " where 1 = 1"
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

      if prop
        args << fix_query_str(prop)
        sql << " and prop like $" << args.size
      end

      if uname
        args << uname
        sql << " and uname = $" << args.size
      end

      if privi
        args << privi
        sql << " and privi = $" << args.size
      end

      sql << " order by mtime desc"

      args << limit
      sql << " limit $" << args.size

      args << offset
      sql << " offset $" << args.size
    end

    terms, count = get_stats(dname.sub(':', '/'), where_stmt, args)

    json = {
      terms: terms,
      start: offset &+ 1,
      pgidx: pg_no,
      pgmax: _pgidx(count, limit),
    }

    render json: json
  end

  private def get_stats(dname : String, where_stmt : String, args : Array(String | Int32))
    ViTerm.db(dname).open_ro do |db|
      terms = db.query_all("select * from terms #{where_stmt}", args: args, as: ViTerm)

      args[-2] = args[-2].as(Int32) &* 3
      count = db.query_one("select count(*) from terms #{where_stmt}", args: args, as: Int32)

      {terms, count &+ args[-2].as(Int32)}
    end
  end

  private def fix_query_str(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"
    str
  end
end
