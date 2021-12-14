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
end

class CV::BaseCtrl < Amber::Controller::Base
  LAYOUT = false

  protected getter u_dname : String { session["u_dname"]? || "Khách" }
  protected getter _cvuser : Cvuser { Cvuser.load!(u_dname) }
  protected getter u_privi : Int32 { _cvuser.privi }

  enum CacheType
    Private; Public
  end

  def cache_rule(type : CacheType, max_age = 30, max_stale = 120, etag = "")
    response.headers.add("ETag", etag) unless etag.empty?
    response.headers.add("Cache-Control", "#{type}, max-age=#{max_age}, stale-while-revalidate=#{max_stale}")
  end

  def add_etag(etag : String)
    response.headers.add("ETag", etag)
  end

  def cache_control(type = "public", max_age = 0)
    if max_age > 0
      control = "#{type}, max-age=#{max_age * 60}"
      response.headers.add("Cache-Control", control)
    end
  end

  def save_session!
    return unless session.changed?

    session.set_session
    cookies.write(response.headers)
  end

  def render_json(data : String, status_code = 200)
    render_json(status_code) do |res|
      res.puts(data)
    end
  end

  def render_json(data : Object, status_code = 200)
    render_json(status_code) do |res|
      data.to_json(response)
    end
  end

  def render_json(status_code = 200)
    response.status_code = status_code
    response.content_type = "application/json"

    yield response
  end

  def json_view(status_code = 200)
    response.status_code = status_code
    response.content_type = "application/json"

    if session.changed?
      session.set_session
      cookies.write(response.headers)
    end

    JSON.build(response) { |jb| yield jb }
  end

  def json_view(data : Object, status_code = 200)
    json_view(status_code) { |jb| data.to_json(jb) }
  end

  def halt!(status_code : Int32 = 200, content = "")
    response.headers["Content-Type"] = "text/plain; charset=UTF-8"
    response.status_code = status_code
    response.puts(content)
  end

  def pgmax(total : Int32 | Int64, limit : Int32)
    (total - 1) // limit + 1
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
end
