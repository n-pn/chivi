require "./shared/book_util"

class CV::Author
  include Clear::Model

  self.table = "authors"
  primary_key

  # has_many nvinfos : Nvinfo

  column zname : String
  column vname : String
  column vslug : String # for text search

  column vdesc : String = ""
  column book_count : Int32 = 0

  column _sort : Int32 = 0 # weight of author's top rated book

  timestamps

  getter books : Array(Nvinfo) do
    books = Nvinfo.query.where({author_id: self.id}).sort_by("_sort")
    books.each { |x| x.author = self }
    books.to_a
  end

  def update_sort!(_sort : Int32)
    update!(_sort: _sort) if _sort > self._sort
  end

  ####################

  def self.glob(qs : String)
    qs =~ /\p{Han}/ ? glob_zh(qs) : glob_vi(qs)
  end

  def self.glob_zh(qs : String)
    query.where("zname LIKE '%#{Nvutil.scrub_zname(qs)}%'")
  end

  def self.glob_vi(qs : String, accent = false)
    res = query.where("vslug LIKE '%#{Nvutil.scrub_vname(qs, "-")}%'")
    accent ? res.where("vname LIKE '%#{qs}%'") : res
  end

  def self.upsert!(zname : String, vname : String? = nil) : Author
    find({zname: zname}) || create!(zname, vname || BookUtil.author_vname(zname))
  end

  def self.create!(zname : String, vname : String) : Author
    vslug = BookUtil.make_slug(vname)
    new({zname: zname, vname: vname, vslug: vslug}).tap(&.save!)
  end

  CACHE_INT = RamCache(Int64, self).new(2048)

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) }
  end
end
