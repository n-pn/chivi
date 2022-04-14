require "colorize"
require "tabkv"

require "../../src/cvmtl/vp_dict"
DIR = "_db/vpinit/bd_lac"

class Counter
  alias CountTag = Hash(String, Int32)

  alias CountStr = Hash(String, CountTag)

  SEP_1 = '\t'
  SEP_2 = '¦'

  getter data : CountStr

  def initialize(@file : String, load = false)
    @data = CountStr.new do |h, k|
      h[k] = CountTag.new { |h2, k2| h2[k2] = 0 }
    end

    load_parsed(@file) if load
  end

  def outdated?(time : Time)
    return true unless info = File.info?(@file)
    info.modification_time < time
  end

  @[AlwaysInline]
  def update_count(term : String, tag : String, count = 1)
    @data[term][tag] &+= count
  end

  def load_parsed(file : String = @file, correcting = false)
    File.each_line(file) do |line|
      next if line.empty?
      input = line.split(SEP_1)

      term = input.first
      next if term.empty?

      input[1..].each do |counts|
        tag, count = counts.split(SEP_2, 2)
        update_count(term, correcting ? correct_tag(tag) : tag, count.to_i)
      end
    end
  end

  def correct_tag(tag : String)
    case tag
    when "PER"  then "nr"
    when "LOC"  then "nn"
    when "ORG"  then "nn"
    when "TIME" then "t"
    when "nw"   then "nz"
    else             tag
    end
  end

  def save_output(file : String = @file, sort = false)
    File.open(file, "w") do |io|
      if sort
        output = @data.to_a
        output.sort_by! do |term, counts|
          {-counts.values.sum, -term.size}
        end
      else
        output = @data
      end

      output.each do |term, counts|
        io << term
        counts.each do |tag, count|
          io << SEP_1 << tag << SEP_2 << count
        end
        io << '\n'
      end
    end
  end

  def parse_lac(file : String)
    File.each_line(file) do |line|
      line.split(SEP_1) do |word|
        list = word.split(' ')

        next unless tag = list.pop?
        term = list.size == 1 ? list.first : list.join(' ')

        update_count(term, tag, 1)
      end
    end
  end

  def merge(other : self)
    other.data.each do |term, counts|
      counts.each do |tag, count|
        @data[term][tag] &+= count
      end
    end
  end
end

def serialize(term : String, value : Hash(String, Int32))
  value.map { |x, y| "#{x}¦#{y}" }.unshift(term).join('\t')
end

def serialize(value : Hash(String, Int32))
  value.map { |x, y| "#{x}¦#{y}" }.join('\t')
end

OUT_DIR = "_db/vpinit/outlac"

def init
  all_books = Counter.new("#{OUT_DIR}/lac-books.tsv").tap(&.load_parsed)
  all_ptags = Counter.new("#{OUT_DIR}/lac-ptags.tsv").tap(&.load_parsed)

  xinhua = Set(String).new File.read_lines("_db/vpinit/corpus/xinhua-all.txt")
  trungviet = Set(String).new File.read_lines("var/vpdicts/v1/fixed/trungviet.tsv").map(&.split('\t', 2).first)
  cc_cedict = Set(String).new File.read_lines("var/vpdicts/v1/fixed/cc_cedict.tsv").map(&.split('\t', 2).first)

  out_book = [] of String
  out_ptag = [] of String

  all_books.data.each do |term, counts|
    book_count = counts.values.sum
    book_count += 10 if xinhua.includes?(term)
    book_count += 20 if trungviet.includes?(term)
    book_count += 20 if cc_cedict.includes?(term)

    next unless term.size == 0 || book_count >= 50

    out_book << serialize(term, counts)
    out_ptag << serialize(term, all_ptags.data[term])
  end

  puts "output: #{out_book.size}"
  File.write("#{OUT_DIR}/all-books.tsv", out_book.join("\n"))
  File.write("#{OUT_DIR}/all-ptags.tsv", out_ptag.join("\n"))
end

def split_group(file : String, name : String)
  input = Counter.new("#{OUT_DIR}/#{file}").tap(&.load_parsed(correcting: false))

  out_united = Tabkv(String).new "#{OUT_DIR}/#{name}-united.tsv", :reset
  out_majory = Tabkv(String).new "#{OUT_DIR}/#{name}-majory.tsv", :reset
  out_differ = Tabkv(String).new "#{OUT_DIR}/#{name}-differ.tsv", :reset
  out_random = Tabkv(String).new "#{OUT_DIR}/#{name}-random.tsv", :reset

  input.data.each do |term, counts|
    if term !~ /\p{Han}/
      out_random.append(term, serialize(counts))
      next
    end

    if counts.size == 1
      out_united.append(term, serialize(counts))
      next
    end

    majory = counts.values.sum * 0.8

    if counts.first[1] >= majory
      out_majory.append(term, serialize(counts))
    else
      out_differ.append(term, serialize(counts))
    end
  end

  out_united.save!(clean: true)
  out_majory.save!(clean: true)
  out_differ.save!(clean: true)
  out_random.save!(clean: true)
