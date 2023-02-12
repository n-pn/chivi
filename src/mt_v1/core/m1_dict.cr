# require "log"
# require "colorize"
require "./mt_node/mt_term"

class M1::MtTrie
  alias HashCT = Hash(Char, self)

  property term : MtTerm? = nil
  property trie : HashCT? = nil

  def find!(input : String) : self
    node = self

    input.each_char do |char|
      trie = node.trie ||= HashCT.new
      node = trie[char] ||= MtTrie.new
    end

    node
  end

  def scan(chars : Array(Char), idx : Int32 = 0) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      break unless trie = node.trie

      char = chars.unsafe_fetch(i)
      break unless node = trie[char]?

      node.term.try { |term| yield term }
    end
  end
end

class M1::MtDict
  DB_PATH = "var/dicts/v1raw/v1_defns.dic"

  CACHED = {} of String => self

  class_getter hanviet : self { new(0).load!(-2).load!(-10) }
  class_getter pin_yin : self { new(0).load!(-2).load!(-11) }

  class_getter regular_main : self { new(2).load!(-2).load_main!(-1).load!(-3) }
  class_getter regular_temp : self { new(3).load_temp!(-1) }

  def self.regular_user(uname : String) : self
    CACHED["@#{uname}"] ||= new(4).load_user!(-1, uname)
  end

  def self.unique_main(wn_id : Int32) : self
    CACHED["#{wn_id}"] ||= new(6).load_main!(wn_id)
  end

  def self.unique_temp(wn_id : Int32) : self
    CACHED["#{wn_id}!"] ||= new(7).load_temp!(wn_id)
  end

  def self.unique_user(wn_id : Int32, uname : String) : self
    CACHED["#{wn_id}!"] ||= new(8).load_user!(wn_id, uname)
  end

  getter trie = MtTrie.new
  delegate scan, to: @trie

  def initialize(@lbl : Int32)
  end

  private def open_db
    DB.open("sqlite3:#{DB_PATH}") { |db| yield db }
  end

  def load!(dic : Int32) : self
    do_load!(dic) { "and tab >= 0" }
  end

  def load_main!(dic : Int32) : self
    do_load!(dic) { "and tab = 1" }
  end

  def load_temp!(dic : Int32) : self
    do_load!(dic) { "and tab > 1" }
  end

  def load_user!(dic : Int32, uname : String) : self
    do_load!(dic, uname) { "and tab > 1 and uname = ?" }
  end

  private def do_load!(*args : DB::Any) : self
    open_db do |db|
      sql = String.build do |io|
        io << "select key, val, ptag, prio from defns"
        io << " where dic = ? and _flag >= 0 "
        io << yield
        io << " order by id asc"
      end

      db.query_each(sql, *args) do |rs|
        key, val, ptag, prio = rs.read(String, String, String, Int32)
        add_term(key, val, ptag, prio)
      end
    end

    self
  end

  def add_term(key : String, val : String, ptag : String, prio : Int32 = 0)
    node = @trie.find!(key)

    if val.empty?
      node.term = nil
    else
      node.term = MtTerm.new(key, val.split('ǀ')[0], dic: @lbl, ptag: ptag, prio: prio)
    end
  end
end
