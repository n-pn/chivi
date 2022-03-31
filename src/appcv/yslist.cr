class CV::Yslist
  include Clear::Model

  self.table = "yslists"
  primary_key

  belongs_to ysuser : Ysuser
  # has_many yscrits : Yscrit
  # has_many nvinfos : Nvinfo, through: "yscrits"

  column origin_id : String

  column zname : String # original list name
  column vname : String # translated name

  column zdesc : String # original description
  column vdesc : String # translated description

  column group : String = "male" # target demographic: male or female

  column utime : Int64 = 0 # list checked at by minutes from epoch
  column stime : Int64 = 0 # list changed at by seconds from epoch

  column book_count : Int32 = 0
  column like_count : Int32 = 0
  column view_count : Int32 = 0

  timestamps
end
