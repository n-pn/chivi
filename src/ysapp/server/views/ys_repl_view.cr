require "json"
require "../../models/ys_repl"

struct YS::ReplView
  def initialize(@data : Ysrepl)
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "yu_id", @data.ysuser_id
      jb.field "vhtml", @data.vhtml
      jb.field "ctime", @data.created_at.to_unix
      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count
    end
  end

  def self.as_list(inp : Enumerable(Ysrepl))
    res = [] of self
    inp.each { |obj| res << new(obj) }
    res
  end
end
