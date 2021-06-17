class CV::Nvinfo < Granite::Base
  connection pg
  table nvinfos

  belongs_to :author, foreign_key: author_id : Int32
  belongs_to :btitle, foreign_key: btitle_id : Int32

  column id : Int32, primary: true
  timestamps

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  column author : Array(String) # [zh_author, vi_author?...]
  column btitle : Array(String) # [zh_title, hv_title, vi_title?...]

  column bgenres : Array(String) = ["Loại khác"]
  column nvseeds : Array(String) = ["local"]

  column bgenre_ids : Array(Int32)? # link to bgenres table for faster lookup
  column nvseed_ids : Array(Int32)? # link to nvseeds table for faster lookup

  column bcover : String = "nocover.png"
  column bintro : String = ""

  # 0: ongoing, 2: completed, 3: axed/hiatus, 4: unknown
  column status : Int32 = 0

  # 0: public (anyone can see), 1: protected (show to registered users),
  # 2: private (show to power users), 3: hidden (show to administrators only)
  column shield : Int32 = 0 # default to 0

  column bumped : Int64 = 0 # value by minute from the epoch, update whenever an registered user viewing book info
  column mftime : Int64 = 0 # value by minute from the epoch, max value of nvseed mftime and ys_mftime

  column weight : Int32 = 0 # voters * rating + ???
  column voters : Int32 = 0 # = ys_voters + vi_voters * 2 + random_seed (if < 25)
  column rating : Int32 = 0 # delivered from above values

  column ys_voters : Int32 = 0 # yousuu voters count
  column vi_voters : Int32 = 0 # chivi voters count

  column ys_rating : Int32 = 0 # yousuu users avg rating, from 00 to 100
  column vi_rating : Int32 = 0 # chivi users avg rating, from 00 to 100

  column ysbook_id : Int32? # link to yousuu book id
  column ys_mftime : Int64? # yousuu book update time

  column orig_link : String? # original publisher novel page
  column orig_name : String? # original publisher name, extract from link

end
