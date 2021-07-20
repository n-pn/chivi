require "./shared/*"
require "../../src/mtlv2/*"

CORPUS = "_db/vpinit/corpus"
QTRANS = "_db/vpinit/qtrans"

class Counter
  getter data = Hash(String, Float64).new(0.0)

  def add(key : String, value = 1)
    @data[key] += value
  end

  def init!
    add_vpdict("trungviet", 2)
    add_vpdict("cc_cedict", 1.5)
    add_file("#{CORPUS}/xinhua-all.txt", 1.5)
    add_file("#{CORPUS}/pfrtag.top.tsv")

    File.read_lines("_db/vpinit/corpus/pkuseg-books.tsv").each do |line|
      key, count = line.split('\t')
      add(key, map_count(count.to_i))
    end
  end

  def add_vpdict(dname : String, value = 1)
    CV::VpDict.load(dname).data.each { |term| add(term.key, value) }
  end

  def add_file(file : String, value = 1)
    File.read_lines(file).each do |line|
      key = line.split('\t', 2).first
      add(key, value)
    end
  end

  private def map_count(count : Int32)
    case count
    when .>(100) then 2
    when .>(50)  then 1
    else              0.5
    end
  end

  def export!
    regular = Set(String).new
    suggest = Set(String).new

    @data.each do |key, val|
      (val >= 2.0 ? regular : suggest) << key
    end

    {regular, suggest}
  end
end

class Postag
  DIR = "_db/vpinit/corpus"
  getter data = {} of String => String

  def initialize(file : String, mode = 2)
    return if mode == 0
    return unless mode > 1 || File.exists?(file)

    File.each_line(file) do |line|
      frags = line.split('\t')
      next if frags.size < 2
      word, tag = frags
      @data[word] ||= tag.split(":").first
    end

    puts " - <postag> #{file} loaded, entries: #{@data.size}"
  end

  def get(word : String)
    @data[word]?
  end

  @@cache = {} of String => self

  def self.load(file : String, mode = 2)
    @@cache[file] ||= new("#{DIR}/#{file}.tsv", mode: mode)
  end

  def self.get_tag(word : String)
    case
    when tag = load("pfrtag.top").get(word)   then tag
    when tag = load("pkuseg-bests").get(word) then tag
    when tag = load("pfrtag").get(word)       then tag
    when tag = load("pkuseg-words").get(word) then tag
    else                                           ""
    end
  end
end

def init_vietphrase!(redo = true)
  input = QtDict.new("_db/vpinit/vietphrase.txt", preload: !redo)
  return input unless redo

  input.load!("_db/vpinit/qtrans/localqt/names2.txt")
  input.load!("_db/vpinit/qtrans/localqt/vietphrase.txt")
  input.load!("_db/vpinit/qtrans/localqt/names1.txt")

  input.load!("_db/vpinit/qtrans/outerqt/1-ttv-thtgiang/VietPhrase.txt")
  input.load!("_db/vpinit/qtrans/outerqt/1-ttv-thtgiang/Names.txt")

  Dir.glob("_db/vpinit/qtrans/fixture/*.txt") { |file| input.load!(file) }

  input.load!("_db/vpinit/qtrans/localqt/fixes/checked-by-hand.txt")
  input.load!("_db/vpinit/qtrans/localqt/fixes/erotic-words.txt")
  input.load!("_db/vpinit/qtrans/localqt/fixes/fix-existing-entries.txt")
  input.load!("_db/vpinit/qtrans/localqt/fixes/resolve-lettercase.txt")

  input.tap(&.save!)
end

counter = Counter.new.tap(&.init!)
regular_inp, suggest_inp = counter.export!
puts "- regular: #{regular_inp.size}, suggest: #{suggest_inp.size}"

lexicon = init_vietphrase!(redo: false)

HANVIET_MTL = CV::MtCore.hanviet_mtl
old_regular = CV::Vdict.regular
old_suggest = CV::Vdict.suggest

regular_out = CV::VpDict.load("regular", reset: true)
suggest_out = CV::VpDict.load("suggest", reset: true)
regular_pleb = CV::VpDict.load("pleb_regular", reset: true)

CV::VpDict.suffix = "_seed"

regular_set = Set(String).new

