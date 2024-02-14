# require "../../_data/_data"

# class WN::WninfoCard
#   include Crorm::Model
#   schema "wninfos", :postgres, strict: false

#   field btitle_vi : String
#   field author_vi : String

#   field igenres : Array(Int32) = [] of Int32

#   field scover : String = ""
#   field bcover : String = ""

#   field voters : Int32 = 0
#   field rating : Int32 = 0
#   field status : Int32 = 0

#   def genres : Array(String)
#     igenres.map { |x| GENRES[x]? || "Loại khác" }.uniq!
#   end

#   GENRES = {} of Int32 => String

#   File.each_line("var/_conf/fixes/genres_vi.tsv") do |line|
#     next if line.empty?
#     id, name = line.split('\t')
#     GENRES[id.to_i] = name
#     {id.to_i, name}
#   end

#   def self.preload(ids : Enumerable(Int32))
#     ids.empty? ? [] of self : query.where { id.in? ids }
#   end
# end
