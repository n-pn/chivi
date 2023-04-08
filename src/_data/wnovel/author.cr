require "../../mtapp/v0_core"

require "../_base"
require "./wn_info"

class CV::Author
  include Clear::Model

  self.table = "authors"
  primary_key type: :serial

  # has_many nvinfos : Nvinfo, foreign_key: "author_id"

  column zname : String
  column vname : String

  # column vslug : String # for text search

  # column alter : Array(String) = [] of String
  column vdesc : String = ""

  column book_count : Int32 = 0
  # column post_count : Int32 = 0
  # column like_count : Int32 = 0
  # column view_count : Int32 = 0

  timestamps

  ####################

  def self.upsert!(zname : String, vname : String?) : Author
    if author = find({zname: zname})
      if vname && author.vname != vname
        author.update({vname: vname})
      end

      author
    else
      vname ||= MT::V0Core.tl_hvname(zname)
      new({zname: zname, vname: vname}).tap(&.save!)
    end
  end

  CACHE_INT = RamCache(Int64, self).new(2048)

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) }
  end
end
