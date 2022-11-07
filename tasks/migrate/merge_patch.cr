require "colorize"
require "file_utils"
require "compress/zip"

require "../src/appcv/nvchap/*"

INP_DIR = Path["var", "chaps", "texts"]

# Dir.children(INP_DIR).each do |sname|
#   next unless sname.starts_with?('@')

sname_dir = INP_DIR / "miscs"

Dir.children(sname_dir).each do |s_bid|
  book_dir = sname_dir.join(s_bid)
  Dir.glob(book_dir.join("*/")).each do |dir|
    FileUtils.rm_rf(dir)
  end
  # Dir.glob(book_dir.join("*-users.tsv")).each do |file|
  # merge(file)
  # end
end

# end

def merge(inp_path)
  input = CV::ChRepo0.new(inp_path)
  output = CV::ChRepo0.new(inp_path.sub("-users", ""))

  zip_path = inp_path.sub(".tsv", ".zip")

  text_dir = inp_path.sub(".tsv", "")
  txt_files = [] of String

  input.data.each_value do |info|
    output.set(info)

    info.stats.parts.times do |cpart|
      file_path = File.join(text_dir, "#{info.chidx}-#{cpart}.txt")
      raise "Missing #{file_path}" unless File.exists?(file_path)
      txt_files << file_path
    end
  end

  File.delete(inp_path)
  return if txt_files.empty?

  puts "- adding: #{text_dir}: #{txt_files.size}"
  system("zip", ["-rjmq", zip_path].concat(txt_files))

  output.save!
end
