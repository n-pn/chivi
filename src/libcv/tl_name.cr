require "./mt_core"
require "./vp_dict"

# module CV::TlUtil
#   extend self

#   class Trie
#     property val : String? = nil
#     getter trie = Hash(Char, Trie).new { |h, c| h[c] = Trie.new }
#     forward_missing_to @trie
#   end

#   def load_trie(file : String)
#     root = Trie.new

#     File.read_lines(file).each do |line|
#       next if line.empty?

#       key, val = line.split('\t', 2)
#       trie = root
#       key.chars.reverse_each { |c| trie = trie[c] }
#       trie.val = val
#     end

#     root
#   end

#   NR_TAGS = ["nr", "n", ""]
#   NN_TAGS = ["nn", "ns", "nt", "n", ""]
#   NZ_TAGS = ["nz", "n", ""]

#   NN_SHORTS = {
#     '府' => "? phủ", # '城' => "thành"
#     '族' => "? tộc",
#     '营' => "doanh ?",
#     '朝' => "triều ?",
#     '国' => "nước ?",
#     '人' => "người ?",
#     '地' => "đất ?",
#     '市' => "thành phố ?",
#     '家' => "? gia",
#     '村' => "thôn ?",
#   }

#   def translate(inp : String, tag : String, dict = "combine")
#     find_defined(inp, [tag, ""], dict).try { |x| return x }

#     case tag
#     when "nr" then convert(inp, self.ptitle, NR_TAGS)
#     when "nn"
#       return convert(inp, self.naffil, NN_TAGS) if inp.size > 2
#       return convert(inp, NN_TAGS) unless val = NN_SHORTS[inp[-1]]?
#       val.sub("?", convert(inp[0].to_s))
#     when "nz" then convert(inp, self.nother, NZ_TAGS)
#     else           convert(inp, [tag])
#     end
#   end

#   def convert(inp : String, trie : Trie, tags : Array(String))
#     chars = inp.chars
#     output = nil

#     while char = chars.pop?
#       break unless trie = trie[char]?
#       next unless val = trie.val
#       output = val.sub("?", convert(chars.join, trie, tags))
#       break if chars.empty?
#     end

#     output || convert(inp, tags.reject("n"))
#   end

#   def convert(key : String, tags = ["nr"]) : String
#     find_defined(key, tags) || TextUtil.titleize(MtCore.cv_hanviet(key, false))
#   end

#   def find_defined(key : String, tags : Array(String), dict = "regular") : String?
#     return unless term = VpDict.load(dict).find(key)
#     return unless term.attr.in?(tags) && term._flag == 0
#     term.val.first?.try { |x| return x unless x.empty? }
#   end

#   # pp! translate("马总", "nr")
#   # pp! translate("李居士", "nr")
#   # pp! translate("黄局长", "nr")
#   # pp! translate("暮雪公主", "nr")
#   # pp! translate("吴克明", "nr")
#   # pp! translate("夏秘书", "nr")
# end

