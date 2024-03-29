require "json"

require "../data/yscrit"
require "../../_util/hash_util"
require "../../_util/tran_util"

struct YS::YscritView
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
      jb.field "vhtml", self.render_html

      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "ctime", @data.created_at.to_unix
      jb.field "utime", @data.updated_at.to_unix
    end
  end

  ERR_MESSAGE = "<p><em>Có lỗi dịch đánh giá, mời liên hệ ban quản trị</em></p>"

  def render_html
    unless vi_bd = @data.vi_bd
      vi_bd = TranUtil.call_api(@data.ztext, "bd_zv")
      return ERR_MESSAGE unless vi_bd
      @data.vi_bd = vi_bd
      spawn Yscrit.set_vi_bd(vi_bd, @data.id)
    end

    TranUtil.txt_to_htm(vi_bd || @data.ztext)
  end

  def self.as_list(inp : Enumerable(Yscrit), full = false)
    res = [] of YscritView
    inp.each { |obj| res << new(obj, full: full) }
    res
  end
end
