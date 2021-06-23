class CV::Yscrit < Granite::Base
  connection pg
  table yscrits

  belongs_to :ysuser
  belongs_to :yslist
  belongs_to :ysbook

  column id : Int64, primary: true
  timestamps

  column starred : Int32 = 3 # voting 1 2 3 4 5 stars

  column zh_text : String = "" # orginal comment
  column vi_html : String = "" # translated comment

  column bumped : Int64 = 0 # list checked at by minutes from epoch
  column mftime : Int64 = 0 # list changed at by seconds from epoch

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional

  def origin_id
    created_at.to_unix.to_s(base: 16) + id.to_s(base: 16)
  end
end
