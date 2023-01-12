require "action-controller"

require "../../engine"
require "../../../_util/ram_cache"

abstract class MT::BaseCtrl < ActionController::Base
  Log = ::Log.for("controller")

  add_parser("text/plain") { |_klass, body_io| body_io.gets_to_end }

  add_responder("*/*") { |io, result| io << result }
  add_responder("text/html") { |io, result| result.to_json(io) }
  add_responder("text/plain") { |io, result| io << result }

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

  UNAME_CACHE = {} of String => String
  PRIVI_CACHE = RamCache(String, Int32).new(limit: 10_000, ttl: 3.minutes)

  getter cu_uname : String do
    token = cookies["cv_rt"].value
    UNAME_CACHE[token] ||= `./bin/cvjwt_cli dr #{token}`.strip
  end

  getter cu_privi : Int32 do
    PRIVI_CACHE.get(cu_uname) do
      `curl -s localhost:5010/api/_user/privi/#{cu_uname}`.to_i? || -1
    end
  end
end
