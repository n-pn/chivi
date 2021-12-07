require "../src/cvmtl/vp_dict"

DIR = "db/vpdicts"

def import(name : String, type = "core")
  output = CV::VpDict.load(name, reset: false)

  files = Dir.glob("#{DIR}/#{type}/#{name}/*.tsv")
  files.each do |file|
    dict = CV::VpDict.new(file)
    is_base = File.basename(file).starts_with?("_base")

    dict.data.each do |term|
      next if term._flag > 1
      term.to_priv! unless is_base
      output.set(term)
    end
  end

  output.save!
end

import("regular")
import("combine")

Dir.children("#{DIR}/uniq").each do |book|
  import(book, "uniq")
end
