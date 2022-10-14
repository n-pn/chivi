require "./cv_repo"

class MT::CvTerm
  include Crorm::Model
  self.table = "terms"
  @@repo : Crorm::Adapter = CvRepo.repo

  column id : Int32
  column dict_id : Int32

  column key : String
  column key_raw : String = ""

  column val : String
  column alt_val : String = ""

  column ptag : String = ""
  column prio : Int32 = 2

  column uname : String = ""
  column mtime : Int64 = 0_i64

  column _prev : Int32 = 0
  column _flag : Int32 = 0
  column _lock : Int32 = 0

  def self.total
    @@repo.open(&.scalar("select count(*) from #{self.table}"))
  end

  def self.total(dict_id : Int32)
    @@repo.open(&.scalar("select count(*) from #{self.table} where dict_id = ?", args: [dict_id]))
  end
end
