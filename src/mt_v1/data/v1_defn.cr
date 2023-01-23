require "crorm"
require "crorm/sqlite3"

require "../pos_tag"
require "./v1_dict"

class M1::DbDefn
  include Crorm::Model
  @@table = "defns"

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/dicts/v1raw/v1_defns.dic"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/defns_v1.sql") }}
  end

  ###

  field id : Int32, primary: true

  field dic : Int32 = 0
  field tab : Int32 = 0

  field key : String = ""
  field val : String = ""

  field ptag : String = ""
  field prio : Int32 = 2

  field uname : String = ""
  field mtime : Int64 = 0

  field _ctx : String = ""

  field _prev : Int32 = 0
  field _flag : Int32 = 1

  SPLIT = 'ǀ'

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "key", self.key

      jb.field "dic", self.dic
      jb.field "tab", self.tab

      jb.field "vals", self.val.split(SPLIT)
      jb.field "ptag", self.ptag

      jb.field "prio", self.prio

      jb.field "uname", self.uname
      jb.field "mtime", self.utime

      jb.field "_flag", self._flag

      jb.field "state", _flag == -1 ? "Xoá" : (_prev > 0 ? "Sửa" : "Thêm")
    end
  end

  def dic=(dname : String)
    @dic = DbDict.get_id(dname)
  end

  def val=(vals : Array(String))
    @val = vals.join(SPLIT)
  end

  def ptag=(tags : Array(String))
    @ptag = tags.join(' ')
  end

  def mtime=(time : Time)
    @mtime = self.class.mtime(time)
  end

  def utime
    EPOCH &+ self.mtime &* 60
  end

  BASE_COSTS = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def cost : Int32
    size = self.key.size
    prio = self.prio

    BASE_COSTS[(size &- 1) &* 4 &+ prio]? || size &* (prio &* 2 &+ 7) &* 2
  end

  ####

  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc)
    (rtime.to_unix - EPOCH) // 60
  end

  # def create!(repo = self.class.repo) : Array(Int32)
  #   prevs = find_prevs(repo, self.tab)

  #   if @_prev = prevs[0]?
  #     query = "update table #{@@table} set _flag = -_flag where id in ?"
  #     repo.open_tx(&.exec(query, prevs))
  #   end

  #   fields, values = self.get_changes
  #   repo.insert(@@table, fields, values)

  #   prevs
  # end

  def find_prevs(repo = self.class.repo, tab = self.tab)
    query = <<-SQL
      select id from #{@@table}
      where dic = ? and key = ? and ptag = ? and _flag > 0
    SQL

    case tab
    when 3 then query += " and uname = '#{@uname}'" # only search for terms from same user
    when 1 then query += " and tab = 2"             # remove temp defns if add dicts from
    end

    self.class.repo.db.query_all(query, dic, key, ptag, as: Int32)
  end

  def to_term
    term = DbTerm.new

    term.id = self.id
    term.dic = self.dic

    term.key = TextUtil.normalize(self.key)
    term.val = self.val.split(SPLIT).first

    ptag = CV::PosTag.parse(self.ptag, self.key)

    term.etag = ptag.tag.value
    term.epos = ptag.pos.value.to_i64

    term.cost = self.cost

    term
  end
end
