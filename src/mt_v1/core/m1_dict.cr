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

  def scan(chars : Array(Char), idx : Int32 = 0, &) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      break unless trie = node.trie

      char = chars.unsafe_fetch(i)
      char = char - 32 if 'ａ' <= char <= 'ｚ'

      break unless node = trie[char]?
      node.term.try { |term| yield term }
    end
  end
end

class M1::MtDict
  DB_PATH = "var/mtapp/v1dic/v1_defns.dic"

  MAINS = {} of Int32 => self
  AUTOS = {} of Int32 => self
  USERS = {} of String => self

  class_getter regular_main : self do
    MAINS[-1] ||= new(2).load!(-2).load_main!(-1).load!(-3)
  end

  # class_getter regular_temp : self do
  #   TEMPS[-1] ||= new(3).load_temp!(-1)
  # end

  def self.regular_user(uname : String) : self
    USERS["@#{uname}"] ||= new(4).load_user!(-1, uname)
  end

  class_getter regular_init : self do
    new(5).load_init!
  end

  def self.unique_main(wn_id : Int32) : self
    MAINS[wn_id] ||= new(6).load_main!(wn_id)
  end

  # def self.unique_temp(wn_id : Int32) : self
  #   TEMPS[wn_id] ||= new(7).load_temp!(wn_id)
  # end

  def self.unique_auto(wn_id : Int32) : self
    AUTOS[wn_id] ||= new(5)
  end

  def self.unique_user(wn_id : Int32, uname : String) : self
    USERS["#{wn_id}@#{uname}"] ||= new(8).load_user!(wn_id, uname)
  end

  getter trie = MtTrie.new
  delegate scan, to: @trie

  def initialize(@lbl : Int32)
  end

  private def open_db(&)
    DB.open("sqlite3:#{DB_PATH}") { |db| yield db }
  end

  def load!(dic : Int32) : self
    do_load!(dic) { "and tab >= 0" }
  end

  def load_main!(dic : Int32) : self
    do_load!(dic) { "and tab = 1" }
  end

  # def load_temp!(dic : Int32) : self
  #   do_load!(dic) { "and tab > 1" }
  # end

  def load_user!(dic : Int32, uname : String) : self
    do_load!(dic, uname) { "and tab > 1 and uname = ?" }
  end

  private def do_load!(*args : DB::Any, &) : self
    open_db do |db|
      sql = String.build do |io|
        io << "select key, val, ptag, prio from defns"
        io << " where dic = ? "
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

  def load_init!
    DB.open("sqlite3:var/mtdic/fixed/v1_init.dic") do |db|
      sql = "select zstr, tags, mtls from terms where _flag >= 0 and mtls <> ''"

      db.query_each(sql) do |rs|
        key, tags, mtls = rs.read(String, String, String)

        val = mtls.split(/[|ǀ\t]/).first
        tag = PosTag.map_ctb(tags.split(' ')[0], key)

        node = @trie.find!(key)
        node.term = MtTerm.new(key, val, tag: tag, dic: @lbl, prio: 1)
      end
    end

    self
  end

  def add_defn(defn : DbDefn)
    add_term(defn.key, defn.val, defn.ptag, defn.prio)
  end

  def add_term(key : String, val : String, ptag : String = "", prio : Int32 = 2)
    node = @trie.find!(key)

    if val.empty?
      node.term = nil
    else
      val = val.split(/[ǀ|\t]/).first
      node.term = MtTerm.new(key, val, dic: @lbl, ptag: ptag, prio: prio)
    end
  end

  def remove_term(key : String) : Nil
    return unless node = @trie.find(key)
    node.term = nil
  end
end
