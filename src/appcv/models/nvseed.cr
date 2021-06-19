class CV::Nvseed < Granite::Base
  connection pg
  table nvseeds

  belongs_to :nvinfo, foreign_key: nvinfo_id : Int32

  column id : Int32, primary: true
  timestamps

  column sname : Int32 # seed name
  column snvid : Int32 # seed book id

  column status : Int32 = 0 # same as Nvinfo#status
  column shield : Int32 = 0 # same as Nvinfo#shield

  column mftime : Int64 = 0 # seed page update time as total seconds since the epoch
  column bumped : Int64 = 0 # last fetching time as total minutes since the epoch

  column chap_count : Int32 = 0 # total chapters
  column last_schid : Int32 = 0 # seed's latest chap id
end
