require "sqlite3"
require "./mt_node"

class MT::MtDict
  class_getter core_base : MtDict { load_core }
  class_getter core_temp : MtDict { load("core", -1, dic: 3_i8) }

  BOOKS = {} of Int32 => MtDict

  def self.book_base(d_id : Int32)
    BOOKS[d_id] ||= load("book", d_id, dic: 4_i8)
  end

  def self.book_temp(d_id : Int32)
    BOOKS[-d_id] ||= load("book", -d_id, dic: 5_i8)
  end

  def self.load_core
    dict = load("core", 1, dic: 2_i8)

    Dir.glob("var/cvmtl/inits/**/*.tsv").each do |file|
      dict.load_tsv_file(file, dic: 1)
    end

    dict
  end

  def self.load(type : String, d_id : Int32, dic : Int8)
    db_path = "sqlite3:./var/dicts/#{type}.dic"
    new(dic).tap(&.load_dic_file(db_path, d_id: d_id, dic: dic))
  end

  ########

  getter trie = Trie.new

  def initialize(@dic : Int8)
  end

  def load_dic_file(db_path : String, d_id : Int32, dic = @dic)
    select_query = <<-SQL
      select key, val, ptag, wseg from terms
      where dic = ? and flag < 1
    SQL

    DB.open(db_path) do |db|
      db.query_each(select_query, d_id) do |rs|
        key, val, tag, prio = rs.read(String, String, String, Int32)
        add_term(key, val, tag, prio, dic: dic)
      end
    end
  end

  def load_tsv_file(tsv_path : String, dic : Int8 = @dic)
    File.each_line(tsv_path) do |line|
      next if line.empty? || line[0] == '#'
      args = line.split('\t')
      key = args[0]
      val = args[1]? || ""
      tag = args[2]? || "Lit"
      prio = args[3]?.try(&.to_i?) || 2

      add_term(key, val, tag, prio, dic: dic)
    end
  end

  def add_term(key : String, val : String, tag : String, prio : Int32, dic : Int8 = @dic)
    term = MtTerm.new(key, val, dic: dic, tag: tag, prio: prio)
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
