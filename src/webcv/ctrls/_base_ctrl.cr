module CV::CtrlUtil
  extend self

  def d_dub(dname : String)
    case dname
    when "cc_cedict" then "CC-CEDICT"
    when "trungviet" then "Trung Việt"
    when "hanviet"   then "Hán Việt"
    when "pin_yin"   then "Bính âm"
    when "tradsim"   then "Phồn giản"
    when "regular"   then "Thông dụng"
    when "essence"   then "Nền tảng"
    when "fixture"   then "Khoá cứng"
    else
      Nvinfo.find({bhash: dname}).try(&.vname) || dname
    end
  end

  def pgmax(total : Int32 | Int64, limit : Int32)
    (total - 1) // limit + 1
  end
end

class CV::BaseCtrl < Amber::Controller::Base
  LAYOUT = false

  protected getter u_dname : String { session["uname"]? || "Khách" }
  protected getter _cvuser : Cvuser { Cvuser.load!(u_dname) }

  enum CacheType
    Private; Public
  end

  enum ContentType
    Json; Text
  end

  @cache_type = CacheType::Public
  @maxage = 0 # max age in seconds

  def set_cache(@cache_type : CacheType = CacheType::Public, @maxage = 3)
  end

  def set_headers(status = 200, content_type : ContentType = :json)
    response.status_code = status

    case content_type
    when .json?
      response.content_type = "application/json; charset=utf-8"
    when .text?
      response.content_type = "text/plain; charset=utf-8"
    end

    if @maxage > 0
      response.headers.add("Cache-Control", "#{@cache_type}, max-age=#{@maxage}")
    end
  end

  def save_session!
    return unless session.changed?
    session.set_session
    cookies.write(response.headers)
  end

  def send_json(props : Object, status = 200)
    set_headers(status, :json)
    body = {status: status, props: props, maxage: @maxage}
    response.puts(body.to_json)
  end

  def send_json(status = 200)
    set_headers(status, :json)
    JSON.build(response) do |jb|
      jb.object {
        jb.field "status", status
        jb.field "props" { yield jb }
        jb.field "maxage", @maxage
      }
    end
  end

  def halt!(status : Int32 = 200, error : String = "")
    response.status_code = status
    response.content_type = "application/json"

    response.puts({status: status, error: error}.to_json)
  end
end

class Amber::Validators::Params
  def fetch_str(name : String | Symbol, df = "") : String
    self[name]? || df
  end

  def fetch_str(name : String, &block : -> String) : String
    self[name]? || yield
  end

  def fetch_int(name : String | Symbol, min = 0, max = Int32::MAX) : Int32
    val = self[name]?.try(&.to_i?) || 0
    val < min ? min : (val > max ? max : val)
  end

  def fetch_int(name : String | Symbol, &block : -> Int32) : Int32
    self[name]?.try(&.to_i?) || yield
  end

  def page_info(min = 1, max = 100) : Tuple(Int32, Int32, Int32)
    pgidx = fetch_int("pg", min: 1)
    limit = fetch_int("lm", min, max)
    {pgidx, limit, limit &* (pgidx - 1)}
  end
end
