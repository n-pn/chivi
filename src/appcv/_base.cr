require "../config"
require "clear"

Clear::Log.level = ::Log::Severity::Error if CV::Config.production?
Clear::SQL.init(CV::Config.database_url)
