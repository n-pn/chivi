require "clear"

Log.builder.bind "clear.*", Log::Severity::Info, Log::IOBackend.new
Clear::SQL.init("postgres://postgres:postgres@localhost/chivi")
