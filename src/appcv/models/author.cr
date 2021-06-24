class CV::Author < Granite::Base
  connection pg
  table authors

  column id : Int64, primary: true
  timestamps

  has_many :btitle

  column zname : String
  column vname : String

  column zname_tz : String # for text search
  column vname_tz : String # for text search

  column weight : Int32 = 0 # weight of author's top rated book

end
