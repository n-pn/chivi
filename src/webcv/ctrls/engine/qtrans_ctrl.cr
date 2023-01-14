require "../_ctrl_base"
require "../shared/qtran_data"
require "../../../_util/tran_util"

class CV::QtransCtrl < CV::BaseCtrl
  base "/api/qtran"

  struct SpecForm
    include JSON::Serializable

    getter input : String
    getter dname : String = "combine"
    getter uname : String? = nil
  end

  @[AC::Route::PUT("/mterror", body: :form)]
  def mtspec(form : SpecForm, _caps : Bool = false)
    mt_v2 = MtCore.generic_mtl(form.dname, form.uname || _viuser.uname)

    output = String.build do |io|
      mt_v2.cv_plain(form.input, cap_first: _caps).to_txt(io)
      io << '\n'
      MtCore.hanviet_mtl.translit(form.input, _caps)
    end

    render text: output
  end

  @[AC::Route::GET("/:type/:name")]
  def cached(type : String, name : String,
             user : String = _viuser.uname,
             trad : Bool = false,
             temp : Bool = false,
             _raw : Bool = false,
             _new : Bool = false,
             format : QtranData::Format = QtranData::Format::Html)
    stale = _new ? Time.utc + 10.minutes : Time.utc
    data = QtranData.load!(type, name, stale: stale)

    raise NotFound.new("Not found!") if data.input.empty?

    engine = data.make_engine(user, with_temp: temp)

    output = String.build do |io|
      data.print_mtl(engine, io, format: format, title: type == "chaps", trad: trad)
      data.print_raw(io) if _raw
    end

    render text: output
  end

  struct PostForm
    include JSON::Serializable

    getter input : String
    getter dname : String = "combine"

    def validate!
      raise BadRequest.new("Dữ liệu quá lớn") if @input.size > 10000
    end
  end

  @[AC::Route::POST("/posts", body: :form)]
  def posts_upsert(form : PostForm)
    # TODO: save posts

    form.validate!

    lines = QtranData.parse_lines(form.input)
    d_lbl = QtranData.get_d_lbl(form.dname)

    data = QtranData.new(lines, form.dname, d_lbl)
    ukey = params["ukey"]? || QtranData.post_ukey

    data.save!(ukey)
    QtranData::CACHE.set("posts/" + ukey, data)

    render json: {ukey: ukey}
  end

  record ConvertForm, input : String do
    include JSON::Serializable
  end

  @[AC::Route::PUT("/", body: :form)]
  @[AC::Route::POST("/", body: :form)]
  def convert(form : ConvertForm, dname : String = "combine", _simp : Bool = false)
    mt_v2 = MtCore.generic_mtl(dname, _viuser.uname)

    input = form.input.tr("\t", " ")
    input = TranUtil.opencc(input, "hk2s") unless params["_simp"]?

    output = String.build do |str|
      input.each_line.with_index do |line, idx|
        str << '\n' if idx > 0
        mt_v2.cv_plain(line, cap_first: true).to_txt(str)
      end
    end

    render text: output
  end
end
