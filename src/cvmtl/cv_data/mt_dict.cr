require "./open_db"
require "./mt_trie"

class MT::MtDict
  getter dicts = [] of Tuple(MtTrie, Int32)

  def initialize(book : String = "shared", pack : String? = nil, user : String? = nil, temp : Bool = false)
    # dicts for current book
    add_dict("user", "@#{user}=#{book}", 6) if user
    add_dict("temp", book, 6) if temp
    add_dict("book", book, 4)

    # dicts for shared theme
    add_dict("user", "@#{user}=#{pack}", 9) if user && pack
    add_dict("temp", pack, 8) if pack && temp
    add_dict("pack", pack, 7) if pack

    # common dicts used in all books
    add_dict("user", "@#{user}=common", 3) if user
    add_dict("temp", "common", 2) if temp
    add_dict("core", "common", 1)
  end

  MT_DICTS = {} of String => {MtTrie, Int32}

  def add_dict(dname : String, d_idx : Int32)
    @dicts << (MT_DICTS[dname] ||= {load_trie(type, name), d_idx})
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
    dict_id = get_dict_id(type, name)

    unless dict_id < 0
      MtTerm.load_all(type, dict_id) { |term| trie.push!(term) }
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
    bits = 0_u32 # only yield first entry found

    @dicts.each do |dict, d_id|
      dict.scan(input, start) do |term|
        wlen = term.key.size
        flag = 1.unsafe_shl(wlen)

        if (bits & flag) == 0
          bits |= flag
          yield term, wlen, d_id if term.seg > 0
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
