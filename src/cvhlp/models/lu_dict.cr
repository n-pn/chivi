require "./lu_term"
require "./lu_trie"

class TL::LuDict
  @trie = LuTrie.new

  def initialize(@name : String)
    build_trie!
  end

  private def build_trie!
    # count = 0

    LuTerm.open_db(@name) do |db|
      db.query_each "select word, id from terms order by id asc" do |rs|
        @trie.set(rs.read(String), rs.read(Int32))
        # count &+= 1
      end
    end

    # Log.debug { "<#{@name}> #{count} entries mapped" }
  end

  def scan(input : String)
    LuTerm.open_db(@name) do |db|
      query = "select word, defn from terms where id = ?"

      @trie.all(input) do |id|
        term = db.query_one query, args: [id], as: {String, String}
        yield term
      end
    end
  end

  def scan(chars : Array(Char), start = 0)
    LuTerm.open_db(@name) do |db|
      query = "select word, defn from terms where id = ?"

      @trie.all(chars, start: start) do |id|
        term = db.query_one query, args: [id], as: {String, String}
        yield term
      end
    end
  end

  class_getter trungviet : self { LuDict.new("trungviet") }
  class_getter cc_cedict : self { LuDict.new("cc_cedict") }
  class_getter trich_dan : self { LuDict.new("trich_dan") }
  class_getter top_terms : self { LuDict.new("top_terms") }
end

# TL::LuDict.trungviet.scan("阿布亚") do |term|
#   puts term
# end
