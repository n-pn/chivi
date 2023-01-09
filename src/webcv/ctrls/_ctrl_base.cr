require "../../appcv/*"
require "./_curr_user"
require "./_ctrl_util"

require "action-controller"

class NotFound < Exception; end

class BadRequest < Exception; end

class Unauthorized < Exception; end

abstract class CV::BaseCtrl < ActionController::Base
  base "/api"

  Log = Log.for("controller")

  add_parser("text/plain") { |_klass, body_io| body_io.gets_to_end }

  add_responder("*/*") { |io, result| result.to_json(io) }
  add_responder("text/plain") { |io, result| io << result }
  add_responder("application/json") { |io, result| result.to_json(io) }

  # @[AC::Route::Filter(:before_action)]
  # def set_request_id
  #   request_id = request.headers["X-Request-ID"]? || UUID.random.to_s
  #   Log.context.set client_ip: client_ip, request_id: request_id
  #   response.headers["X-Request-ID"] = request_id
  # end

  @[AC::Route::Filter(:before_action)]
  def set_date_header
    response.headers["Date"] = HTTP.format_time(Time.utc)
  end

  # handle common errors at a global level
  # this covers no acceptable response format and not an acceptable post format
  @[AC::Route::Exception(AC::Route::NotAcceptable, status_code: HTTP::Status::NOT_ACCEPTABLE)]
  @[AC::Route::Exception(AC::Route::UnsupportedMediaType, status_code: HTTP::Status::UNSUPPORTED_MEDIA_TYPE)]
  def bad_media_type(error)
    {
      error:   error.message,
      accepts: error.accepts,
    }
  end

  @[AC::Route::Exception(AC::Route::Param::MissingError, status_code: HTTP::Status::BAD_REQUEST)]
  @[AC::Route::Exception(AC::Route::Param::ValueError, status_code: HTTP::Status::BAD_REQUEST)]
  def invalid_param(error)
    {
      error:       error.message,
      parameter:   error.parameter,
      restriction: error.restriction,
    }
  end

  @[AC::Route::Exception(BadRequest, status_code: HTTP::Status::BAD_REQUEST)]
  def bad_request(error)
    {error: error.message}
  end

  @[AC::Route::Exception(NotFound, status_code: HTTP::Status::NOT_FOUND)]
  def not_found(error)
    {error: error.message}
  end

  @[AC::Route::Exception(Unauthorized, status_code: HTTP::Status::FORBIDDEN)]
  def unauthorized(error)
    {error: error.message}
  end

  USER_CACHE = {} of String => CurrentUser

  getter _viuser : CurrentUser do
    case
    when token = cookies["_user"]? then CurrentUser.from_user_token(token.value)
    when uname = session["uname"]? then CurrentUser.from_sess_uname(uname)
    else                                CurrentUser.guest
    end
  rescue
    CurrentUser.guest
  end

  private def get_nvinfo(b_id : Int64) : Nvinfo
    Nvinfo.load!(b_id) || raise NotFound.new("Quyển sách không tồn tại")
  end

  enum ChrootLoadMode
    Auto # guess from type
    Init # create new one if not exist
    Find # raise missing if not exist
  end

  private def get_chroot(b_id : Int64, sname : String, load_mode : ChrootLoadMode = :auto)
    nvinfo = get_nvinfo(b_id)

    case sname
    when "=base"
      Chroot.load!(nvinfo, sname, force: !mode.find?)
    when "@" + _viuser.uname
      Chroot.load!(nvinfo, "@" + _viuser.uname, force: !mode.find?)
    else
      Chroot.load!(nvinfo, sname, force: mode.init?)
    end
  end

  private def get_chinfo(chroot : Chroot, ch_no : Int32)
    chroot.chinfo(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  def save_current_user!(user : Viuser) : Ni
    user_token = CjwtUtil.encode_user_token(user.id, user.uname, user.privi)
    USER_CACHE[user_token] = CurrentUser.new(user.id, user.uname, user.privi)

    session["uname"] = user.uname
    cookies.set "_user", user_token, expires: 30.minutes.from_now
  end

  private def guard_privi(min = 0)
    raise Unauthorized.new("Quyền hạn không đủ!") if _viuser.privi < min
  end

  private def allowed?(owner_id : Int32 = -2)
    privi = _viuser.privi
    privi < 0 ? false : privi > 3 ? true : _viuser.id == owner_id
  end
end

# class CV::BaseCtrl < Amber::Controller::Base
#   LAYOUT = false

#   # protected getter u_dname : String { session["uname"]? || "Khách" }
#   protected getter u_dname : String { get_uname_from_jwt }

#   private def get_uname_from_jwt
#     token = cookies["cv_rt"]
#     `bin/cvjwt_cli dr "#{token}"`.strip
#   rescue
#     "Khách"
#   end

#   protected getter u_privi : Int32 do
#     token = cookies["cv_at"]
#     _user, privi = `bin/cvjwt_cli da "#{token}"`.split("\n")
#     privi.to_i
#   rescue
#     -1
#   end

#   protected getter _viuser : Viuser do
#     Viuser.load!(u_dname)
#   rescue err
#     Log.error { err.message }
#     Viuser.load!("Khách")
#   end

#   enum CacheType
#     Private; Public
#   end

#   enum ContentType
#     Json; Text
#   end

#   @cache_type = CacheType::Public
#   @maxage = 0 # max age in seconds

#   def set_cache(@cache_type : CacheType = CacheType::Public, @maxage = 3)
#   end

#   def set_headers(status = 200, content_type : ContentType = :json)
#     response.status_code = status

#     case content_type
#     when .json?
#       response.content_type = "application/json; charset=utf-8"
#     when .text?
#       response.content_type = "text/plain; charset=utf-8"
#     end

#     if @maxage > 0
#       response.headers.add("Cache-Control", "#{@cache_type}, max-age=#{@maxage}")
#     end
#   end

#   def save_session!
#     # return unless session.changed?
#     session.set_session
#     cookies.write(response.headers)
#   end

#   def serv_json(object : Object, status = 200)
#     set_headers(status, :json)
#     response.puts(object.to_json)
#   end

#   def serv_json(status = 200)
#     set_headers(status, :json)
#     JSON.build(response) { |jb| yield jb }
#   end

#   def serv_text(object : Object, status = 200)
#     set_headers(status, :text)
#     response.puts(object.to_s)
#   end

#   def halt!(status : Int32 = 200, error : String = "")
#     set_headers(status, :json)
#     response.puts({status: status, error: error}.to_json)
#   end

#   private def read_chidx(param : String = "chidx", max : Int32? = nil) : Int32
#     idx = params.read_int(param, min: 1)
#     max && max < idx ? max : idx
#   end

# end
