require "../../appcv/**"
require "./_curr_user"
require "./_ctrl_util"

require "action-controller"

class NotFound < Exception; end

class BadRequest < Exception; end

class Unauthorized < Exception; end

abstract class CV::BaseCtrl < ActionController::Base
  base "/api"

  Log = ::Log.for("controller")

  # add_parser("application/json") { |klass, body_io| klass.from_json(body_io) }
  # add_parser("text/plain") { |_klass, body_io| body_io.gets_to_end }

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

  getter _viuser : Viuser do
    uname = session["uname"]?.try(&.as(String)) || "Khách"
    Viuser.load!(uname)
  end

  private def get_nvinfo(b_id : Int64) : Nvinfo
    Nvinfo.load!(b_id) || raise NotFound.new("Quyển sách không tồn tại")
  end

  enum ChrootLoadMode
    Auto # guess from type
    Init # create new one if not exist
    Find # raise missing if not exist
  end

  private def get_chroot(b_id : Int64, sname : String, mode : ChrootLoadMode = :auto)
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

  def save_current_user!(user : Viuser) : Nil
    # user_token = CjwtUtil.encode_user_token(user.id, user.uname, user.privi)
    # USER_CACHE[user_token] = CurrentUser.new(user.id, user.uname, user.privi)
    # cookies << HTTP::Cookie.new("_user", user_token, expires: 30.minutes.from_now)

    session["uname"] = user.uname
  end

  private def guard_privi(min = 0)
    raise Unauthorized.new("Quyền hạn không đủ!") if _viuser.privi < min
  end

  private def guard_owner(owner_id : Int32)
    privi = _viuser.privi
    privi < 0 ? false : privi > 3 ? true : _viuser.id == owner_id
  end
end
