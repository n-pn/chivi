require "./_base"

class YS::Author
  include Clear::Model

  self.table = "author"
  column vname : String = ""
end

class YS::CvBook
  include Clear::Model

  self.table = "nvinfos"
  primary_key

  belongs_to author : Author, foreign_key_type: Int32

  column vname : String
  column bslug : String

  # column bhash : String
  # getter dname : String { "-" + bhash }

  column igenres : Array(Int32) = [] of Int32

  column scover : String = ""
  column bcover : String = ""

  column voters : Int32 = 0
  column rating : Int32 = 0
  column status : Int32 = 0

  column utime : Int64 = 0

  def bgenre
    GENRES[self.igenres.first]? || "Loại khác"
  end

  GENRES = {} of Int32 => String

  File.each_line("var/books/fixes/genres_id.tsv") do |line|
    next if line.empty?
    id, name = line.split('\t')
    GENRES[id.to_i] = name
    {id.to_i, name}
  end
end
