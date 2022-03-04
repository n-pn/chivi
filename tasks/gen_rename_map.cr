DIR = "var/nvinfos/autos"

require "../src/appcv/shared/book_util"

record Bname, btitle : String, author : String

def load_index(sname : String)
  index_dir = File.join(DIR, sname, "_index")
  if File.exists?(index_dir)
    input = File.glob("#{index_dir}/*.tsv")
  else
    input = [index_dir + ".tsv"]
  end

  output = [] of Bname
  input.each do |file|
    output = read_index(file, output)
  end

  output
end

def read_index(file : String, output = [] of Bname)
  File.read_lines(file).each do |line|
    _, _, btitle, author = line.split('\t')
    output << Bname.new(btitle, author)
  end

  output
end

changed = Set(Bname).new

Dir.children(DIR).each do |sname|
  index = load_index(sname)
index.each do |bname|
    btitle, author =

end
end
