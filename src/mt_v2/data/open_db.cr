require "db"
require "log"
require "crorm"
require "sqlite3"
require "colorize"

module M2::DbRepo
  @[AlwaysInline]
  def self.db_path(type : String) : String
    "var/dicts/#{type}.dic"
  end

  def self.open_db(type : String)
    DB.open("sqlite3:./var/dicts/#{type}.dic") { |db| yield db }
  end

  def self.init_db(type : String)
    open_db(type) do |db|
      db.exec {{ read_file("#{__DIR__}/init_db/dicts_table.sql") }}
      db.exec {{ read_file("#{__DIR__}/init_db/terms_table.sql") }}
    rescue err
      Log.error(exception: err) { "Error init #{type}" }
    end
  end
end