regular_inp.each do |key|
  next unless key =~ /\p{Han}/
  regular_set << key

  tag = Postag.get_tag(key)

  if old_term = old_regular.find(key)
    val = old_term.vals.first(3)
    rank = key.size.in?(2..3) ? old_term.prio + 2 : 3
    mtime, uname, privi = old_term.mtime, old_term.uname, old_term.power

    term = regular_out.new_term(key, val, tag, rank, mtime, uname, privi)
    regular_out.set(term)
  elsif val = lexicon.fval(key)
    term = regular_out.new_term(key, [val], tag, mtime: 1, uname: "qt")
    regular_out.set(term)
  elsif !tag.empty?
    cap_mode = {"nr", "ns", "nt", "nz"}.includes?(tag) ? 2 : 0
    val = HANVIET_MTL.translit(key, cap_mode: cap_mode).to_s
    term = regular_out.new_term(key, [val], tag, mtime: 1, uname: "[seed]")
    regular_out.set(term)
  else
    val = HANVIET_MTL.translit(key, false).to_s
    term = suggest_out.new_term(key, [val])
    suggest_out.set(term)
  end
end

old_regular.each do |term|
  next if regular_inp.includes?(term.key)
  regular_set << term.key

  tag = Postag.get_tag(term.key)

  val = term.vals.first(3)
  rank = term.key.size.in?(2..3) ? term.prio + 2 : 3
  mtime, uname, privi = term.mtime, term.uname, term.power

  new_term = regular_pleb.new_term(term.key, val, tag, rank, mtime, uname, privi)

  if mtime > 0 && term.key =~ /\p{Han}/
    regular_out.set(new_term)
  else
    regular_pleb.set(new_term)
    suggest_out.set(new_term)
  end
end

regular_out.save!
regular_pleb.save!

suggest_inp.each do |key|
  next unless key =~ /\p{Han}/

  tag = Postag.get_tag(key)

  if old_term = old_suggest.find(key)
    val = old_term.vals.first(3)
    rank = key.size.in?(2..3) ? old_term.prio + 2 : 3
    mtime, uname, privi = old_term.mtime, old_term.uname, old_term.power

    term = suggest_out.new_term(key, val, tag, rank, mtime, uname, privi)
    suggest_out.set(term)
  elsif val = lexicon.fval(key)
    term = suggest_out.new_term(key, [val], tag, mtime: 1, uname: "[init]")
    suggest_out.set(term)
  elsif !tag.empty?
    cap_mode = {"nr", "ns", "nt", "nz"}.includes?(tag) ? 2 : 0
    val = HANVIET_MTL.translit(key, cap_mode: cap_mode).to_s
    term = suggest_out.new_term(key, [val], tag, mtime: 1, uname: "[seed]")
    suggest_out.set(term)
  end
end

old_suggest.each do |term|
  next if suggest_inp.includes?(term.key)
  tag = Postag.get_tag(term.key)

  val = term.vals.first(3)
  rank = term.key.size.in?(2..3) ? term.prio + 2 : 3
  mtime, uname, privi = term.mtime, term.uname, term.power

  new_term = suggest_out.new_term(term.key, val, tag, rank, mtime, uname, privi)
  suggest_out.set(new_term)
end

suggest_out.save!

def export_book(bhash, regular_set)
  checked = Set(String).new
  book_inp = Postag.load("pkuseg/#{bhash}", mode: 1)

  book_out = CV::VpDict.load(bhash, reset: true)
  book_pleb = CV::VpDict.load("pleb_#{bhash}")

  old_book = CV::Vdict.load(bhash)
  old_book.each do |term|
    checked << term.key

    tag = book_inp.get(term.key) || Postag.get_tag(term.key)
    val = term.vals.first
    upcase = val.downcase != val
    if tag.empty? || upcase
      tag = "nr"
    elsif term.attr == 1 || tag == "i" || tag == "j"
      tag == upcase ? "n" : "nr"
    else
      tag = upcase ? "nr" : tag
    end

    mtime, uname, privi = term.mtime, term.uname, term.power

    rank = term.key.size == 1 ? 2 : 3
    new_term = book_out.new_term(term.key, [val], tag, rank, mtime, uname, privi)

    if new_term.ptag.nouns? || new_term.ptag.adjts?
      book_out.set(new_term)
    elsif !regular_set.includes?(term.key)
      book_pleb.set(new_term)
    end
  end

  book_inp.data.each do |key, tag|
    next if checked.includes?(key)
    next if regular_set.includes?(key)

    postag = CV::PosTag.from_str(tag)
    next unless postag.nouns?
    cap_mode = postag.names? ? 2 : 0

    val = HANVIET_MTL.translit(key, cap_mode: cap_mode).to_s
    rank = key.size == 1 ? 2 : 3

    new_term = book_out.new_term(key, [val], postag.to_str, rank, 1, "[seed]")
    book_out.set(new_term)
  end

  book_out.save!
  book_pleb.save!
end

checked = Set(String).new
Dir.glob("#{CORPUS}/pkuseg/*.tsv").each do |file|
  bhash = File.basename(file, ".tsv")
  export_book(bhash, regular_set)
  checked << bhash
end

CV::Vdict.udicts.each do |bhash|
  next if checked.includes?(bhash)
  export_book(bhash, regular_set)
end
