require "./ws_term"
require "./hash_dict"

class MT::TrieDict
  CACHE = {} of String => self

  class_getter essence : self { load!("essence") }
  class_getter regular : self { load!("regular") }

  def self.load!(dname : String) : self
    CACHE[dname] ||= begin
      self.new.tap do |root|
        time = Time.measure do
          root.load_from_db3!(dname)
          root.load_from_tsv!(dname)
        end

        Log.info { "loading #{dname} trie: #{time.total_milliseconds}" }
      end
    end
  end

  def self.add_term(dname : String, wterm : WsTerm)
    CACHE[dname]?.try(&.[wstem.zstr] = wterm)
  end

  def self.delete_term(dname : String, zstr : String)
    CACHE[dname]?.try(&.[zstr] = nil)
  end

  ####

  property term : WsTerm? = nil
  property hash = {} of Char => TrieDict

  def load_from_db3!(dname : String)
    HashDict.load!(dname).hash.each_key do |zstr|
      self[zstr] = WsTerm.new(zstr)
    end
  end

  DIR = "var/mtdic/wseg"

  def load_from_tsv!(dname : String)
    tsv_file = "#{DIR}/#{dname}.tsv"
    return unless File.file?(tsv_file)

    File.each_line(tsv_file) do |line|
      cols = line.split('\t')
      next if cols.empty?
      term = WsTerm.new(cols)
      self[term.zstr] = term
    end
  end

  def []=(zstr : String, term : WsTerm?)
    self[zstr].term = term
  end

  def [](zstr : String)
    zstr.each_char.reduce(self) do |acc, char|
      acc.hash[char] ||= TrieDict.new
    end
  end

  def scan(chars : Array(Char), start : Int32 = 0, &)
    node = self
    size = 0

    start.upto(chars.size &- 1) do |idx|
      size &+= 1
      char = chars.unsafe_fetch(idx)
      char = CharUtil.to_canon(char, false)

      break unless node = node.hash[char]?
      next unless term = node.term

      yield size, term
    end
  end
end
