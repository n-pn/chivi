class CV::Cvbook < Granite::Base
  connection pg
  table cvbooks

  belongs_to :btitle, primary: true, foreign_key: :id
  timestamps

  column author : String = ""
  column vtitle : String = ""

  column genres : Array(String) = [] of String
  column bcover : String = ""
  column bintro : String = ""

  column status : Int32 = 0
  column shield : Int32 = 0

  column voters : Int32 = 0
  column rating : Int32 = 0

  column bumped : Int64 = 0
  column mftime : Int64 = 0

  column list_count : Int32 = 0
  column crit_count : Int32 = 0
  column chap_count : Int32 = 0
end
