require "./_mt_ctrl_base"
require "./vi_term_form"
require "../core/ai_dict"

class MT::ViTermCtrl < AC::Base
  base "/_ai/terms"

  @[AC::Route::GET("/")]
  def index(dname : String,
            zstr : String? = nil,
            vstr : String? = nil,
            cpos : String? = nil,
            attr : String? = nil,
            uname : String? = nil,
            plock : Int32? = nil)
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

    terms, total = get_stats(dname.sub(':', '/'), where_stmt, args)

    json = {
      items: terms,
      start: offset &+ 1,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  private def get_stats(dname : String, where_stmt : String, args : Array(String | Int32))
    ViTerm.db(dname).open_ro do |db|
      terms = db.query_all("select * from terms #{where_stmt}", args: args, as: ViTerm)

      if terms.size < args[-2].as(Int32)
        count = terms.size
      else
        args[-2] = args[-2].as(Int32) &* 3
        count = db.query_all("select rowid from terms #{where_stmt}", args: args, as: Int32).size
      end

      {terms, count &+ args[-1].as(Int32)}
    end
  end

  private def fix_query_str(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"
    str
  end

  LOG_DIR = "var/ulogs/mtapp"
  Dir.mkdir_p(LOG_DIR)

  @[AC::Route::PUT("/once", body: :form)]
  def upsert_once(form : ViTermForm)
    _log_action("once", form, ldir: LOG_DIR)

    prev_term = form.prev_term

    min_plock = prev_term ? prev_term.plock : 0
    min_privi = ViDict.min_privi(form.dname) + min_plock

    if _privi < min_privi
      raise Unauthorized.new "Bạn cần quyền hạn tối thiểu là #{min_privi} để thêm/sửa từ"
    end

    if form.plock < min_plock && _privi < min_privi &+ 1
      raise Unauthorized.new "Từ đã bị khoá, bạn cần quyền hạn tối thiểu là #{min_privi + 1} để đổi khoá"
    end

    spawn form.save_to_disk!(_uname, on_create: prev_term.nil?)

    form.sync_with_dict!
    render text: "ok"
  end

  @[AC::Route::GET("/find")]
  def show(dict : String, zstr : String, cpos : String)
    dict = dict.sub(':', '/')
    term = ViTerm.find(dict: dict, zstr: zstr, cpos: cpos)

    if term
      render json: term
    else
      render :not_found, text: "Không tồn tại"
    end
  end
end
