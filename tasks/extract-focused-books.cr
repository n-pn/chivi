INP_DIR = "_db/vi_users/marks"

books = Dir.children(INP_DIR).map { |x| File.basename(x, ".tsv") }
puts books
