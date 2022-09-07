require "amber"
require "clear"

Clear::Log.level = ::Log::Severity::Error if ENV["AMBER_ENV"]? == "production"

database_url = ENV["DATABASE_URL"]? || Amber.settings.database_url
Clear::SQL.init(database_url)
