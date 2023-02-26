require "json"
require "../../models/ys_user"

struct YS::UserView
  def initialize(@data : Ysuser)
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "id", @data.id
      jb.field "uname", @data.vname
      jb.field "uslug", @data.id

      jb.field "avatar", ""
    end
  end

  def self.as_hash(inp : Enumerable(Ysuser))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end
end