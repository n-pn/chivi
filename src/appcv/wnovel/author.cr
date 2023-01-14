require "../shared/book_util"
require "../_base"

require "./nv_info"

class CV::Author
  include Clear::Model

  self.table = "authors"
  primary_key type: :serial

  has_many nvinfos : Nvinfo, foreign_key: "author_id"

  column zname : String
  column vname : String

  column vslug : String # for text search

  # column alter : Array(String) = [] of String
  column vdesc : String = ""

  column book_count : Int32 = 0
  # column post_count : Int32 = 0
  # column like_count : Int32 = 0
  # column view_count : Int32 = 0

  timestamps

  def update_sort!(_sort : Int32)
    update!(_sort: _sort) if _sort > self._sort
  end

  def set_vname(vname = BookUtil.author_vname(self.zname))
    self.vname = vname
    self.vslug = BookUtil.make_slug(vname)
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
    unless author = find({zname: zname})
      return create!(zname, vname || BookUtil.author_vname(zname))
    end

    author.update({vname: vname}) if vname && author.vname != vname
    author
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
