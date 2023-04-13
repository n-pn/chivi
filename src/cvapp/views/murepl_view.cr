require "./_base_view"

struct CV::MureplView
  include BaseView

  def initialize(@data : Murepl, @full : Bool = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id
      jb.field "user_id", @data.viuser_id

      jb.field "thread_id", @data.thread_id
      jb.field "thread_mu", @data.thread_mu

      jb.field "touser_id", @data.touser_id
      jb.field "torepl_id", @data.torepl_id

      jb.field "level", @data.level
      jb.field "ohtml", @data.ohtml

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "vcoin", @data.gift_vcoin
      jb.field "repls", [] of Murepl
    }
  end

  def self.as_list(data : Enumerable(Murepl), full = false)
    list = [] of self
    data.each { |x| list << new(x, full: full) }
    list
  end
end
