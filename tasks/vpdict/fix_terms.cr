require "../../src/cvmtl/mt_core"

DIR = "var/vpdicts/v1/novel"

AFFIL_FILE = "var/vpdicts/naffil.tsv"

class Trie
  property val : String? = nil
  getter trie = Hash(Char, Trie).new { |h, c| h[c] = Trie.new }
  forward_missing_to @trie
end

def load_dict(file : String)
  output = Trie.new

  File.read_lines(file).each do |line|
    key, val = line.split('\t', 2)

    trie = output
    key.chars.reverse_each { |c| trie = trie[c] }
    trie.val = val
  end

  output
end

SHORTS = {
  '府' => "? phủ", # '城' => "thành"
  '朝' => "triều ?",
}

def translate(inp : String, dict : Trie) : String
  if val = find_defined(key)
    return val if val != val.downcase
  end

  if inp.size == 2
    return translate(inp) unless val = SHORTS[inp[-1]]?
    return val.sub("?", translate(inp[0].to_s))
  end

  chars = inp.chars

  trie = dict
  name = nil

  while char = chars.pop?
    break unless trie = trie[char]?
    next unless val = trie.val

    name = val.sub("?", translate(chars.join, dict))
  end

  name || translate(inp)
end

def translate(key : String) : String
  if val = find_defined(key)
    return val # if val != val.downcase
  end

  hanviet = CV::MtCore.hanviet_mtl.translit(key, false)
  CV::TextUtil.titleize(hanviet.to_s)
end

def find_defined(key : String)
  return unless term = CV::VpDict.regular.find(key)
  term.val.first if term.attr[0]? == 'n'
end

####

AFFIL = load_dict(AFFIL_FILE)

def fix_terms(file : String)
  vdict = CV::VpDict.new(file)

  fixed = 0

  vdict.list.each do |term|
    next if term._flag > 0 || term.uname != "~" || term.key.size == 1
    next unless term.attr == "nn"

    old_val = term.val.first
    new_val = translate(term.key, AFFIL)

    color = old_val != new_val ? :red : (term.key.size > 2 ? :green : :blue)
    puts "- [#{term.key}] #{old_val} => #{new_val}".colorize(color)
  end

  vdict.save! if fixed > 0
end

files = Dir.glob("#{DIR}/*.tsv")
input = files.sample(20)

input.each_with_index(1) do |file, idx|
  puts "\n[#{idx}/#{files.size}] #{File.basename(file)}"
  fix_terms(file)
end
