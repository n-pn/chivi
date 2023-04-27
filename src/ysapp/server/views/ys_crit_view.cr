require "json"

require "../../data/yscrit"
require "../../../_util/hash_util"

struct YS::CritView
  def initialize(@data : Yscrit, @full = false)
  end

  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  def to_json(jb = JSON::Builder.new)
    jb.object do
      jb.field "id", @data.id

      jb.field "book_id", @data.nvinfo_id
      jb.field "user_id", @data.ysuser_id
      jb.field "list_id", @data.yslist_id

      jb.field "stars", @data.stars
      jb.field "vtags", @data.vtags

      # @data.fix_vhtml(persist: true) if @data.vhtml.empty?
      jb.field "vhtml", @data.vhtml

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.utime
    end
  end

  def self.as_list(inp : Enumerable(Yscrit), full = false)
    res = [] of CritView
    inp.each { |obj| res << new(obj, full: full) }
    res
  end
end
