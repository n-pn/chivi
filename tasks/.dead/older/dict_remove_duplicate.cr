require "../../src/mtlv1/*"

DIR = "var/vpdicts"

def remove_duplicates(dname : String)
  dict = CV::VpDict.load(dname)
  dups = 0

  dict.trie.each do |node|
    next unless base = node.base
    next unless priv = node.privs["!#{base.uname}"]?
    next unless similar?(base, priv)
    priv._flag = 2
    dups += 1
  end

  puts "- duplicate: #{dups}"
  dict.save!
end

def similar?(base, priv)
  return false if base.rank != priv.rank
  return false if base.ptag != priv.ptag
  base.val == priv.val
end

remove_duplicates("regular")
remove_duplicates("suggest")
CV::VpDict.udicts.each do |udict|
  remove_duplicates(udict)
end
