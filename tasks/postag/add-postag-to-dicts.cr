require "../../src/libcv/*"
require "./shared/*"

def hanviet(key : String)
  Cvmtl.hanviet.translit(key, false).to_s
end

def hanviet?(key : String, val : String)
  hanviet(key) == val
end

mtime = CV::VpTerm.mtime(Time.utc(2021, 4, 24, 0, 0, 0))

def add_tag(input : CV::Vdict, out_file : String)
  output = File.open(out_file)
end

CV::Vdict.regular.each do |term|
  next if term.mtime >= mtime # skip corrected entries
  next unless fval = term.vals.first?

  term.attr = 0 # reset attrs
  term.attr |= 1 if NOUNS.includes?(term.key) || VIE.is_noun?(term.key, fval)
  term.attr |= 4 if ADJES.includes?(term.key) || VIE.is_adje?(term.key, fval)
  term.attr |= 2 if VERBS.includes?(term.key)

  # puts term if term.attr > 0
end

CV::Vdict.regular.save!
