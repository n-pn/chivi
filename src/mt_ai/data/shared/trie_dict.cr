require "./mt_term"
require "./hash_dict"

class MT::TrieDict
  CACHE = {} of String => self

  class_getter essence : self { load!("essence") }

  # class_getter regular : self { load!("regular") }

  # class_getter suggest : self { load!("suggest") }

  def self.load!(dname : String) : self
    CACHE[dname] ||= begin
      self.new.tap do |root|
        time = Time.measure do
          HashDict.load!(dname).hash.each do |zstr, hash|
            root[zstr] = hash.first_value
          end
        end

        Log.info { "loading #{dname} trie: #{time.total_milliseconds}" }
      end
    end
  end

  def self.add_term(dname : String, zstr : String, mterm : MtTerm)
    CACHE[dname]?.try(&.[zstr] = mterm)
  end

  def self.delete_term(dname : String, zstr : String)
    CACHE[dname]?.try(&.[zstr] = nil)
  end

  ####

  property term : MtTerm? = nil
  property hash = {} of Char => TrieDict

  def [](zstr : String)
    zstr.each_char.reduce(self) { |acc, char| acc.hash[char] ||= TrieDict.new }
  end

  def []=(zstr : String, term : MtTerm?)
    self[zstr].term = term
  end

  def match(chars : Array(Char), start : Int32 = 0, dpos : Int32 = 2)
    node = self
    size = 0

    best_term = nil
    best_size = 0

    start.upto(chars.size &- 1) do |idx|
      char = chars.unsafe_fetch(idx)
      char = CharUtil.to_canon(char, true)

      break unless node = node.hash[char]?
      size &+= 1

      next unless term = node.term
      best_term, best_size = term, size
    end

    {best_term, best_size, dpos} if best_term
  end
end
