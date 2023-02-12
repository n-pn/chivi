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

  def find(input : String) : self | Nil
    node = self

    input.each_char do |char|
      return unless trie = node.trie
      return unless node = trie[char]?
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

  MAINS = {} of Int32 => self
  TEMPS = {} of Int32 => self
  USERS = {} of String => self

  class_getter hanviet : self do
    MAINS[-10] ||= new(0).load!(-2).load!(-10)
  end

  class_getter pin_yin : self do
    MAINS[-11] ||= new(0).load!(-2).load!(-11)
  end

  class_getter regular_main : self do
    MAINS[-1] ||= new(2).load!(-2).load_main!(-1).load!(-3)
  end

  class_getter regular_temp : self do
    TEMPS[-1] ||= new(3).load_temp!(-1)
  end

  def self.regular_user(uname : String) : self
    USERS["-1@#{uname}"] ||= new(4).load_user!(-1, uname)
  end

  def self.unique_main(wn_id : Int32) : self
    MAINS[wn_id] ||= new(6).load_main!(wn_id)
  end

  def self.unique_temp(wn_id : Int32) : self
    TEMPS[wn_id] ||= new(7).load_temp!(wn_id)
  end

  def self.unique_user(wn_id : Int32, uname : String) : self
    USERS["#{wn_id}@#{uname}"] ||= new(8).load_user!(wn_id, uname)
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

  def add_defn(defn : DbDefn)
    add_term(defn.key, defn.val, defn.ptag, defn.prio)
  end

  def add_term(key : String, val : String, ptag : String = "", prio : Int32 = 0)
    node = @trie.find!(key)

    if val.empty?
      node.term = nil
    else
      node.term = MtTerm.new(key, val.split('ǀ')[0], dic: @lbl, ptag: ptag, prio: prio)
    end
  end

  def remove_term(key : String) : Nil
    return unless node = @trie.find(key)
    node.term = nil
  end
end
