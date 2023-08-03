require "./_base_view"

struct CV::UbmemoView
  include BaseView

  def initialize(@data : Ubmemo, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      if @full
        jb.field "bname", @data.nvinfo.btitle_vi
        jb.field "bslug", "#{@data.nvinfo.id}-#{@data.nvinfo.bslug}"
      end

      jb.field "status", @data.status_s
      jb.field "locked", @data.locked

      jb.field "atime", @data.atime
      jb.field "utime", @data.utime

      jb.field "sname", @data.lr_sname
      jb.field "chidx", @data.lr_chidx
      jb.field "cpart", @data.lr_cpart

      jb.field "title", @data.lc_title
      jb.field "uslug", @data.lc_uslug
    end
  end
end
