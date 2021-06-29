class CV::Yscrit
  include Clear::Model

  self.table = "yscrits"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to ysbook : Ysbook

  belongs_to ysuser : Ysuser
  belongs_to yslist : Yslist

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
