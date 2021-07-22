class CV::BaseCtrl < Amber::Controller::Base
  LAYOUT = false

  protected getter cu_dname : String { session["cu_uname"]? || "Khách" }
  protected getter cu_uname : String { cu_dname.downcase }
  protected getter cu_privi : Int32 { session["cu_privi"]?.try(&.to_i?) || ViUser.get_power(cu_uname) }
  protected getter cu_wtheme : String { session["cu_wtheme"]? || ViUser.get_wtheme(cu_uname) }
  protected getter cu_tlmode : Int32 { session["cu_tlmode"]?.try(&.to_i?) || ViUser.get_tlmode(cu_uname) }

  def add_etag(etag : String)
    response.headers.add("ETag", etag)
  end

  def cache_control(type = "public", max_age = 0)
    if max_age > 0
      control = "#{type}, max-age=#{max_age * 60}"
      response.headers.add("Cache-Control", control)
    end
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

  def save_session!
    return unless session.changed?

    session.set_session
    cookies.write(response.headers)
  end

  def render_json(status_code = 200)
    response.status_code = status_code
    response.content_type = "application/json"

    yield response
  end

  def halt!(status_code : Int32 = 200, content = "")
    response.headers["Content-Type"] = "text/plain; charset=UTF-8"
    response.status_code = status_code
    response.puts(content)
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
