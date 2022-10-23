require "./open_db"

class MT::CvDict
  include Crorm::Model
  self.table = "dicts"

  column id : Int32

  column name : String
  column type : Int32 = 0

  column label : String = ""
  column intro : String = ""

  column min_privi : Int32 = 1

  column term_total : Int32 = 0
  column term_count : Int32 = 0

  column last_mtime : Int64 = 0

  def ininitialize(@id, @name, @type = 0, @label = "", @intro = "")
  end

  # def save!(db : DB::Connection)
  #   fields, values = self.changes

  # end
  ######

  def self.find(name : String)
    case name[0]
    when '-' then find("book", name)
    when '!' then find("pack", name)
    when '@' then find("user", name)
    else          find("core", name)
    end
  end

  def self.find(type : String, name : String)
    find!(type, name)
  rescue
    nil
  end

  def self.find!(type : String, name : String)
    DbRepo.open_dict_db(type) do |db|
      db.query_one(%{select * from "dicts" where name = ?}, args: [name], as: CvDict)
    end
  end
end
