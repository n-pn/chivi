require "./mt_node"

class MT::MtDict
  class_getter core_base : MtDict { load("core", 1, dic: 1_i8) }
  class_getter core_temp : MtDict { load("core", -1, dic: 2_i8) }

  BOOKS = {} of Int32 => MtDict

  def self.book_base(d_id : Int32)
    BOOKS[d_id] ||= load("book", d_id, dic: 3_i8)
  end

  def self.book_temp(d_id : Int32)
    BOOKS[-d_id] ||= load("book", -d_id, dic: 4_i8)
  end

  def self.load(type : String, d_id : Int32, dic : Int8)
    db_path = "sqlite3:./var/dicts/#{type}.dic"

    select_query = <<-SQL
    select key, val, ptag, wseg from terms
    where dic = ? and flag < 1
    SQL

    instance = new(dic)

    DB.open(db_path) do |db|
      db.query_each(select_query, d_id) do |rs|
        key, val, tag, prio = rs.read(String, String, String, Int32)
        instance.add_term(key, val, tag, prio)
      end
    end

    instance
  end

  ########

  getter trie = Trie.new

  def initialize(@dic : Int8)
  end

  def add_term(key : String, val : String, tag : String, prio : Int32)
    term = MtTerm.new(key, val, dic: @dic, tag: tag, prio: prio)
    add_term(key, term)
  end

  def add_term(key : String, term : MtTerm)
    trie = @trie

    key.each_char do |char|
      succ = trie.succ ||= Trie::Succ.new
      trie = succ[char] ||= Trie.new
    end

    data = trie.data ||= Trie::Data.new
    data << term
  end

  def scan(input : Array(Char), start : Int32 = 0) : Nil
    trie = @trie

    start.upto(input.size - 1) do |idx|
      char = input.unsafe_fetch(idx)
      return unless trie = trie[char]?

      trie.data.try { |data| yield data }
    end
  end

  class Trie
    alias Data = Array(MtTerm)
    alias Succ = Hash(Char, Trie)

    property data : Data? = nil
    property succ : Succ? = nil

    @[AlwaysInline]
    def []?(char : Char)
      @succ.try(&.[char]?)
    end
  end
end
