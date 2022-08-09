class CV::BaseCtrl < Amber::Controller::Base
  LAYOUT = false

  protected getter u_dname : String { session["uname"]? || "Khách" }
  protected getter _viuser : Viuser { Viuser.load!(u_dname) }

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

  private def read_chidx(param : String = "chidx", max : Int32? = nil) : Int32
    idx = params.read_int(param, min: 1)
    max && max < idx ? max : idx
  end

  private def load_nvinfo : Nvinfo
    nv_id = params["nv_id"].to_i64
    Nvinfo.load!(nv_id) || raise NotFound.new("Quyển sách không tồn tại")
  end

  enum ChrootLoadMode
    Auto # guess from type
    Init # create new one if not exist
    Find # raise missing if not exist
  end

  private def load_chroot(sname : String = params["sname"],
                          mode : ChrootLoadMode = :auto)
    case sname
    when "=base", "=user"
      Chroot.load!(load_nvinfo, sname, force: !mode.find?)
    when "=self", "@" + _viuser.uname
      Chroot.load!(load_nvinfo, "@" + _viuser.uname, force: !mode.find?)
    else
      Chroot.load!(load_nvinfo, sname, force: mode.init?)
    end
  end

  private def guard_privi(min : Int8 = 0)
    raise Unauthorized.new("Quyền hạn không đủ!") if _viuser.privi < min
  end

  private def load_chinfo(chroot : Chroot, chidx : Int32 = read_chidx)
    chroot.chinfo(chidx) || raise NotFound.new("Chương tiết không tồn tại")
  end

  def assert_privi(privi : Int32 = 1)
    raise Unauthorized.new("Bạn không đủ quyền hạn") if _viuser.privi < privi
  end
end
