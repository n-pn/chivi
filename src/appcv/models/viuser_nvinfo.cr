class CV::ViuserNvinfo < Granite::Base
  connection pg
  table viuser_nvinfos

  belongs_to :viuser, foreign_key: viuser_id : Int32
  belongs_to :nvinfo, foreign_key: nvinfo_id : Int32

  column id : Int32, primary: true
  timestamps

  # bookmark type: reading, finished, onhold, dropped, pending, nothing
  column blist : String = "default"

  column privi : Int32 = 1 # user access privilege for editing book...
  # column prefs : JSON::Any? # future proof preferences

  # preferred nvseed's name when picking chapters
  column fav_sname : String? # default to chap_mark.first? || chap_last.first?

  # format: [sname, snvid, chidx, title, cslug]
  # cached data to avoid loading chap infos
  column chap_last : Array(String)?
  column chap_mark : Array(String)?
end
