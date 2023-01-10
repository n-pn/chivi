require "../_ctrl_base"
require "../shared/qtran_data"
require "../../../_util/tran_util"

class CV::QtransCtrl < CV::BaseCtrl
  base "/api/qtran"

  @[AC::Route::PUT("/mterror", body: :input)]
  def mtspec(input : String,
             dname : String = "combine", uname : String = _viuser.uname,
             _caps : Bool = false)
    response.headers["Content-Type"] = "text/plain; charset=utf8"

    cvmtl = MtCore.generic_mtl(dname, uname)

    output = String.build do |io|
      cvmtl.cv_plain(input, cap_first: _caps).to_txt(io)
      io << '\n'
      MtCore.hanviet_mtl.translit(input, _caps)
    end

    render text: output
  end

  @[AC::Route::GET("/:type/:name")]
  def convert(type : String, name : String, _new : Bool = false,
              trad : Bool = false,
              user : String = _viuser.uname,
              temp : Bool = false,
              format : QtranData::Format = QtranData::Format::Html)
    stale = _new ? Time.utc + 10.minutes : Time.utc
    data = QtranData.load!(type, name, stale: stale)
    raise NotFound.new("Not found!") if data.input.empty?

    engine = data.make_engine(user, with_temp: temp)

    output = String.build do |io|
      data.print_mtl(engine, io, format: format, title: type == "chaps", trad: trad)
      data.print_raw(io) if params["_raw"]?
    end

    render text: output
  end

  @[AC::Route::POST("/posts")]
  def posts_upsert
    # TODO: save posts
    input = params["input"]
    dname = params["dname"]? || "combine"

    raise BadRequest.new("Dữ liệu quá lớn") if input.size > 10000

    lines = QtranData.parse_lines(input)
    d_lbl = QtranData.get_d_lbl(dname)

    data = QtranData.new(lines, dname, d_lbl)
    ukey = params["ukey"]? || QtranData.post_ukey

    data.save!(ukey)
    QtranData::CACHE.set("posts/" + ukey, data)

    render json: {ukey: ukey}
  end

  @[AC::Route::PUT("/webpage")]
  @[AC::Route::POST("/webpage")]
  def webpage(dname : String = "combine", _simp : Bool = false)
    cvmtl = MtCore.generic_mtl(dname, _viuser.uname)

    input = params["input"].tr("\t", " ")
    input = TranUtil.opencc(input, "hk2s") unless params["_simp"]?

    output = String.build do |str|
      input.each_line.with_index do |line, idx|
        str << '\n' if idx > 0
        cvmtl.cv_plain(line, cap_first: true).to_txt(str)
      end
    end

    render text: output
  end
end
