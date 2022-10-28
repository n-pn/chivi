module MT::FixCmpl
  class Trie
    alias Next = Hash(Char, Trie)

    property cmpl_val : String? = nil
    property verb_val : String? = nil

    property trie : Next? = nil

    def set(word : String, cmpl_val : String? = Nil, verb_val : String? = nil) : Nil
      node = self

      word.chars.reverse_each do |char|
        trie = node.trie ||= Next.new
        node = trie[char] ||= Trie.new
      end

      node.cmpl_val = cmpl_val
      node.verb_val = verb_val
    end

    def get(word : String, wlen = 0) : {Int32, String?, String?}
      node = self
      cmpl_val = verb_val = nil

      word.chars.reverse_each do |char|
        break unless (trie = node.trie) && (node = trie[char]?)
        cmpl_val = node.cmpl_val
        verb_val = node.verb_val
        wlen &+= 1
      end

      {wlen, cmpl_val, verb_val}
    end
  end

  TRIE = load_trie("var/cvmtl/inits/fix_vcompl.tsv")

  def self.load_trie(file : String)
    trie = Trie.new

    File.each_line(file) do |line|
      args = line.split('\t')
      next unless word = args[0]?
      trie.set(word, args[1]?, args[2]?)
    end

    trie
  end

  def self.get(word : String)
    TRIE.get(word)
  end
end
