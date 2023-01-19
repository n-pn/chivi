require "../_ctrl_base"
require "../../../mt_v1/vp_hint"

class CV::VpdictCtrl < CV::BaseCtrl
  base "/_db/dicts"

  alias VdInfo = Tuple(String, String, Int32) # dict name, label, entries count

  getter core_dicts : Array(VdInfo) do
    [
      {"regular", "Thông dụng", VpDict.regular.size},
      {"essence", "Nền tảng", VpDict.essence.size},
      {"fixture", "Khoá cứng", VpDict.fixture.size},
      {"$hanviet", "Hán việt", VpDict.hanviet.size},
      {"$pin_yin", "Bính âm", VpDict.pin_yin.size},
    ]
  end

  @[AC::Route::GET("/", converters: {lm: ConvertLimit}, config: {lm: {min: 24, max: 40}})]
  def index(pg pg_no : Int32 = 1, lm limit : Int32 = 24)
    offset = CtrlUtil.offset(pg_no, limit)

    total = Nvdict.query.count.to_i
    query = Nvdict.query.limit(limit).offset(offset)

    book_dicts = query.order_by(utime: :desc).map do |dict|
      {dict.dname, dict.d_lbl, dict.dsize}
    end

    render json: {
      cores: core_dicts,
      books: book_dicts,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  @[AC::Route::GET("/:dname", converters: {lm: ConvertLimit}, config: {lm: {min: 25, max: 50}})]
  def show(dname : String, pg pg_no : Int32 = 1, lm limit : Int32 = 24)
    vdict = VpDict.load(dname)

    offset = CtrlUtil.offset(pg_no, limit)
    total = offset + limit * 3
    terms = [] of VpTerm
    filter = VMatch.init(params)

    # TODO: provide cursor to search faster

    vdict.list.reverse_each do |term|
      next unless filter.match?(term)
      terms << term
      break if terms.size >= total
    end

    total = terms.size

    render json: {
      dname: dname,
      d_dub: dname[0] == '-' ? Nvdict.load!(dname[1..]).d_lbl : "",
      dsize: vdict.size,

      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),

      start: offset &+ 1,
      terms: total > offset ? terms[offset, limit] : [] of VpTerm,
    }
  end
end
