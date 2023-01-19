require "./wd_defn"

class SP::WdDict
  class Trie
    alias Next = Hash(Char, Trie)

    property data : Int32? = nil
    property trie : Next? = nil

    def next(char : Char) : self
      trie = @trie ||= Next.new
      trie[char] ||= Trie.new
    end

    def set(word : String, data : Int32) : Nil
      node = self

      word.each_char do |char|
        trie = node.trie ||= Next.new
        node = trie[char] ||= Trie.new
      end

      node.data = data
    end

    def all(input : String, start = 0, &) : Nil
      scan_all(input.each_char, start) { |data| yield data }
    end

    def all(chars : Array(Char), start = 0, &) : Nil
      scan_all(chars.each, start) { |data| yield data }
    end

    private def scan_all(iter, offset = 0, &) : Nil
      offset.times { iter.next }

      node = self
      iter.each do |char|
        return unless node = node.trie.try(&.[char]?)
        node.data.try { |x| yield x }
      end
    end
  end

  getter trie : Trie

  def initialize(@name : String)
    @trie = Trie.new
    build_trie!
  end

  def build_trie!
    query = "select word, id from defns order by id asc"
    open_db do |db|
      db.query_each(query) do |rs|
        @trie.set(rs.read(String), rs.read(Int32))
      end
    end
  end

  private def open_db
    WdDefn.open_db(@name) { |db| yield db }
  end

  def scan(input : String | Array(Char), start = 0, &)
    query = "select word, defn from defns where id = ?"

    open_db do |db|
      @trie.all(input, start: start) do |id|
        yield db.query_one(query, id, as: {String, String})
      end
    end
  end

  ########

  class_getter trungviet : self { new("trungviet") }
  class_getter cc_cedict : self { new("cc_cedict") }
  class_getter trich_dan : self { new("trich_dan") }
  class_getter top_terms : self { new("top_terms") }

  # trungviet.scan("阿布亚") do |term|
  #   puts term
  # end
end
