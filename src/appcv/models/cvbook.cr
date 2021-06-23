class CV::Cvbook < Granite::Base
  connection pg
  table cvbooks

  belongs_to :author
  belongs_to :btitle
  belongs_to :ysbook

  column id : Int64, primary: true
  timestamps

  column bhash : String # unique string generate from zh_title & zh_author
  column bslug : String # unique string generate from hv_title & bhash

  column author : Array(String) # [zh_author, vi_author?...]
  column btitle : Array(String) # [zh_title, hv_title, vi_title?...]

  column bgenre_ids : Array(Int32)?
  column zhseed_ids : Array(Int32)?

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

  getter bgenres : Array(String) do
    bgenre_ids.map { |id| Bgenre.vname(id) }
  end

  getter zhseeds : Array(String) do
    zhseed_ids.map { |id| Zhseed.zseed(id) }
  end
end
