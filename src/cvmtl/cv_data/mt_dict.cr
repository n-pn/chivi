require "./open_db"
require "./mt_trie"

class MT::MtDict
  getter dicts = [] of MtTrie

  def initialize(book : String = "combine", pack : String? = nil, user : String? = nil)
    add_dict("user", "@#{user}/#{book}") if user
    add_dict("book", book)
    add_dict("user", "@#{user}/regular") if user
    add_dict("pack", pack) if pack
    add_dict("core", "regular")
  end

  MT_TRIES = {} of String => MtTrie

  def add_dict(dname : String)
    @dicts << (MT_TRIES[dname] ||= load_trie(type, name))
  end

  DICT_IDS = {} of String => Int32

  def get_dict_id(type : String, name : String) : Int32
    DICT_IDS["#{type}/#{name}"] ||= begin
      DbRepo.open_dict_db(type) do |db|
        query = "select id from dicts where name = ?"
        db.query_one?(query, args: [name], as: Int32) || -1
      end
    end
  end

  private def load_trie(type : String, name : String)
    trie = MtTrie.new

    dic = get_dict_id(type, name)
    return trie if dic < 0

    MtTerm.load_all(type, dic) do |term|
      trie.push!(term)
    end

    trie
  end

  def find(input : String)
    chars = input.chars
    @dicts.each do |dict|
      if data = dict.find(chars).try(&.data)
        yield data
      end
    end
  end

  def scan(input : Array(Char), start : Int32 = 0)
    bits = 0_u32

    @dicts.each_with_index do |dict, i|
      dict.scan(input, start) do |term|
        size = term.key.size
        flag = 1.unsafe_shl(size)

        if (bits & flag) == 0
          bits |= flag
          yield term, size, i if term.seg > 0
        end
      end
    end
  end
end

# span = Time.measure do
#   test = MT::MtDict.new

#   test.scan("汉语大辞典".chars) do |term|
#     puts [term.key, term.val]
#   end

#   test.find("汉语") do |term|
#     puts [term.key, term.val]
#   end

#   test.find("汉") do |term|
#     puts [term.key, term.val]
#   end
# end

# puts span.total_milliseconds
