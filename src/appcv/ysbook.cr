class CV::Ysbook
  include Clear::Model

  self.table = "ysbooks"
  primary_key

  belongs_to cvbook : Cvbook
  has_many yscrits : Yscrit
  has_many yslists : Yslist, through: "yscrits"

  column voters : Int32 = 0
  column rating : Int32 = 0

  column bumped : Int64 = 0
  column mftime : Int64 = 0

  column list_count : Int32 = 0
  column crit_count : Int32 = 0

  column root_link : String = "" # original publisher novel page
  column root_name : String = "" # original publisher name, extract from link

  def unmatch?(cvbook_id : Int64) : Bool
    cvbook_id_column.value(0) != cvbook_id
  end

  def self.get!(id : Int64) : Ysbook
    find({id: id}) || new({id: id})
  end
end
