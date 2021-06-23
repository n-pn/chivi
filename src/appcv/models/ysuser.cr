class CV::Ysuser < Granite::Base
  connection pg
  table ysusers

  column id : Int64, primary: true
  timestamps

  column zh_name : String
  column vi_name : String

  column like_count : Int32 = 0 # TBD: total list like_count or direct like count
  column list_count : Int32 = 0 # book list count
  column crit_count : Int32 = 0 # review count

  def origin_id
    created_at.to_unix.to_s(base: 16) + id.to_s(base: 16)
  end
end
