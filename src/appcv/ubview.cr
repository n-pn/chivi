class CV::Ubview < Granite::Base
  connection pg
  table ubviews

  belongs_to :btitle
  belongs_to :cvuser

  column id : Int64, primary: true
  timestamps

  column zseed : Int32 = 0
  column znvid : Int32 = 0

  column zchid : Int32 = 0
  column chidx : Int32 = 0

  column bumped : Int64 = 0_i64 # order field

  column ch_title : String = ""
  column ch_label : String = ""
  column ch_uslug : String = ""
end
