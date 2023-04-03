require "./_base_view"

struct CV::DreplyView
  include BaseView

  def initialize(@data : Cvrepl, @full : Bool = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "id", @data.id

      jb.field "post_id", @data.cvpost_id
      jb.field "repl_id", @data.repl_cvrepl_id
      jb.field "user_id", @data.viuser_id

      jb.field "ohtml", @data.ohtml

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "coins", @data.coins
      jb.field "repls", [] of Cvrepl
    }
  end

  def self.as_list(data : Enumerable(Cvrepl), full = false)
    list = [] of self
    data.each { |x| list << new(x, full: full) }
    list
  end
end
