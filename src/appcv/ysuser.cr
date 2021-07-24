class CV::Ysuser
  include Clear::Model

  self.table = "ysusers"
  primary_key

  has_many yslists : Yslist, foreign_key: "ysuser_id"
  has_many yscrits : Yscrit, foreign_key: "ysuser_id"
  has_many ysbooks : Ysbook, through: "yscrits"
  has_many cvbooks : Cvbook, through: "yscrits"

  column zname : String
  column vname : String

  column like_count : Int32 = 0 # TBD: total list like_count or direct like count
  column list_count : Int32 = 0 # book list count
  column crit_count : Int32 = 0 # review count

  def self.get!(id : Int32 | Int64, zname : String)
    find({id: id}) || begin
      vname = BookUtils.hanviet(zname)
      new({id: id, zname: zname, vname: vname}).tap(&.save!)
    end
  end
end
