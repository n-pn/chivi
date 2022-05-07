require "colorize"
require "tabkv"

require "../../src/_init/postag_init"
require "../../src/libcv/tl_util"

def similar?(attr : String, ptag : String)
  return true if attr == ptag
  return attr.in?("ns", "nt") if ptag == "nn"
  attr.in?("nz", "nw") && ptag.in?("nz", "nw")
end

def extract_book(file : String)
  # min_count = File.read_lines("#{DIR}/#{name}/_all.log").size

  dname = File.basename(file, ".tag").split("-").last
  vdict = CV::VpDict.load("-#{dname}", mode: -1)
  vdict.load!(vdict.flog) if File.exists?(vdict.flog)

  input = CV::PostagInit.new(file)
  input.data.each do |key, counts|
    ptag = counts.first_key

    next unless ptag.in?("nr", "nn", "nw")
    ptag = "nz" if ptag == "nw"

    if term = SIMILAR.find(key)
      next if similar?(term.attr, ptag)
    end

    if old_term = vdict.find(key)
      val = old_term.val
      uname = old_term.uname
      mtime = old_term.mtime + 1
    else
      val = [CV::TlUtil.translate(key, ptag)]
      uname = "[hv]"
      mtime = 0
    end

    vdict.set(CV::VpTerm.new(key, val, ptag, mtime: mtime, uname: uname))
  end

  vdict.save!
end

DIR = "var/vpdicts/v0"

SIMILAR = CV::VpDict.new("#{DIR}/patch/similar-tags.tsv")

files = Dir.glob("#{DIR}/novel/*.tag")
files.each_with_index(1) do |file, idx|
  puts "- <#{idx}/#{files.size}> #{file}" if idx % 100 == 0
  extract_book(file)
end