end

PFR14 = Set(String).new File.read_lines("_db/vpinit/pfrtag.tsv").map(&.split('\t').first)

EPOCH = CV::VpTerm.mtime(Time.utc(2021, 9, 1))

def should_replace?(term : CV::VpTerm, ptag : String) : String?
  fval = term.val.first
  not_name = fval.downcase == fval || term.uname == "[hv]"

  attr = term.attr
  return ptag if attr.in?("", "i", "l", "j")

  case ptag
  when "nn"
    return ptag if attr.in?("ns", "nt", "n", "nz")
    return ptag if attr.in?("v") && !not_name
  when "t", "s"
    return ptag if attr == "n"
  when "nz"
    return ptag if attr == "n"
  when "a"
    return "al" if attr.in?("vl", "bl", "az") || term.key =~ /.(.)\1/
  when "ad"
    return ptag if attr.in?("a", "d")
  when "an"
    return ptag if attr.in?("a", "n")
  when "vd"
    return ptag if attr.in?("v", "vd")
  when "vn"
    return ptag if attr.in?("v", "n")
  when "nr"
    return not_name ? nil : ptag
  when "v"
    return "vo" if attr.in?("n")
  when "m"
    return "mq" if attr.in?("q", "n", "t")
  end

  case attr
  when "b", "bl", "a", "an"
    return "na" if ptag == "n"
  when "vl"
    return "vo" if ptag == "n"
  when "nr", "ns", "nt"
    return ptag if not_name
  when "nz"
    return ptag if not_name && ptag.in?("n", "v", "a")
  when "ng"
    return ptag if ptag.in?("n", "an", "vn")
  when "ag"
    return ptag if ptag.in?("a", "an", "ad")
  when "vg"
    return ptag if ptag.in?("v", "vd", "vn")
  else
    nil
  end
end

def similar?(attr : String, ptag : String)
  case ptag
  when "v"  then attr.in?("v", "vi", "vo", "vl", "vf", "vx")
  when "n"  then attr.in?("n", "nl", "nw", "na", "kn", "nn", "nt")
  when "r"  then attr.in?("r", "rr", "rz", "ry")
  when "m"  then attr.in?("m", "mq")
  when "a"  then attr.in?("a", "al")
  when "xc" then attr.in?("o")
  else           attr.in?(ptag, "na")
  end
end

# init
# split_group("all-books.tsv", "books")
# split_group("all-ptags.tsv", "ptags")

input = Counter.new("#{OUT_DIR}/#{ARGV.first}.tsv", load: true)

matcher = CV::VpDict.regular
patcher = CV::VpDict.new("var/vpdicts/v1/patch/regular-tags.tsv")
similar = CV::VpDict.new("var/vpdicts/v1/patch/similar-tags.tsv")
missing = CV::VpDict.new("var/vpdicts/v1/patch/missing-tags.tsv")

conflict = 0

FIXING = ARGV.includes?("--fix")

input.data.each do |key, counts|
  next if patcher.find(key) || similar.find(key)
  ptag = counts.first_key

  unless term = matcher.find(key)
    missing.set!(CV::VpTerm.new(key, ["!"], ptag, mtime: 0))
    next
  end

  if similar?(term.attr, ptag)
    similar.set!(CV::VpTerm.new(key, term.val, term.attr, mtime: 0))
  else
    # next if PFR14.includes?(key)

    color = term.attr.empty? ? :green : :red
    color = :blue if term.mtime >= EPOCH

    if attr = should_replace?(term, ptag)
      new_term = CV::VpTerm.new(key, term.val, attr, mtime: 0)
      patcher.set!(new_term)
      next
    end

    conflict += 1
    puts "\n- <#{conflict}> [#{key}=#{term.val.join('/')} <#{term.uname}>] new: #{ptag} -- old: #{term.attr}".colorize(color)

    next unless FIXING
    resolve = color == :blue ? term.attr : ptag

    print "Resolve (1: #{ptag.colorize.yellow}, 2: #{term.attr.colorize.yellow}, s: skip, else: #{resolve.colorize.yellow}): "

    case gets.try(&.strip)
    when "1" then resolve = ptag
    when "2" then resolve = term.attr
    when "3"
      print "  Manual: "
      resolve = gets.try(&.strip) || resolve
    when "s" then next
    end

    patcher.set!(CV::VpTerm.new(key, term.val, resolve, mtime: 0))
  end
end

similar.save!
missing.save!

puts "similar: #{similar.size}, patches: #{patcher.size}, missing: #{missing.size}".colorize.yellow
puts "conflict: #{conflict}".colorize.red
