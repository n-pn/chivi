require "json"
require "../../data/ysuser"

struct YS::UserView
  def initialize(@data : Ysuser)
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "id", @data.id
      jb.field "uname", @data.vname
      jb.field "uslug", @data.vslug
      jb.field "avatar", @data.y_avatar
    end
  end

  def self.as_hash(inp : Enumerable(Ysuser))
    res = {} of Int32 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end

  def self.as_list(inp : Enumerable(Ysuser), full = false)
    res = [] of self
    inp.each { |obj| res << new(obj, full: full) }
    res
  end
end
