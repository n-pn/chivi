require "./open_db"

class MT::CvTerm
  include Crorm::Model
  self.table = "terms"

  column id : Int32, primary: true
  column dic : Int32

  column key : String
  column raw : String?

  column val : String
  column alt : String?

  column ptag : String = ""
  column wseg : Int32 = 2

  column user : String = ""
  column time : Int64 = 0_i64
  column flag : Int32 = 0

  ###########

  def self.total(type : String, query = "true")
    DbRepo.open_term_db(type, &.scalar("select count(*) from terms where #{query}"))
  end

  def self.total(type : String, dic : Int32)
    total(type, "dic = #{dic}")
  end
end
