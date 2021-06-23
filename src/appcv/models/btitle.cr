class CV::Btitle < Granite::Base
  connection pg
  table btitles

  has_many :nvinfo

  column id : Int64, primary: true
  timestamps

  column zh_name : String
  column hv_name : String # translate from zh_name
  column vi_name : String # manual inputted or same as hv_name

  # for text search
  column zh_slug : String # auto generated from zh_name
  column hv_slug : String # auto generated from hv_name
  column vi_slug : String # auto generated from vi_name

  column sorting : Int32 = 0 # weight of top rated book has this title

end
