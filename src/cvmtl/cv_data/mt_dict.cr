require "./cv_dict"
require "./cv_term"
require "./mt_trie"

class MT::MtDict
  getter dicts = [] of Tuple(MtTrie, Int32)

  def initialize(book : String = "shared", user : String? = nil, temp : Bool = false)
    # dicts for current book
    # note: by convention dict id for book always smaller than zero

    d_id = -get_dict_id("-#{book}")
    add_dicts("book", d_id: d_id, dpos: 4, user: user, temp: temp) if d_id != 0

    # global dicts used in all books
    add_dicts("core", d_id: 1, dpos: 1, user: user, temp: temp)
  end

  DICT_IDS = {} of String => Int32

  def get_dict_id(name : String) : Int32
    DICT_IDS[name] ||= begin
      query = "select id from dicts where name = ?"
      CvDict.open_db(&.query_one?(query, args: [name], as: Int32)) || 0
    end
  end

  private def add_dicts(type : String, d_id : Int32, dpos : Int32, user : String?, temp : Bool)
    if user
      add_dict("#{type}/#{d_id}/@#{user}", dpos) do
        load_dict(type, [-d_id, user], where: "flag < 0 and user = ?")
      end
    end

    if temp
      add_dict("#{type}/#{d_id}/!temp", dpos) { load_dict(type, [-d_id], where: "flag = 0") }
    end

    add_dict("#{type}/#{d_id}", dpos) { load_dict(type, [d_id], where: "flag < 1") }
  end

  MT_DICTS = {} of String => {MtTrie, Int32}

  private def add_dict(label : String, dpos : Int32)
    @dicts << (MT_DICTS[label] ||= {yield, dpos})
  end

  private def load_dict(type : String, args : Array(DB::Any), where clause : String = "flag < 1") : MtTrie
    trie = MtTrie.new

    query = <<-SQL
      select key, val, alt, ptag, wseg from terms
      where dic = ? and #{clause}
    SQL

    CvTerm.open_db(type) do |db|
      db.query_each(query, args: args) { |rs| trie.push!(rs.read(MtTerm)) }
    end

    trie
  end

  def find(input : String)
    chars = input.chars

    @dicts.each do |dict, _id|
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
