class CV::Ysbook < Granite::Base
  connection pg
  table ysbooks

  column id : Int32, primary: true
  timestamps

  column author : String
  column btitle : String

  column genres : Array(String) # combine className with tags

  column bintro : String
  column bcover : String

  column status : Int32 = 0
  column shield : Int32 = 0

  column voters : Int32 = 0
  column rating : Int32 = 0

  column mftime : Int64 = 0
  column bumped : Int64 = 0

  column orig_link : String? # original publisher novel page
  column orig_name : String? # original publisher name, extract from link

  column word_count : Int32 = 0
  column list_count : Int32 = 0
  column crit_count : Int32 = 0
end
