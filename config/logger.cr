require "log"

# Using environment settings:
Colorize.enabled = Amber.settings.logging.colorize

# Using crystal's standard environment variables:
# CRYSTAL_LOG_LEVEL=INFO
# CRYSTAL_LOG_SOURCES=*
# Logs are emitted to STDOUT

class Log
  backend = IOBackend.new(STDOUT)

  # Custom formatter
  # This is a good place to change the time from UTC

  time_zone = Time::Location.load("Asia/Ho_Chi_Minh")

  backend.formatter = Formatter.new do |entry, io|
    io << entry.timestamp.in(time_zone).to_s("%I:%M:%S")
    io << " "
    io << entry.source
    io << " |"
    io << " (#{entry.severity})" if entry.severity > Severity::Debug
    io << " "
    io << entry.message

    if entry.severity == Severity::Error
      io << "\n"
      entry.exception.try(&.inspect_with_backtrace)
    end
  end

  builder.clear
  builder.bind "*", Amber.settings.logging.severity, backend

  setup_from_env
end

# Using more advanced options:
# backend = Log::IOBackend.new
# Log.builder.bind "*", :warn, backend
# Log.builder.bind "request", :debug, backend
# Log.builder.bind "headers", :debug, backend
# Log.builder.bind "cookies", :debug, backend
# Log.builder.bind "params", :debug, backend
# Log.builder.bind "session", :debug, backend
# Log.builder.bind "errors", :warn, backend
# Log.builder.bind "granite.*", :info, backend
# Log.builder.bind "*", :error, ElasticSearchBackend.new("http://localhost:9200")
