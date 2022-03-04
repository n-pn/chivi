class CV::Nvstat
  include Clear::Model

  self.table = "nvstats"
  belongs_to nvinfo : Nvinfo

  column _type : String = ""

  column voters : Int32 = 0
  column points : Int32 = 0
  column weight : Int32 = 0

  column views : Int32 = 0
  column marks : Int32 = 0

  column posts : Int32 = 0
  column crits : Int32 = 0
  column repls : Int32 = 0

  #########################################
end
