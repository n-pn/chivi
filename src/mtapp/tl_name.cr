require "./sp_core"

class MT::TlName
  DIR = "var/mtdic/tl_name"

  class Trie
    class_getter human : self { new("#{DIR}/human.tsv") }
    class_getter affil : self { new("#{DIR}/affil.tsv") }
    class_getter other : self { new("#{DIR}/other.tsv") }

    ##############

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
  end

  ####################

  enum Type
    Human; Affil; Title; Other
  end

  def initialize(wn_id : Int32)
  end

  def tl_by_ptag(input : String, ptag : String)
    case ptag
    when "Nr"               then tl_human(input)
    when "Na", "Nal", "Nag" then tl_affil(input)
    when "nx"               then tl_title(input)
    else                         tl_other(input)
    end
  end

  NAMES_TAGS = {"Nr", "Na", "Nal", "Nag"}
  OTHER_TAGS = {"Nz", "Nw"}

  def tl_human(input : String)
    if input.size == 2 && input[0] == '老'
      output = find_defined(input, NAMES_TAGS) || [] of String
      extras = translate(input[1..], Trie.human, NAMES_TAGS).map! { |x| "lão #{x}" }
      return output.empty? ? extras : output.concat(extras).uniq!
    end

    if input.includes?("·")
      find_defined(input, NAMES_TAGS).try { |vals| return vals }
      names = input.split("·").map! do |x|
        case x
        when "冯" then "von"
        when "德" then "de"
        else
          tl_human(x).first? || SpCore.tl_hvname(x)
        end
      end

      return [names.join(" ")]
    end

    if input[0]? == "圣"
      return translate(input[1..], Trie.human, NAMES_TAGS).map! { |x| "Thánh #{x}" }
    end

    output = translate(input, Trie.human, NAMES_TAGS)
    return output unless input[0]? == '小'

    extras = translate(input[1..], Trie.human, NAMES_TAGS)
    extras.first(3).map! { |x| "tiểu #{x}" }.concat(output).uniq!
  end

  def tl_other(input : String)
    translate(input, Trie.other, OTHER_TAGS)
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
    return translate(input, Trie.affil, NAMES_TAGS) if input.size > 2
    output = find_defined(input, NAMES_TAGS) || [] of String

    if mold = AFFIL_SHORTS[input[-1]]?
      first = input[0].to_s
      output << mold.sub("?", tl_name(first))
    end

    output << tl_name(input)
    output.uniq!
  end

  def tl_title(input : String)
    output = find_defined(input, OTHER_TAGS) || [] of String
    output.map! { |x| TextUtil.titleize(x) }
    output << tl_name(input)
    output.uniq!
  end

  def translate(input : String, trie : Trie, tags : Enumerable(String)) : Array(String)
    output = [] of String
    chars = input.chars

    node = trie.root
    while char = chars.pop?
      break if !(node = node[char]?) || chars.empty?
      next unless molds = node.vals

      translate(chars.join, trie, tags).reverse_each do |tran|
        molds.reverse_each { |mold| output.unshift(mold.sub("?", tran)) }
      end
    end

    if defined = find_defined(input, tags)
      defined.reverse_each { |x| output.unshift(x) }
    end

    if common = find_defined(input, ["n"])
      output.concat(common)
    end

    if output.size < 3
      output << SpCore.tl_hvname(input)
    end

    output.uniq!
  end

  NAMES = load_tsv("#{DIR}/knowns/names-common.tsv")

  def find_defined(input : String, tags : Enumerable(String))
    NAMES[input]?
  end

  # def find_defined(vdict : VpDict, input : String, tags : Enumerable(String))
  #   return if !(term = vdict.find(input)) || term.deleted?
  #   term.vals if tags.includes?(term.tags.first)
  # end

  def self.load_tsv(file : String)
    output = {} of String => Array(String)
    File.each_line(file) do |line|
      key, *vals = line.split('\t')
      output[key] = vals
    end

    output
  end

  LASTNAMES = load_chars("#{DIR}/detect/lastnames.txt")
  ATTRIBUTE = load_chars("#{DIR}/detect/attribute.txt")

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

  # puts TlName.new(0).tl_human("请仙子")
end
