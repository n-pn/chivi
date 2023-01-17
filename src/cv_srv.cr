require "./cv_env"

require "log"
require "action-controller"
require "action-controller/logger"
require "action-controller/server"

class ::Log
  backend = IOBackend.new(STDOUT)
  time_zone = Time::Location.load("Asia/Ho_Chi_Minh")

  backend.formatter = Formatter.new do |entry, io|
    io << entry.timestamp.in(time_zone).to_s("%I:%M:%S")
    io << ' ' << entry.source << " |"
    io << " (#{entry.severity})" if entry.severity > Severity::Debug
    io << ' ' << entry.message

    if entry.severity == Severity::Error
      io << '\n'
      entry.exception.try(&.inspect_with_backtrace(io))
    end
  end

  builder.clear

  if CV_ENV.production?
    log_level = ::Log::Severity::Info
    builder.bind "*", :warn, backend
  else
    log_level = ::Log::Severity::Debug
    builder.bind "*", :info, backend
  end

  setup_from_env
end

class UserError < Exception; end

class NotFound < UserError; end

class BadRequest < UserError; end

class Unauthorized < UserError; end

abstract class AC::Base
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

  @[AC::Route::Exception(BadRequest, status_code: HTTP::Status::BAD_REQUEST)]
  def bad_request(error)
    {message: error.message}
  end

  @[AC::Route::Exception(NotFound, status_code: HTTP::Status::NOT_FOUND)]
  def not_found(error)
    {message: error.message}
  end

  @[AC::Route::Exception(Unauthorized, status_code: HTTP::Status::FORBIDDEN)]
  def unauthorized(error)
    {message: error.message}
  end

  #####

  private getter _uname : String { session["uname"]?.try(&.as(String)) || "Khách" }

  private getter _privi : Int32 do
    _privi = session["privi"]?.try(&.as(Int64).to_i) || -1
    _until = session["until"]?.try(&.as(Int64)) || 0_i64

    (0 < _privi < 4) && _until < Time.utc.to_unix ? _privi - 1 : _privi
  end

  #####

  private def _paginate(max = 100)
    pg_no = params["pg"]?.try(&.to_i?) || 1
    limit = params["lm"]?.try(&.to_i?) || 5

    pg_no = 1 if pg_no < 1
    limit = max if limit > max

    {pg_no, limit, (pg_no &- 1) &* limit}
  end

  private def _paged(pg_no : Int, limit : Int, max : Int)
    limit = max if limit > max
    _paged(pg_no, limit)
  end

  private def _paged(pg_no : Int, limit : Int)
    pg_no = 1 if pg_no < 1
    {limit, limit &* (pg_no &- 1)}
  end

  private def _pgidx(total : Int, limit : Int)
    (total &- 1) // limit &+ 1
  end

  private def _get_str(name : String)
    params[name]?.try { |x| x unless x.blank? }
  end

  private def _get_int(name : String)
    params[name]?.try(&.to_i?)
  end
end

struct ConvertLimit
  def initialize(@min = 0, @max = 24)
  end

  def convert(raw : String)
    return @max unless int = raw.to_i?
    int > @max ? @max : int < @min ? @min : int
  end
end

struct ConvertArray
  def initialize(@delimit = ",")
  end

  def convert(raw : String)
    raw.split(@delimit, remove_empty: true).map(&.strip).uniq!
  end
end

struct ConvertBase32
  def convert(raw : String)
    HashUtil.decode32(raw)
  end
end

def start_server!(port : Int32, server_name = "Chivi")
  # Add handlers that should run before your application
  AC::Server.before(
    AC::ErrorHandler.new(CV_ENV.production?, ["X-Request-ID"]),
    AC::LogHandler.new(["upass", "new_upass"]),
    HTTP::CompressHandler.new
  )

  AC::Session.configure do |settings|
    settings.key = "_auth"
    settings.secret = CV_ENV.session_skey
    settings.secure = CV_ENV.production? # HTTPS only
  end

  server = AC::Server.new(port, "127.0.0.1")

  terminate = Proc(Signal, Nil).new do |signal|
    signal.ignore
    server.close
    # puts " > terminating gracefully"
    # spawn { server.close }
  end

  Signal::INT.trap &terminate  # Detect ctr-c to shutdown gracefully
  Signal::TERM.trap &terminate # Docker containers use the term signal

  server.run { puts "[#{server_name}] listening on #{server.print_addresses}" }

  # finished
  puts "[#{server_name}] server terminated"
end
