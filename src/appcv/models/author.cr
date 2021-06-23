class CV::Author < Granite::Base
  connection pg
  table authors

  has_many :nvinfo

  column id : Int64, primary: true
  timestamps

  column zh_name : String
  column vi_name : String

  column zh_slug : String # for text search
  column vi_slug : String # for text search

  column sorting : Int32 = 0 # weight of author top rated book

end
