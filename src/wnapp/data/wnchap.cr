require "db"

class WN::OldChap
  include DB::Serializable

  property ch_no : Int32 # chaper index number
  property s_cid : Int32 # chapter fname in disk/remote

  property title : String = "" # chapter title
  property chdiv : String = "" # volume name

  property vtitle : String = "" # translated title
  property vchdiv : String = "" # translated volume name

  property mtime : Int64 = 0   # last modification time
  property uname : String = "" # last modified by username

  property c_len : Int32 = 0 # chars count
  property p_len : Int32 = 0 # parts count

  property _path : String = "" # file locator
  property _flag : Int32 = 0   # marking states
end
