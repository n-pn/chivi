require "tabkv"
require "../cvmtl/vp_dict"

class CV::PostagInit
  alias CountTag = Hash(String, Int32)
  alias CountStr = Hash(String, CountTag)

  DIR = "var/vpdicts/v1/_init"

  def self.load(name : String, fixed = false)
    new("#{DIR}/#{name}.tsv", fixed: fixed)
  end

  SEP_1 = '\t'
  SEP_2 = '¦'

  getter data : CountStr

  def initialize(@file : String, reset = false, fixed = false)
    @data = CountStr.new do |h, k|
      h[k] = CountTag.new { |h2, k2| h2[k2] = 0 }
    end

    load!(@file, fixed: fixed) if !reset && File.exists?(@file)
  end

  def load!(file : String = @file, fixed = false)
    File.each_line(file) do |line|
      next if line.empty?
      input = line.split(SEP_1)

      term = input.first
      next if term.empty?

      input[1..].each do |counts|
        tag, count = counts.split(SEP_2, 2)
        update_count(term, fixed ? tag : fix_tag(tag), count.to_i)
      end
    end
  end

  def load_raw!(file : String)
    File.each_line(file) do |line|
      line.split(SEP_1) do |word|
        list = word.split(' ')

        next unless tag = list.pop?
        term = list.size == 1 ? list.first : list.join(' ')

        update_count(term, fix_tag(tag), 1)
      end
    end
  end

  def fix_tag(tag : String)
    case tag
    when "PER"  then "nr"
    when "LOC"  then "nn"
    when "ORG"  then "nn"
    when "TIME" then "t"
    when "nw"   then "nz"
    else             tag
    end
  end

  @[AlwaysInline]
  def update_count(term : String, tag : String, count = 1)
    @data[term][tag] &+= count
  end

  def save!(file : String = @file, sort = false)
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

  def serialize(term : String, value : CountTag)
    value.map { |x, y| "#{x}¦#{y}" }.unshift(term).join('\t')
  end

  def serialize(value : CountTag)
    value.map { |x, y| "#{x}¦#{y}" }.join('\t')
  end

  def fix_ptag?(term : VpTerm, ptag : String) : String?
    attr = term.attr
    return ptag if attr.in?("", "i", "l", "j")

    fval = term.val.first
    not_name = fval.downcase == fval || term.uname == "[hv]"

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
    return false unless char = attr[0]?

    case ptag
    when "v"  then char == 'v'
    when "n"  then char == 'n' || attr == "kn"
    when "r"  then char == 'r'
    when "m"  then char == 'm'
    when "a"  then char == 'b' || attr == "a" || attr == "al"
    when "c"  then char == 'c'
    when "p"  then char == 'p'
    when "u"  then char == 'u'
    when "xc" then attr.in?("o", "y", "e")
    else           attr == ptag || attr == "na"
    end
  end

  record Conflict, term : VpTerm, ptag : String do
    def to_json(jb)
      {
        ptag:  ptag,
        attr:  term.attr,
        key:   term.key,
        val:   term.val[0],
        uname: term.uname,
        mtime: term.utime,
      }.to_json(jb)
    end
  end

  TARGETS = {} of String => VpDict

  def self.get_target(target = "regular")
    TARGETS[target] ||= VpDict.new("#{DIR}/patch/#{target}-tags.tsv")
  end

  class_getter similar = VpDict.new("#{DIR}/patch/similar-tags.tsv")
  class_getter topatch = VpDict.new("#{DIR}/patch/topatch-tags.tsv")

  def match(target = "regular")
    matcher = VpDict.load(target)
    conflicts = [] of Conflict

    @data.each do |key, counts|
      next if @@topatch.find(key) || @@similar.find(key)
      ptag = counts.first_key

      next unless term = matcher.find(key)

      if similar?(term.attr, ptag)
        @@similar.set(VpTerm.new(key, term.val, term.attr, mtime: 0))
      else
        # next if PFR14.includes?(key)

        if attr = fix_ptag?(term, ptag)
          @@topatch.set!(VpTerm.new(key, term.val, attr, mtime: 0))
        else
          conflicts << Conflict.new(term, ptag)
        end
      end
    end

    @@similar.save!
    conflicts
  end
end
