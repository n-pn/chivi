class CV::BaseCtrl < Amber::Controller::Base
  LAYOUT = false

  @cu_uname : String?
  @cu_privi : Int32?

  # current user username
  protected def cu_uname
    @cu_uname ||= session["cu_uname"]? || "Khách"
  end

  # current user priviedge
  protected def cu_privi : Int32
    @cu_privi ||= ViUser.get_power(cu_uname)
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
    if session.changed?
      puts "Saving session!"

      session.set_session
      cookies.write(response.headers)
    end
  end

  def render_json(status_code = 200)
    response.status_code = status_code
    response.content_type = "application/json"

    save_session!
    yield response
  end

  def clamp(val : Int32, min = 0, max = 100)
    val < min ? min : (val > max ? max : val)
  end
end

class Amber::Validators::Params
  def fetch(name : String | Symbol, df = "")
    self[name]? || df
  end

  def fetch_int(name : String | Symbol, df = 0)
    self[name]?.try(&.to_i?) || df
  end
end
