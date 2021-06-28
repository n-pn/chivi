class CV::Yslist < Granite::Base
  connection pg
  table yslists

  column id : Int64, primary: true
  timestamps

  belongs_to :ysuser
  has_many :yscrit
  has_many :ysbook, through: :yscrit
  has_many :cvbook, through: :yscrit

  column zname : String # original list name
  column vname : String # translated name

  column zdesc : String # original description
  column vdesc : String # translated description

  column aim_at : String = "male" # target demographic: male or female

  column bumped : Int64 = 0 # list checked at by minutes from epoch
  column mftime : Int64 = 0 # list changed at by seconds from epoch

  column book_count : Int32 = 0
  column like_count : Int32 = 0
  column view_count : Int32 = 0

  getter origin_id : String do
    created_at.not_nil!.to_unix.to_s(base: 16) + id.to_s(base: 16)
  end
end
