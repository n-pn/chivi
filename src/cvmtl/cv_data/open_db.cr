require "db"
require "log"
require "crorm"
require "sqlite3"
require "colorize"

module MT::DbRepo
  @[AlwaysInline]
  def self.dict_path(type : String) : String
    "var/dicts/#{type}-dicts.db"
  end

  def self.open_dict_db(type : String)
    DB.open("sqlite3:./#{dict_path(type)}") { |db| yield db }
  end

  def self.init_dict_db!(type : String)
    open_dict_db(type) do |db|
      db.exec {{ read_file("#{__DIR__}/init_db/cv_dict_init.sql") }}
    rescue err
      Log.error(exception: err) { "Error init #{type}" }
    end
  end

  @[AlwaysInline]
  def self.term_path(type : String) : String
    "var/dicts/#{type}-terms.db"
  end

  def self.open_term_db(type : String)
    DB.open("sqlite3:./#{term_path(type)}") { |db| yield db }
  end

  def self.init_term_db!(type : String)
    open_term_db(type) do |db|
      db.exec {{ read_file("#{__DIR__}/init_db/cv_term_init.sql") }}
    rescue err
      Log.error(exception: err) { "Error init #{type}" }
    end
  end
end
