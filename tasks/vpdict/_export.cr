require "./shared/*"
require "../../src/mtlv2/*"

CORPUS = "_db/vpinit/corpus"
QTRANS = "_db/vpinit/qtrans"

class Counter
  getter data = Hash(String, Float64).new(0.0)

  def add(key : String, value = 1)
    @data[key] += value
  end

  def should_reject?(key)
    key =~ /^\d/
  end

  def init!
    File.read_lines("#{CORPUS}/xinhua-all.txt").each { |key| add(key, 2) }
    CV::VpDict.load("trungviet").data.each { |term| add(term.key, 2.5) }
    CV::VpDict.load("cc_cedict").data.each { |term| add(term.key, 1.5) }

    File.read_lines("#{CORPUS}/pfrtag.top.tsv").each do |line|
      key, _ = line.split('\t', 2)
      add(key, 1) unless should_reject?(key)
    end

    File.read_lines("#{CORPUS}/pkuseg-books.tsv").each do |line|
      key, count = line.split('\t')
      value = map_count(count.to_i)

      case key.size
      when 2 then value -= 0.5
      when 3 then value -= 0.25
      end

      add(key, value) unless should_reject?(key)
    end
  end

  private def map_count(count : Int32)
    case count
    when .>(500) then 3
    when .>(200) then 2.5
    when .>(150) then 2
    when .>(100) then 1.5
    when .>(50)  then 1
    when .>(10)  then 0.5
    else              0
    end
  end

  def export!
    regular = Set(String).new
    suggest = Set(String).new

    @data.each do |key, val|
      if val >= 2.5
        regular << key
      elsif val >= 0.5
        suggest << key
      end
    end

    {regular, suggest}
  end
end

class Postag
  DIR = "_db/vpinit/corpus"

  alias Counter = Hash(String, Int32)
  getter data = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }

  def initialize(file : String, mode = 2)
    return if mode == 0
    return unless mode > 1 || File.exists?(file)

    File.each_line(file) do |line|
      frags = line.split('\t')
      next if frags.size < 2
      word = frags[0]

      frags[1..].each do |frag|
        list = frag.split(":")
        tag = list[0]
        count = list[1]?.try(&.to_i) || 1

        @data[word][tag] = count
      end
    end

    puts " - <postag> #{file} loaded, entries: #{@data.size}"
  end

  def get(word : String)
    @data[word]?.try(&.first_key)
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
    next if key.starts_with?("第")
    if key.size > 2
      term = regular_out.new_term(key, [val], tag, mtime: 1, uname: "[qt]")
      regular_out.set(term)
    else
      term = suggest_out.new_term(key, [val], tag, mtime: 1, uname: "[qt]")
      suggest_out.set(term)
    end
  elsif !tag.empty?
    next if key.starts_with?("第")
    cap_mode = {"nr", "ns", "nt", "nz"}.includes?(tag) ? 2 : 0
    val = HANVIET_MTL.translit(key, cap_mode: cap_mode).to_s
    if key.size > 3
      term = regular_out.new_term(key, [val], tag, mtime: 1, uname: "[hv]")
      regular_out.set(term)
    else
      term = suggest_out.new_term(key, [val], tag, mtime: 1, uname: "[hv]")
      suggest_out.set(term)
    end
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

  val = term.vals.first(3).map(&.sub("", "").strip)
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

app_file = "_db/vpdict/logs/regular.appcv.tsv"
regular_out.load!(app_file) if File.exists?(app_file)
regular_out.save!

pleb_file = "_db/vpdict/plebs/regular.appcv.tsv"
regular_pleb.load!(pleb_file) if File.exists?(pleb_file)
regular_pleb.save!

suggest_inp.each do |key|
  next unless key =~ /\p{Han}/

  tag = Postag.get_tag(key)

  if old_term = old_suggest.find(key)
    val = old_term.vals.first(3).map(&.sub("", "").strip)

    rank = key.size.in?(2..3) ? old_term.prio + 2 : 3
    mtime, uname, privi = old_term.mtime, old_term.uname, old_term.power

    term = suggest_out.new_term(key, val, tag, rank, mtime, uname, privi)
    suggest_out.set(term)
  elsif val = lexicon.fval(key)
    term = suggest_out.new_term(key, [val], tag, mtime: 1, uname: "[qt]")
    suggest_out.set(term)
  elsif !tag.empty?
    cap_mode = {"nr", "ns", "nt", "nz"}.includes?(tag) ? 2 : 0
    val = HANVIET_MTL.translit(key, cap_mode: cap_mode).to_s
    term = suggest_out.new_term(key, [val], tag, mtime: 1, uname: "[hv]")
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

app_file = "_db/vpdict/logs/suggest.appcv.tsv"
suggest_out.load!(app_file) if File.exists?(app_file)
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
    val = term.vals.first.sub("", "").strip
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

  book_inp.data.each do |key, tags|
    next unless key =~ /\p{Han}/
    next if checked.includes?(key)
    next if regular_set.includes?(key)

    tag, count = tags.first

    case key.size
    when 1 then next
    when 2 then next if count < 50
    when 3 then next if count < 40
    else        next if count < 30
    end

    postag = CV::PosTag.from_str(tag)
    next unless postag.nouns?
    cap_mode = postag.names? ? 2 : 0

    val = HANVIET_MTL.translit(key, cap_mode: cap_mode).to_s
    rank = key.size == 1 ? 2 : 3

    new_term = book_out.new_term(key, [val], postag.to_str, rank, 1, "[hv]")
    book_out.set(new_term)
  end

  app_file = "_db/vpdict/logs/books/#{bhash}.appcv.tsv"
  book_out.load!(app_file) if File.exists?(app_file)
  book_out.save!

  pleb_file = "_db/vpdict/pleb/books/#{bhash}.appcv.tsv"
  book_pleb.load!(pleb_file) if File.exists?(pleb_file)
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
