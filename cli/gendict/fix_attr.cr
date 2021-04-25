require "../../src/libcv/vdict"
require "./shared/*"

module ENG
  extend self

  NOUN_FILE = QtUtil.path("_system/english-nouns.txt")
  ADJE_FILE = QtUtil.path("_system/english-adjectives.txt")

  ENG_NOUNS = Set(String).new File.read_lines(NOUN_FILE)
  ENG_ADJES = Set(String).new File.read_lines(ADJE_FILE)

  def is_noun?(words : Array(String))
    words.any? { |w| ENG_NOUNS.includes?(w) }
  end

  def is_verb?(words : Array(String))
    words.any? { |w| w.starts_with?("to ") }
  end

  def is_adje?(words : Array(String))
    words.any? { |w| ENG_ADJES.includes?(w) }
  end
end

module VIE
  extend self

  def is_noun?(key : String, val : String)
    return true if val != val.downcase || noun_and_adje?(key, val)

    case key
    when .ends_with?("者"), .ends_with?("人")
      true
    else
      false
    end
  end

  def is_adje?(key : String, val : String)
    noun_and_adje?(key, val)
  end

  def noun_and_adje?(key : String, val : String)
    return false if key.size < 2

    return true if key.ends_with?("色") && val.starts_with?("màu ")
    return true if key.ends_with?("上") && val.includes?("trên ")
    return true if key.ends_with?("下") && val.includes?("dưới ")
    return true if key.ends_with?("间") && val.includes?("giữa ")
    return true if key.ends_with?("中") && val.includes?("trong ")
    return true if key.ends_with?("里") && val.includes?("trong ")
    return true if key.ends_with?("内") && val.includes?("trong ")
    return true if key.ends_with?("中心") && val.includes?("trong ")
    return true if key.ends_with?("中央") && val.includes?("trong ")

    false
  end

  def hanviet?(key : String, val : String)
    Cvmtl.hanviet.translit(key, false).to_s == val.to_s
  end
end

TERMS = Set(String).new
NOUNS = Set(String).new
VERBS = Set(String).new
ADJES = Set(String).new

input = CV::Vdict.cc_cedict
puts "- cc_cedict size: #{input.size}"

input.each do |term|
  words = term.vals.map { |x| x.sub(/\[.+\]\s*/, "").split("; ") }.flatten.uniq

  TERMS.add(term.key)
  NOUNS.add(term.key) if ENG.is_noun?(words)
  VERBS.add(term.key) if ENG.is_verb?(words)
  ADJES.add(term.key) if ENG.is_adje?(words)
end

puts "- nouns: #{NOUNS.size}, verbs: #{VERBS.size}, adjes: #{ADJES.size}"

QtDict.load("localqt/vietphrase.txt").each do |key, vals|
  next unless fval = vals.first?

  NOUNS.add(key) if VIE.is_noun?(key, fval)
  ADJES.add(key) if VIE.is_adje?(key, fval)

  next unless key =~ /.的./
  k_left, k_right = key.split("的", 2)

  NOUNS.add(k_right) if TERMS.includes?(k_right)
  NOUNS.add(k_left) if fval.includes?("của")
end

puts "- nouns: #{NOUNS.size}, verbs: #{VERBS.size}, adjes: #{ADJES.size}"

mtime = CV::Vterm.mtime(Time.utc(2021, 4, 24, 0, 0, 0))

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
