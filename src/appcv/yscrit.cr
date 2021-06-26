class CV::Yscrit < Granite::Base
  connection pg
  table yscrits

  column id : Int64, primary: true
  timestamps

  belongs_to :cvbook
  belongs_to :ysbook

  belongs_to :ysuser
  belongs_to :yslist, foreign_key: id : Int64?

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars

  column ztext : String = "" # orginal comment
  column vhtml : String = "" # translated comment

  column bumped : Int64 = 0 # list checked at by minutes from epoch
  column mftime : Int64 = 0 # list changed at by seconds from epoch

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional

  getter origin_id : String do
    created_at.not_nil!.to_unix.to_s(base: 16) + id.to_s(base: 16)
  end
end
