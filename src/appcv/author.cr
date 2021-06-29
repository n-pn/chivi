require "./shared/book_utils"

class CV::Author
  include Clear::Model
  self.table = "authors"
  primary_key

  has_many cvbook : Cvbook

  column zname : String
  column vname : String

  column zname_ts : String # for text search
  column vname_ts : String # for text search

  column weight : Int32 = 0 # weight of author's top rated book

  def update_weight!(weight : Int32)
    update!(weight: weight) if weight > self.weight
  end

  def self.glob(qs : String)
    qs =~ /\p{Han}/ ? glob_zh(qs) : glob_vi(qs)
  end

  def self.glob_zh(qs : String)
    query.where("zname_ts LIKE %?%", BookUtils.scrub_zname(qs))
  end

  def self.glob_vi(qs : String, accent = false)
    res = query.where("vname_ts LIKE %?%", BookUtils.scrub_vname(qs))
    accent ? res.where("vname LIKE %?%", qs) : res
  end

  def self.upsert!(zname : String, vname : String? = nil) : Author
    find({zname: zname}) || create!(zname, vname)
  end

  def self.create!(zname : String, vname : String? = nil) : Author
    vname ||= BookUtils.get_vi_author(zname)

    zname_ts = BookUtils.scrub_zname(zname)
    vname_ts = BookUtils.scrub_vname(vname, "-")

    author = new({
      zname: zname, vname: vname,
      zname_ts: zname_ts, vname_ts: vname_ts,
    })

    author.tap(&.save!)
  end
end
