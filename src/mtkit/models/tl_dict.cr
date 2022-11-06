require "./tl_term"
require "./tl_trie"

class TL::TlDict
  @trie = TlTrie.new

  def initialize(@name : String)
    build_trie!
  end

  private def build_trie!
    # count = 0

    TlTerm.open_db(@name) do |db|
      db.query_each "select word, id from terms order by id asc" do |rs|
        @trie.set(rs.read(String), rs.read(Int32))
        # count &+= 1
      end
    end

    # Log.debug { "<#{@name}> #{count} entries mapped" }
  end

  def scan(word : String)
    TlTerm.open_db(@name) do |db|
      query = "select word, defn from terms where id = ?"

      @trie.all(word) do |id|
        term = db.query_one query, args: [id], as: {String, String}
        yield term
      end
    end
  end

  class_getter trungviet : self { TlDict.new("trungviet") }
  class_getter cc_cedict : self { TlDict.new("cc_cedict") }
  class_getter trich_dan : self { TlDict.new("trich_dan") }
end

# TL::TlDict.trungviet.scan("阿布亚") do |term|
#   puts term
# end
