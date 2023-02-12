require "../data/v1_dict"
require "../data/v1_defn"

require "./_m1_ctrl_base"
require "./m1_defn_form"

class M1::DefnCtrl < AC::Base
  base "/_m1"

  @[AC::Route::GET("/defns")]
  def index(dic : String?, tab : Int32?,
            key : String?, val : String?,
            ptag : String?, prio : Int32?,
            uname : String?)
    pg_no, limit, offset = _paginate(min: 50, max: 100)

    query, args = build_query(params, limit, offset)
    terms = DbDefn.repo.open_db { |db| db.query_all query, args: args, as: DbDefn }

    total = terms.size
    if total == limit
      total = DbDefn.repo.open_db do |db|
        query = query.sub("select * ", "select count (*) ")
        args[-2] = args[-2].as(Int32) + limit * 2
        args[-1] = 0
        db.query_one(query, args: args, as: Int32)
      end
    end

    render json: {
      terms: terms,
      total: total,
      pgidx: pg_no,
      start: offset + 1,
      pgmax: _pgidx(total, limit),
    }
  end

  private def build_query(params, limit, offset)
    args = [] of DB::Any

    query = String.build do |sql|
      sql << "select * from defns where _flag > -2"

      if dic = _get_str("dic")
        sql << " and dic = ?"
        args << DbDict.get_id(dic)
      end

      if tab = _get_int("tab")
        sql << " and tab = ?"
        args << tab
      end

      if key = _get_str("key")
        sql << " and key like ?"
        args << regex_to_like(key)
      end

      if val = _get_str("val")
        sql << " and val like ?"
        args << regex_to_like(val)
      end

      if ptag = _get_str("ptag")
        sql << " and ptag = ?"
        args << ptag
      end

      if prio = _get_int("prio")
        sql << " and prio = ?"
        args << prio
      end

      if uname = _get_str("uname")
        sql << " and uname = ?"
        args << uname
      end

      sql << " order by id desc"
      sql << " limit ? offset ?"

      args << limit << offset
    end

    {query, args}
  end

  private def regex_to_like(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"

    str
  end

  @[AC::Route::POST("/defns", body: :form)]
  def create(form : DefnForm)
    form.validate!(_privi)

    defn = form.save!(_uname)
    sync_data!(form.vdict, defn)

    spawn do
      date = Time.local.to_s("%Y-%m/%d")
      log_file = "var/dicts/v1log/#{date}.jsonl"

      Dir.mkdir_p(File.dirname(log_file))
      File.open(log_file, "a", &.puts(form.to_json))
    end

    render json: defn
  end

  private def sync_data!(dict : DbDict, defn : DbDefn)
    dict.update_after_term_added!(defn.mtime)

    case defn.tab
    when 0, 1 # add to main dict
      MtDict::TEMPS[dict.id]?.try(&.remove_term(defn.key))
      MtDict::MAINS[dict.id]?.try(&.add_defn(defn))
    when 2 # add to temp dict
      MtDict::TEMPS[dict.id]?.try(&.add_defn(defn))
    when 3 # add to user dict
      MtDict::TEMPS[dict.id]?.try(&.remove_term(defn.key))
      MtDict::USERS["#{dict.id}/#{defn.uname}"]?.try(&.add_defn(defn))
    end
  end
end
