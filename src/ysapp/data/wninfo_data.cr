require "./_base"
require "crorm/model"

class YS::Author
  include Crorm::Model
  schema "authors", :postgres, strict: false

  field zname : String = ""
  field vname : String = ""

  class_getter known_authors : Set(String) do
    PG_DB.query_all("select zname from authors", as: String).to_set
  end
end

class YS::Wninfo
  include Clear::Model
  self.table = "wninfos"

  primary_key type: :serial

  column btitle_vi : String
  column author_vi : String

  column bslug : String

  column igenres : Array(Int32) = [] of Int32

  column scover : String = ""
  column bcover : String = ""

  column voters : Int32 = 0
  column rating : Int32 = 0
  column status : Int32 = 0

  column utime : Int64 = 0

  def genres : Array(String)
    igenres.map { |x| GENRES[x]? || "Loại khác" }.uniq!
  end

  GENRES = {} of Int32 => String

  File.each_line("var/_conf/fixes/genres_vi.tsv") do |line|
    next if line.empty?
    id, name = line.split('\t')
    GENRES[id.to_i] = name
    {id.to_i, name}
  end

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : query.where { id.in? ids }
  end
end
