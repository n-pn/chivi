require "./_setup"

class CV::ViuserNvinfo
  include Clear::Model

  primary_key type: serial

  column viuser_id : Int32 # link to ysusers table
  column nvinfo_id : Int32 # link to ysusers table

  # bookmark type: reading, finished, onhold, dropped, pending, nothing
  column label : String, presence: false    # default to "nothing"
  column privi : Int32, presence: false     # privilege
  column prefs : JSON::Any, presence: false # future proof preferences

  # format: [sname, snvid, chidx, title, cslug]
  # cached data to avoid loading chap infos
  column chap_last : Array(String)? # latest viewed chapter
  column chap_mark : Array(String)? # fixed chapter bookmark

  # preferred nvseed's name when picking chapters
  column fav_sname : String? # default to chap_read or chap_mark sname
end
