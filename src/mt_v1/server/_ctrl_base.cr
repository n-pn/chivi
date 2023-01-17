require "action-controller"

require "../mt_core"

abstract class M1::BaseCtrl < ActionController::Base
  # add_parser("text/plain") { |klass, body_io| klass.new(body_io) }
  # add_responder("text/plain") { |io, result| io << result }

  @[AC::Route::Filter(:before_action)]
  def set_date_header
    response.headers["Date"] = HTTP.format_time(Time.utc)
  end

  # handle common errors at a global level
  # this covers no acceptable response format and not an acceptable post format
  @[AC::Route::Exception(ActionController::Route::NotAcceptable, status_code: HTTP::Status::NOT_ACCEPTABLE)]
  @[AC::Route::Exception(AC::Route::UnsupportedMediaType, status_code: HTTP::Status::UNSUPPORTED_MEDIA_TYPE)]
  def bad_media_type(error)
    {
      error:   error.message,
      accepts: error.accepts,
    }
  end

  # this covers a required paramater missing and a bad paramater value / format
  @[AC::Route::Exception(AC::Route::Param::MissingError, status_code: HTTP::Status::BAD_REQUEST)]
  @[AC::Route::Exception(AC::Route::Param::ValueError, status_code: HTTP::Status::BAD_REQUEST)]
  def invalid_param(error)
    {
      error:       error.message,
      parameter:   error.parameter,
      restriction: error.restriction,
    }
  end

  getter cu_uname : String { session["uname"] }

  getter cu_privi : Int32 do
    privi = session[:privi].to_i
    (0 < privi < 4) && session["until"] < Time.utc.to_unix ? privi - 1 : privi
  end
end

module M1::CtrlUtil
  extend self

  def paged(pg_no : Int, limit : Int, max : Int = limit)
    limit = max if limit > max
    {limit, (pg_no - 1) &* limit}
  end

  def pg_no(index : Int, limit : Int)
    (index &- 1) // limit &+ 1
  end

  def offset(pgidx : Int32, limit : Int32)
    (pgidx &- 1) &* limit
  end
end
