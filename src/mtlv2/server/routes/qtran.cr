require "../../../libcv/qtran_data"

class CV::QtranData
  getter simps : Array(String) do
    @input.map { |x| MtlV2::MtCore.trad_to_simp(x) }
  end

  def make_engine(uname : String)
    MtlV2::MtCore.generic_mtl(@dname, uname)
  end
end

class MtlV2::QtranCtrl < MtlV2::BaseCtrl
  base "/"

  @[AC::Route::POST("/_v2/qtran/:type")]
  def convert(type : String)
    input = params["input"]
    rmode = params["mode"]? || "text"

    case type
    when "hanviet"
      apply_cap = params["apply_cap"]? == "true"
      tokens = MtCore.hanviet_mtl.translit(input, apply_cap)
      render text: rmode == "text" ? tokens.to_s : token.to_str
    when "tradsim"
      render text: MtCore.tradsim_mtl.translit(input).to_s
    else
      raise "Unsupported"
    end
  end

  @[AC::Route::GET("/_v2/qtran/:type/:name")]
  def cached(type : String, name : String, user = "")
    data = CV::QtranData.load_cached(name, type) do
      raise "bad_request: not found!"
    end

    respond_with do
      text do
        String.build do |io|
          engine = data.make_engine(user)
          format = CV::QtranData::Format.parse(params["mode"]? || "node")
          trad = params["trad"]? == "true"

          data.print_mtl(engine, io, format: format, title: type == "chaps", trad: trad)
          data.print_raw(io) if params["_raw"]?
        end
      end
    end

    # response = context.response
    # # response.status_code = 200
    # # response.content_type = "text/plain; charset=utf-8"

    # engine = data.make_engine(user)
    # format = QtranData::Format.parse(params["mode"]? || "node")

    # title = false
    # trad = params["trad"]? == "true"

    # data.print_mtl(engine, response, format: format, title: title, trad: trad)
    # data.print_raw(response) if params["_raw"]?
  end

  @[AC::Route::DELETE("/_v2/purge/:type")]
  def uncache(type : String)
    disk = params["disk"]? == "true"
    CV::QtranData.clear_cache(type, disk: disk)
    render json: {msg: "ok"}
  end
end
