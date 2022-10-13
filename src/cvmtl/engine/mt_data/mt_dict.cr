require "log"
require "sqlite3"
require "colorize"

require "./mt_trie"

class MT::MtDict
  DICT_PATH = "var/dicts/cvdicts.db"

  private def open_db
    DB.open "sqlite3://./#{DICT_PATH}" do |db|
      yield db
    end
  end

  #############

  getter dicts = [] of MtTrie

  def initialize(nv_dict : String = "combine", tm_dict : String? = nil, vi_user : String? = nil)
    add_dict(vi_user, nv_dict) if vi_user # user vi_user as dict name
    add_dict(nv_dict)
    add_dict(vi_user, "regular") if vi_user
    add_dict(tm_dict) if tm_dict
    add_dict("fixture")
    add_dict("regular")
  end

  CACHE = {} of String => MtTrie

  def add_dict(dname : String)
    @dicts << (CACHE[dname] ||= load_trie(dname))
  end

  def add_dict(dname : String, uname : String)
    @dicts << (CACHE["#{dname}/#{uname}"] ||= load_trie(dname, uname))
  end

  private def load_trie(dname : String, uname : String? = nil)
    trie = MtTrie.new

    open_db do |db|
      dict_id_query = "select id from dicts where dname = ?"
      break unless dict_id = db.query_one?(dict_id_query, args: [dname], as: Int32)

      uname_query = uname ? "uname = '#{uname}'" : "true"
      terms = db.query_all(<<-SQL, args: [dict_id], as: MtTerm)
        select key, val, alt_val, ptag, prio
        from terms where dict_id = ? and _flag = 0 and #{uname_query}
      SQL

      terms.each { |x| trie.push!(x) }
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
