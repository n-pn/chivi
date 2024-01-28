record V1Term, zstr : String, cpos : String, vstr : String, attr : String do
  def initialize(cols : Array(String))
    @zstr, @cpos, @vstr, @attr = cols
  end

  def self.load_tsv(tsv_path : String)
    output = [] of self
    File.each_line(tsv_path, chomp: true) do |line|
      output << new(line.split('\t'))
    end
    output
  end
end

v1_terms = V1Term.load_tsv("var/mtdic/mt_v1/regular.tsv")

puts v1_terms.size
