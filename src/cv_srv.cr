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

abstract class UserError < Exception
  getter status : HTTP::Status = :bad_request

  def initialize(@message)
    @cause = nil
    @callstack = nil
  end
end

class BadRequest < UserError
  def initialize(message)
    super(message)
    @status = :bad_request
  end
end

class Unauthorized < UserError
  def initialize(message)
    super(message)
    @status = :unauthorized
  end
end

class Forbidden < UserError
  def initialize(message)
    super(message)
    @status = :forbidden
  end
end

class NotFound < UserError
  def initialize(@message)
    @status = :not_found
  end
end

abstract class AC::Base
  # add_responder("text/plain") { |io, result| io << result }
  # add_responder("text/html") { |io, result| io << result }

  @[AC::Route::Filter(:before_action)]
  def before_all_actions
    response.headers["Date"] = HTTP.format_time(Time.utc)
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Content-Type"] = "application/json"
    response.headers["Access-Control-Allow-Methods"] = "GET,HEAD,POST,DELETE,OPTIONS,PUT,PATCH"

    Log.context.set(client_ip: client_ip)
  end

  private getter _vu_id : Int32 do
    session["vu_id"]?.try(&.as(Int64).to_i) || 0
  end

  private getter _uname : String do
    session["uname"]?.try(&.as(String)) || "Khách"
  end

  private getter _privi : Int32 do
    _privi = session["privi"]?.try(&.as(Int64).to_i) || -1
    _until = session["until"]?.try(&.as(Int64)) || 0_i64

    (0 < _privi < 4) && _until < Time.utc.to_unix ? _privi &- 1 : _privi
  end

  private def guard_privi(min min_privi : Int32, action : String = "thực hiện hoạt động")
    raise Unauthorized.new(privi_rejected(action, min_privi)) if _privi < min_privi
  end

  private def guard_owner(owner : Int32, min min_privi : Int32,
                          action : String = "thực hiện hoạt động")
    return if _privi > 3 || (_privi >= min_privi && owner == _vu_id)
    raise Unauthorized.new(privi_rejected(action, min_privi))
  end

  private def guard_owner(owner : String, min min_privi : Int32,
                          action : String = "thực hiện hoạt động")
    return if _privi > 3 || (_privi >= min_privi && owner == _uname)
    raise Unauthorized.new(privi_rejected(action, min_privi))
  end

  @[AlwaysInline]
  private def privi_rejected(action : String, min_privi : Int32)
    "Bạn không đủ quyền hạn để #{action} (tối thiểu: #{min_privi})!"
  end

  #####

  @[AlwaysInline]
  private def _read_cookie(name : String)
    cookies[name]?.try(&.value)
  end

  private def _paginate(min = 5, max = 100)
    pg_no = params["pg"]?.try(&.to_i?) || 1
    limit = params["lm"]?.try(&.to_i?) || min

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

  LOG_DIR = "var/ulogs/daily"
  Dir.mkdir_p(LOG_DIR)

  def _log_action(type : String, data : Object, user = _uname, ldir = LOG_DIR)
    spawn do
      local_now = Time.local
      log_file = "#{ldir}/#{local_now.to_s("%F")}.jsonl"

      action = {time: local_now, user: user, type: type, data: data}
      File.open(log_file, "a", &.puts(action.to_json))
    end
  end
end

# struct ConvertLimit
#   def initialize(@min = 0, @max = 24)
#   end

#   def convert(raw : String)
#     return @max unless int = raw.to_i?
#     int > @max ? @max : int < @min ? @min : int
#   end
# end

# struct ConvertArray
#   def initialize(@delimit = ",")
#   end

#   def convert(raw : String)
#     raw.split(@delimit, remove_empty: true).map(&.strip).uniq!
#   end
# end

class ErrorHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue ex : Exception
    response = context.response
    response.reset

    if ex.is_a?(UserError)
      response.status = ex.status
    else
      response.status = :internal_server_error
    end

    response.content_type = "text/plain; charset=utf-8"
    response.print(ex.message)
  end
end

def start_server!(port : Int32, server_name = "Chivi")
  # Add handlers that should run before your application
  AC::Server.before(
    ErrorHandler.new,
    AC::LogHandler.new(["upass", "new_upass"]),
    HTTP::CompressHandler.new
  )

  AC::Session.configure do |settings|
    settings.key = "_a"
    settings.path = "/"
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
