require "colorize"
require "tabkv"

require "../../src/_init/postag_init"
require "../../src/cvmtl/mt_core"

DIR = "_db/vpinit/bd_lac"

class Trie
  property val : String? = nil
  getter trie = Hash(Char, Trie).new { |h, c| h[c] = Trie.new }
  forward_missing_to @trie
end

def build_ptitle(file : String)
  output = Trie.new

  File.read_lines(file).each do |line|
    key, val = line.split('\t', 2)

    trie = output
    key.chars.reverse_each { |c| trie = trie[c] }
    trie.val = val
  end

  output
end

PTITLE = build_ptitle("var/vpdicts/ptitle.tsv")

def translate_person(inp : String) : String
  chars = inp.chars

  trie = PTITLE
  name = nil

  while char = chars.pop?
    break unless trie = trie[char]?
    next unless val = trie.val
    name = translate(chars) + " " + val
  end

  name || translate(inp)
end

def extract_book(name : String)
  # min_count = File.read_lines("#{DIR}/#{name}/_all.log").size
  min_count = 20

  dname = name.split("-").last
  vdict = CV::VpDict.load("-#{dname}", mode: -1)
  vdict.load!(vdict.flog) if File.exists?(vdict.flog)

  hints = CV::PostagInit.new("var/vpdicts/v0/novel/#{name}.tag", reset: true)

  input = CV::PostagInit.new("#{DIR}/#{name}/_all.sum", fixed: false)
  input.data.each do |key, counts|
    counts = counts.to_a.sort(&.[1].-)

    ptag, count = counts.first
    next if count < min_count
    next unless ptag.in?("nr", "nn", "nw")
    ptag = "nz" if ptag == "nw"

    if old_term = vdict.find(key)
      val = old_term.val
      uname = old_term.uname
      mtime = old_term.mtime + 1
    else
      val = [ptag == "nr" ? translate_person(key) : translate(key)]
      uname = "[hv]"
      mtime = 0
    end

    vdict.set(CV::VpTerm.new(key, val, ptag, mtime: mtime, uname: uname))
  end

  vdict.save!
end

Dir.each_child(DIR) do |dir|
  extract_book(dir)
end

# pp! translate_person("马总")
# pp! translate_person("李居士")
# pp! translate_person("黄局长")
# pp! translate_person("暮雪公主")
# pp! translate_person("吴克明")
# pp! translate_person("夏秘书")
