class CV::Ysuser < Granite::Base
  connection pg
  table ysusers

  column id : Int64, primary: true
  timestamps

  has_many :yslist
  has_many :yscrit
  has_many :cvbook, through: :yscrit
  has_many :ysbook, through: :yscrit

  column zname : String
  column vname : String

  column like_count : Int32 = 0 # TBD: total list like_count or direct like count
  column list_count : Int32 = 0 # book list count
  column crit_count : Int32 = 0 # review count

end
