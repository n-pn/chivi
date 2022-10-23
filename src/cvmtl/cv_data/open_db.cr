require "db"
require "log"
require "crorm"
require "sqlite3"
require "colorize"

module MT::DbRepo
  def self.open_dict_db(type : String)
    DB.open("sqlite3:./var/dicts/#{type}-dicts.db") { |db| yield db }
  end

  def self.init_dict_db!(db_path : String)
    open_dict_db(dname) do |db|
      db.exec {{ read_file("#{__DIR__}/init_db/cv_dict_init.sql") }}
    end
  end

  def self.open_term_db(type : String)
    DB.open("sqlite3:./var/dicts/#{type}-terms.db") { |db| yield db }
  end

  def self.init_db!(db_path : String)
    open_term_db(type) do |db|
      db.exec {{ read_file("#{__DIR__}/init_db/cv_term_init.sql") }}
    end
  end
end
