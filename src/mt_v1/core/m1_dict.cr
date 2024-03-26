# require "log"
# require "colorize"
require "./mt_node/mt_term"

class M1::ZvTrie
  alias HashCT = Hash(Char, self)

  property term : MtDefn? = nil
  property trie : HashCT? = nil

  def find!(input : String) : self
    node = self

    input.each_char do |char|
      trie = node.trie ||= HashCT.new
      node = trie[char] ||= ZvTrie.new
    end

    node
  end

  def find(input : String) : self | Nil
    node = self

    input.each_char do |char|
      return unless trie = node.trie
      char = CharUtil.to_canon(char, true)
      return unless node = trie[char]?
    end

    node
  end

  def scan(chars : Array(Char), idx : Int32 = 0, &) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      break unless trie = node.trie

      char = chars[i]
      char = CharUtil.upcase_canonize(char)

      break unless node = trie[char]?
      node.term.try { |term| yield term }
    end
  end
end

class M1::MtDict
  DICT_IDS = {
    "verb_obj"  => -31,
    "v_ditran"  => -30,
    "v_rescom"  => -29,
    "v_dircom"  => -28,
    "qt_times"  => -27,
    "qt_verbs"  => -26,
    "qt_nouns"  => -25,
    "fix_u_zhi" => -24,
    "fix_advbs" => -23,
    "fix_adjts" => -22,
    "fix_verbs" => -21,
    "fix_nouns" => -20,
    "surname"   => -12,
    "pin_yin"   => -11,
    "hanviet"   => -10,
    "fixture"   => -3,
    "essence"   => -2,
    "regular"   => -1,
  } of String => Int32

  CACHE = {} of Int32 => self

  class_getter regular : self do
    new(dnum: 2, d_id: -1)
  end

  def self.wn_dic(wn_id : Int32) : self
    CACHE[wn_id] ||= new(dnum: 6, d_id: wn_id)
  end

  getter trie = ZvTrie.new
  delegate scan, to: @trie

  DB_PATH = "/srv/chivi/mt_db/v1_defns.db3"

  LOAD_SQL = <<-SQL
    select zstr, vstr, ptag, rank from defns
    where d_id = $1
    SQL

  def initialize(@dnum : Int32, d_id : Int32)
    DB.open("sqlite3:#{DB_PATH}") do |db|
      db.query_each(LOAD_SQL, d_id) do |rs|
        zstr, vstr, ptag, rank = rs.read(String, String, String, Int32)
        node = @trie.find!(zstr)
        node.term = vstr.empty? ? nil : MtDefn.new(zstr, vstr, dic: @dnum, ptag: ptag, prio: rank)
      end
    end
  end
end
