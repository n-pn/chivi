require "tabkv"

require "./mt_core"
require "./vp_dict"

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

  enum Type
    Human; Affil; Title; Other
  end

  def initialize(@vdict : VpDict)
    @bdict = VpDict.regular
  end

  def tl_by_ptag(input : String, ptag : String)
    case ptag
    when "nr"             then tl_human(input)
    when "nn", "ns", "nt" then tl_affil(input)
    when "nx"             then tl_title(input)
    else                       tl_other(input)
    end
  end

  def tl_human(input : String)
    if input.size == 2 && input[0] == '老'
      output = find_defined(input, :human) || [] of String
      extras = translate(input[1..], Trie.human, :human).map! { |x| "lão #{x}" }
      return output.empty? ? extras : output.concat(extras).uniq!
    end

    if input.includes?("·")
      find_defined(input, :human).try { |vals| return vals }
      names = input.split("·").map! { |x| tl_human(x).first }
      return [names.join(" ")]
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
    output = find_defined(input, :affil, lax: false) || [] of String

    if mold = AFFIL_SHORTS[input[-1]]?
      first = input[0].to_s
      output << mold.sub("?", tl_name(first))
    end

    output << tl_name(input)
    output.uniq!
  end

  def tl_title(input : String)
    output = find_defined(input, :title) || [] of String
    output.map! { |x| TextUtil.titleize(x) }
    output << tl_name(input)
    output.uniq!
  end

  def translate(input : String, trie : Trie, type : Type = :human) : Array(String)
    output = [] of String
    chars = input.chars

    node = trie.root
    while char = chars.pop?
      break if !(node = node[char]?) || chars.empty?
      next unless molds = node.vals

      translate(chars.join, trie, type).reverse_each do |tran|
        molds.reverse_each { |mold| output.unshift(mold.sub("?", tran)) }
      end
    end

    if defined = find_defined(input, type)
      defined.reverse_each { |x| output.unshift(x) }
    end

    if output.size < 3
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

  NAMES = Tabkv(Array(String)).new("var/vphints/names-common.tsv")

  def find_defined(input : String, type : Type = :human)
    NAMES[input]? || find_defined(@vdict, input, type) || find_defined(@bdict, input, type)
  end

  def find_defined(vdict : VpDict, input : String, type : Type = :human)
    return if !(term = vdict.find(input)) || term.deleted?
    to_match = type.human? || type.affil? ? {"nr", "nn", "nt", "ns"} : {"nz", "nx"}
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
