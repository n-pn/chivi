require "../../../libcv/qtran_data"

class CV::MtlV2::QtranData < Libcv::QtranData
  getter simps : Array(String) do
    @input.map { |x| CV::MtlV2::MtCore.trad_to_simp(x) }
  end

  def make_engine(uname : String)
    CV::MtlV2::MtCore.generic_mtl(@dname, uname)
  end
end

class CV::MtlV2::QtranCtrl < CV::MtlV2::BaseCtrl
  base "/"

  @[AC::Route::GET("/")]
  def index
    welcome_text = "You're being trampled by Spider-Gazelle!"
    Log.warn { "logs can be collated using the request ID" }

    # You can use signals to change log levels at runtime
    # USR1 is debugging, USR2 is info
    # `kill -s USR1 %APP_PID`
    Log.debug { "use signals to change log levels at runtime" }

    welcome_text
  end

  @[AC::Route::GET("/_v2/qtran/:type/:name")]
  def qtran(type : String, name : String, user = "")
    file = QtranData.path(name, type)

    unless data = QtranData.load(file)
      render :bad_request, text: "Not found!"
      return
    end

    respond_with do
      text do
        String.build do |io|
          engine = data.make_engine(user)
          format = QtranData::Format.parse(params["mode"]? || "node")
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
end
