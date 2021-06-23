require "../../cutil/core_utils"

class CV::Zhbook < Granite::Base
  connection pg
  table zhbooks

  has_one :cvbook

  column id : Int64, primary: true
  timestamps

  column zseed : Int32 # seed name
  column znvid : Int32 # seed book id

  column author : String
  column btitle : String

  column genres : Array(String) # combine className with tags
  column bintro : String?
  column bcover : String?

  column status : Int32 = 0 # same as Nvinfo#status
  column shield : Int32 = 0 # same as Nvinfo#shield

  column voters : Int32 = 0
  column rating : Int32 = 0

  column mftime : Int64 = 0 # seed page update time as total seconds since the epoch
  column bumped : Int64 = 0 # last fetching time as total minutes since the epoch

  column chap_count : Int32 = 0 # total chapters
  column last_schid : Int32 = 0 # seed's latest chap id

  getter sname : String { Zhseed.zseed(zseed) }
  getter snvid : String { sname == "zhwenpg" ? CoreUtils.encode32_zh(znvid) : znvid.to_s }
end
