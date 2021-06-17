require "./_setup"

class CV::Nvinfo
  include Clear::Model

  primary_key type: serial

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  column author : Array(String) # [zh_author, vi_author?...]
  column btitle : Array(String) # [zh_title, hv_title, vi_title?...]

  column author_id : Int32? # link to authors table for faster lookup
  column btitle_id : Int32? # link to nvseeds table for faster lookup

  column bgenres : Array(String) # default to ["Loại khác"]
  column nvseeds : Array(String) # default to ["local"]

  column bgenre_ids : Array(Int32)? # link to bgenres table for faster lookup
  column nvseed_ids : Array(Int32)? # link to nvseeds table for faster lookup

  column bcover : String # default to nocover.png
  column bintro : String # default to empty string

  column ys_voters : Int32, presence: false # yousuu voters count
  column vi_voters : Int32, presence: false # chivi voters count

  column ys_rating : Int32, presence: false # yousuu users avg rating, from 00 to 100
  column vi_rating : Int32, presence: false # chivi users avg rating, from 00 to 100

  column voters : Int32, presence: false # = ys_voters + vi_voters * 2 + random_seed (if < 25)
  column rating : Int32, presence: false # delivered from above values

  column weight : Int32, presence: false # voters * rating + ???

  column mftime : Int64, presence: false # value by minute from the epoch, max value of nvseed mftime and ys_mftime
  column bumped : Int32, presence: false # value by minute from the epoch, update whenever an registered user viewing book info

  # 0: ongoing, 2: completed, 3: axed/hiatus, 4: unknown
  column status : Int32, presence: false

  # 0: public (anyone can see), 1: protected (show to registered users),
  # 2: private (show to power users), 3: hidden (show to administrators only)
  column shield : Int32, presence: false # default to 0

  column ysbook_id : Int32? # link to yousuu book id
  column ys_mftime : Int64? # yousuu book update time

  column orig_link : String? # original publisher novel page
  column orig_name : String? # original publisher name, extract from link

  # TODO: add counters
end
