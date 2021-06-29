class CV::Ubview
  include Clear::Model

  self.table = "ubviews"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to cvuser : Cvuser

  column zseed : Int32 = 0
  column znvid : Int32 = 0

  column zchid : Int32 = 0
  column chidx : Int32 = 0

  column bumped : Int64 = 0_i64 # order field

  column ch_title : String = ""
  column ch_label : String = ""
  column ch_uslug : String = ""
end