class CV::TlName
  class Trie
    class Node
      property vals : Array(String)? = nil
      getter hash = Hash(Char, self).new { |h, c| h[c] = Node.new }
      forward_missing_to @hash
    end

    getter root = Node.new

    def initialize(file : String)
      File.read_lines(file).each do |line|
        next if line.empty?

        rows = line.split('\t')
        key = rows.shift

        node = @root
        key.chars.reverse_each { |c| node = node[c] }
        node.vals = rows
      end
    end

    def has_ends?(input : String)
      node = @root
      chars = input.chars

      while char = chars.pop?
        return false unless node = node[char]?
        return true if node.vals && !chars.empty?
      end

      false
    end

    ##############

    DIR = "var/vphints/tlname"

    class_getter human : self { new("#{DIR}/human.tsv") }
    class_getter affil : self { new("#{DIR}/affil.tsv") }
    class_getter other : self { new("#{DIR}/other.tsv") }
  end

  ####################

  def initialize(dname : String = "combine")
    @udict = VpDict.load(dname)
    @bdict = VpDict.regular
  end

  enum Type
    Human; Affil; Title; Other
  end

  def tl_human(input : String)
    if input.size == 2 && input[0] == '老'
      output = find_defined(input, :human) || [] of String
      extras = translate(input[1..], Trie.human, :human).map! { |x| "lão #{x}" }
      return output.empty? ? extras : output.concat(extras).uniq!
    end

    output = translate(input, Trie.human, :human)
    return output unless input[0] == '小'

    extras = translate(input[1..], Trie.human, :human)
    extras.first(3).map! { |x| "tiểu #{x}" }.concat(output).uniq!
  end

  def tl_other(input : String)
    translate(input, Trie.other, :other)
  end

  # usually we will skip match affil with suffixes if word size under 3 characters
  # but sometime two characters word can be matched with suffixes too

  AFFIL_SHORTS = {
    # '城' => "thành"
    '府' => "? phủ",
    '族' => "? tộc",
    '营' => "doanh ?",
    '朝' => "triều ?",
    '国' => "nước ?",
    '人' => "người ?",
    '地' => "đất ?",
    '市' => "thành phố ?",
    '家' => "? gia",
    '村' => "thôn ?",
  }

  def tl_affil(input : String)
    return translate(input, Trie.affil, :affil) if input.size > 2
    output = [] of String

    if mold = AFFIL_SHORTS[input[-1]]?
      first = input[0].to_s
      find_defined(input, :affil).try { |val| output << mold.sub("?", val) }
      output << mold.sub("?", tl_name(first))
    end

    output << tl_name(input)
    output.uniq!
  end

  def tl_title(input : String)
    output = find_defined(input, :title) || [] of String
    output.map! { |x| TextUtil.titleize(x) }
    output << tl_name(word)
    output.uniq!
  end

  def translate(input : String, trie : Trie, type : Type = :human) : Array(String)
    output = [] of String
    chars = input.chars

    node = trie.root
    while char = chars.pop?
      break if !(node = node[char]?) || chars.empty?
      next unless molds = node.vals

      translate(chars.join, trie, type).reverse_each do |result|
        molds.each { |mold| output.unshift mold.sub("?", result) }
      end
    end

    if defined = find_defined(input, type)
      output = defined.concat(output.first(2))
    elsif output.size < 3
      output << tl_name(input)
    end

    output.uniq!
  end

  HV_MTL = MtCore.new([VpDict.hanviet, VpDict.surname], "[cv]")

  def tl_name(input : String) : String
    return input unless input =~ /\p{Han}/
    mt_list = HV_MTL.translit(input, apply_cap: false)
    TextUtil.titleize(mt_list.to_s)
  end

  def find_defined(input : String, type : Type = :human)
    find_defined(@udict, input, type) || find_defined(@bdict, input, type)
  end

  def find_defined(vdict : VpDict, input : String, type : Type = :human)
    return unless term = vdict.find(input)
    return if term.deleted?

    to_match = type.human? || type.affil? ? {"nr", "nn", "n", ""} : {"nz", "n", ""}
    term.val if to_match.includes?(term.attr)
  end

  DIR = "var/vphints/detect"

  LASTNAMES = load_chars("#{DIR}/lastnames.txt")
  ATTRIBUTE = load_chars("#{DIR}/attribute.txt")

  def self.load_chars(file : String) : Set(Char)
    lines = File.read_lines(file)
    Set(Char).new(lines.map(&.[0]))
  end

  def self.is_human?(input : String)
    return false unless first_char = input[0]?
    return true if LASTNAMES.includes?(first_char)

    if input.size == 2 && first_char.in?('小', '老')
      return LASTNAMES.includes?(input[1]?)
    end

    Trie.human.has_ends?(input)
  end

  def self.is_affil?(input : String)
    Trie.affil.has_ends?(input)
  end
end
