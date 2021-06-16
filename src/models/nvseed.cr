require "./_setup"

class CV::Nvseed
  include Clear::Model

  primary_key type: serial

  column nvinfo_id : Int32? # link to nvinfo tables

  column sname : String # seed name
  column snvid : String # seed book string id

  column status : Int32, presence: false # same as Nvinfo#status
  column shield : Int32, presence: false # same as Nvinfo#shield

  column mftime : Int64, presence: false # seed page update time as total seconds since the epoch
  column bumped : Int32, presence: false # last fetching time as total minutes since the epoch

  column chap_count : Int32, presence: false  # total chapters
  column last_schid : String, presence: false # seed's latest chap string id

end
