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
    body = {status: status, props: props, cache: {maxage: @maxage}}
    response.puts(body.to_json)
  end

  def send_json(status = 200)
    set_headers(status, :json)

    JSON.build(response) do |jb|
      jb.object {
        jb.field "status", status
        jb.field "props" { yield jb }
        jb.field "cache", {maxage: @maxage}
      }
    end
  end

  def serv_json(object : Object, status = 200)
    set_headers(status, :json)
    response.puts(object.to_json)
  end

  def serv_json(status = 200)
    set_headers(status, :json)
    JSON.build(response) { |jb| yield jb }
  end

  def serv_text(object : Object, status = 200)
    set_headers(status, :text)
    response.puts(object.to_s)
  end

  def halt!(status : Int32 = 200, error : String = "")
    set_headers(status, :json)
    response.puts({status: status, error: error}.to_json)
  end

  private def load_nvinfo : Nvinfo
    nv_id = params["nv_id"].to_i64
    Nvinfo.load!(nv_id) || raise NotFound.new("Quyển sách không tồn tại")
  end

  private def load_nvseed(force = false)
    case sname = params["sname"]
    when "=base", "=user"
      Nvseed.load!(load_nvinfo, sname, force: true)
    when "=self", "@" + _cvuser.uname
      Nvseed.load!(load_nvinfo, "@" + _cvuser.uname, force: true)
    else
      Nvseed.load!(load_nvinfo, sname, force: false)
    end
  end
end
