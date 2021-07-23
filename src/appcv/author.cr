require "./shared/book_utils"

class CV::Author
  include Clear::Model
  self.table = "authors"
  primary_key

  has_many cvbook : Cvbook, foreign_key: "cvbook_id"

  column zname : String
  column vname : String
  column vslug : String # for text search

  column weight : Int32 = 0 # weight of author's top rated book

  def update_weight!(weight : Int32)
    update!(weight: weight) if weight > self.weight
  end

  def self.glob(qs : String)
    qs =~ /\p{Han}/ ? glob_zh(qs) : glob_vi(qs)
  end

  def self.glob_zh(qs : String)
    query.where("zname LIKE '%#{BookUtils.scrub_zname(qs)}%'")
  end

  def self.glob_vi(qs : String, accent = false)
    res = query.where("vslug LIKE '%#{BookUtils.scrub_vname(qs, "-")}%'")
    accent ? res.where("vname LIKE '%#{qs}%'") : res
  end

  def self.upsert!(zname : String, vname : String? = nil) : Author
    find({zname: zname}) || create!(zname, vname)
  end

  def self.create!(zname : String, vname : String? = nil) : Author
    vname ||= BookUtils.get_vi_author(zname)
    vslug = BookUtils.scrub_vname(vname, "-")

    author = new({zname: zname, vname: vname, vslug: vslug})
    author.tap(&.save!)
  end
end
