DIR = "var/books/fixes"
require "../../src/_util/char_util"

def update_file(inp_path : String)
  out_file = File.open(inp_path + ".fix", "w")

  File.each_line(inp_path) do |line|
    if line.empty?
      out_file.puts
      next
    end

    inp_name, out_name = line.split('\t')
    inp_name = CharUtil.canonicalize(inp_name, true).sub("　　", "  ")
    out_name = CharUtil.canonicalize(out_name, false)
    out_file << inp_name << '\t' << out_name << '\n'
  end

  out_file.close
end

update_file "#{DIR}/authors_zh.tsv"
