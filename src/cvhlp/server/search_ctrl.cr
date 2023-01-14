require "./_shared"

require "../../mt_v2/cv_data/cv_dict"
require "../../mt_v2/cv_data/cv_term"

class TL::SearchCtrl < TL::BaseCtrl
  base "/_mh"

  @[AC::Route::GET("/dicts")]
  def index(page : Int32 = 1, take : Int32 = 20)
    pgidx, limit, offset = fix_paged(page, take)

    total = MT::CvDict.total_books.to_i
    cores = [MT::CvDict.get!(1)]
    books = MT::CvDict.fetch_books(limit: limit, offset: offset)

    output = {
      cores: cores.map(&.tuple),
      books: books.map(&.tuple),
      total: total,
      pgidx: pgidx,
      pgmax: calc_pgmax(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/dicts/:name")]
  def query(name : String,
            key : String?, val : String?, ptag : String?, prio : String?,
            page : Int32 = 1, take : Int32 = 50)
    dict = MT::CvDict.find!(name)
    type = dict.id < 0 ? "book" : "core"

    pgidx, limit, offset = fix_paged(page, take)
    args = [dict.id, -dict.id] of DB::Any

    args << fix_str(key) if key
    args << fix_str(val) if val
    args << ptag if ptag
    args << map_seg(prio) if prio
    args << limit << offset

    terms = MT::CvTerm.open_db(type) do |db|
      find_query = build_search_query("*", key, val, ptag, prio)
      db.query_all find_query, args: args, as: MT::CvTerm
    end

    total = MT::CvTerm.open_db(type) do |db|
      args[-2] = args[-2].as(Int32) + limit * 2
      total_query = build_search_query("id", key, val, ptag, prio)
      db.query_all(total_query, args: args, as: Int32).size
    end

    output = {
      dname: dict.name,
      d_dub: dict.label,
      dsize: dict.dsize,

      total: total,
      pgidx: pgidx,
      pgmax: calc_pgmax(total, limit),

      start: offset &+ 1,
      terms: terms,
    }

    render json: output
  end

  private def map_seg(prio : String)
    case prio
    when "^" then 3
    when "v" then 1
    when "x" then 0
    else          2
    end
  end

  private def fix_str(str : String)
    str = str.starts_with?('^') ? str[1..] : "%" + str
    str = str.ends_with?('$') ? str[..-2] : str + "%"

    str
  end

  private def build_search_query(selects : String, key : String?, val : String?, ptag : String?, prio : String?)
    String.build do |str|
      str << "select #{selects} from terms where dic = ? or dic = ?"
      str << " and key like ?" if key
      str << " and val like ?" if val
      str << " and ptag like ?" if ptag
      str << " and wseg = ?" if prio
      str << " order by id desc"
      str << " limit ? offset ?"
    end
  end
end
