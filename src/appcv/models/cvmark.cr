class CV::Cvmark < Granite::Base
  connection pg
  table cvmarks

  belongs_to :cvuser
  belongs_to :cvbook

  column id : Int64, primary: true
  timestamps

  # bookmark type: reading, finished, onhold, dropped, pending, nothing
  column blist : String = ""

  # caching data to avoid loading chapter infos
  # format: [zseed, snvid, chidx, title, cslug]

  column last_view : Array(String)?
  column viewed_at : Int64 = 0

  column chap_mark : Array(String)?
  column marked_at : Int64 = 0

  # preferred nvseed's name when picking chapters
  column fav_zseed : Int32? # default to chap_mark.first? || last_view.first?

  # column privi : Int32 = 1 # user access privilege for editing book...
  # column prefs : JSON::Any? # future proof preferences

end
