require "../mt_core/mt_defn"
require "./qt_node"

class MT::QtDict
  @tries = [] of Trie

  def initialize(d_id : Int32, user : String = "")
    @tries << Trie.new(MtDefn.db_path("common-main"))
    @tries << Trie.new(MtDefn.db_path("common-user"), user) unless user.empty?
    @tries << Trie.new(MtDefn.db_path("wnovel-main"), d_id)
    @tries << Trie.new(MtDefn.db_path("wnovel-user"), d_id, user) unless user.empty?
  end

  def find_best(chars : Array(Char), start = 0) : QtNode
    output = nil

    @tries.reverse_each do |trie|
      node = trie

      start.upto(chars.size &- 1) do |idx|
        char = chars.unsafe_fetch(idx)
        break unless node = node.trie[char]?

        next unless data = node.data
        output = data.dup!(idx) unless output && output.zlen >= data.zlen
      end
    end

    output || begin
      char = chars.unsafe_fetch(start)
      QtNode.new(char, idx: start)
    end
  end

  class Trie
    property data : QtNode? = nil
    getter trie = {} of Char => Trie

    def initialize
    end

    def initialize(db_path : String)
      DB.open("sqlite3://#{db_path}") do |db|
        stmt = "select zstr, vstr, _fmt from defns where vstr <> ''"
        db.query_each(stmt) { |rs| self.add!(rs, dic: 2) }
      end
    end

    def initialize(db_path : String, user : String)
      DB.open("sqlite3://#{db_path}") do |db|
        stmt = "select zstr, vstr, _fmt from defns where vstr <> '' and uname = $1"
        db.query_each(stmt, user) { |rs| self.add!(rs, dic: 4) }
      end
    end

    def initialize(db_path : String, d_id : Int32)
      DB.open("sqlite3://#{db_path}") do |db|
        stmt = "select zstr, vstr, _fmt from defns where vstr <> '' and d_id = $1"
        db.query_each(stmt, d_id) { |rs| self.add!(rs, dic: 6) }
      end
    end

    def initialize(db_path : String, d_id : Int32, user : String)
      DB.open("sqlite3://#{db_path}") do |db|
        stmt = "select zstr, vstr, _fmt from defns where vstr <> '' and d_id = $1 and uname = $2"
        db.query_each(stmt, d_id, user) { |rs| self.add!(rs, dic: 8) }
      end
    end

    def []=(zstr : String, data : QtNode?)
      node = self

      zstr.each_char do |char|
        node = node.trie[char] ||= Trie.new
      end

      node.data = data
    end

    def add!(rs : DB::ResultSet, dic : Int32)
      zstr = rs.read(String)
      vstr = rs.read(String).split('\t').first

      fmt = FmtFlag.new(rs.read(Int32).to_i16)
      self[zstr] = QtNode.new(zstr: zstr, vstr: vstr, dic: dic, fmt: fmt, idx: 0)
    end

    def find!(zstr : String)
      node = self

      zstr.each_char do |char|
        trie = node.trie ||= Hash(Char, Trie).new
        node = trie[char] ||= Trie.new
      end

      node
    end
  end
end
