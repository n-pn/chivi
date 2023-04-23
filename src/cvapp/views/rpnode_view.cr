require "./_base_view"

struct CV::RpnodeView
  include BaseView

  def initialize(@data : Rpnode, @full : Bool = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id

      jb.field "user_id", @data.viuser_id
      jb.field "head_id", @data.rproot_id

      jb.field "touser_id", @data.touser_id
      jb.field "torepl_id", @data.torepl_id

      jb.field "level", @data.level
      jb.field "ohtml", @data.ohtml

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime
      jb.field "dtime", @data.deleted_at.try(&.to_unix)

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "vcoin", @data.gift_vcoin
      jb.field "repls", [] of Rpnode
    }
  end

  def self.as_list(data : Enumerable(Rpnode), full = false)
    list = [] of self
    data.each { |x| list << new(x, full: full) }
    list
  end
end
