require "./_base"

class YS::Ysbook
  include Clear::Model

  self.table = "ysbooks"

  column nvinfo_id : Int64 = 0
  column crit_count : Int32 = 0 # fetched reviews
  column list_count : Int32 = 0 # fetched book lists

  # column crit_total : Int32 = 0 # total reviews
  # column list_total : Int32 = 0 # total book lists
end
