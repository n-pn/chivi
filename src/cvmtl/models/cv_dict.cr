require "./cv_repo"

class MT::CvDict
  include Crorm::Model
  self.table = "dicts"
  @@repo : Crorm::Adapter = CvRepo.repo

  column id : Int32

  column dname : String
  column dtype : Int32 = 0

  column label : String = ""
  column intro : String = ""

  column min_privi : Int32 = 1

  column term_total : Int32 = 0
  column term_count : Int32 = 0

  column last_mtime : Int64 = 0

  def ininitialize(@id, @dname, @dtype = 20, @label = "", @intro = "")
  end

  ######

  def self.load(dname : String)
    load!(dname)
  rescue
    nil
  end

  def self.load!(dname : String)
    CvRepo.open_db do |db|
      db.query_one("select * from 'dicts' where dname = ?", args: [dname], as: CvDict)
    end
  end
end
