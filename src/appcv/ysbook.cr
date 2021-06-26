class CV::Ysbook < Granite::Base
  connection pg
  table ysbooks

  column id : Int64, primary: true
  timestamps

  belongs_to :btitle
  has_many :yscrit
  has_many :yslist, through: :yscrit

  column author : String
  column ztitle : String

  column genres : Array(String) = [] of String
  column bintro : String = ""
  column bcover : String = ""

  column status : Int32 = 0
  column shield : Int32 = 0

  column voters : Int32 = 0
  column rating : Int32 = 0

  column bumped : Int64 = 0
  column mftime : Int64 = 0

  column word_count : Int32 = 0
  column list_count : Int32 = 0
  column crit_count : Int32 = 0

  column root_link : String? # original publisher novel page
  column root_name : String? # original publisher name, extract from link

  def decent?
    list_count > 0 || crit_count > 4
  end

  def self.get!(id : Int64)
    find(id) || new(id: id)
  end
end
