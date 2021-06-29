require "clear"

database_url = ENV["DATABASE_URL"]? || Amber.settings.database_url
Clear::SQL.init(database_url)
