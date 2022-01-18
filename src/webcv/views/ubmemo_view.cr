require "json"

module CV::UbmemoView
  def self.render(jb : JSON::Builder, obj : Ubmemo)
    jb.object do
      jb.field "status", obj.status_s
      jb.field "locked", obj.locked

      jb.field "atime", obj.atime
      jb.field "utime", obj.utime

      jb.field "sname", obj.lr_sname
      jb.field "chidx", obj.lr_chidx
      jb.field "cpart", obj.lr_cpart

      jb.field "title", obj.lc_title
      jb.field "uslug", obj.lc_uslug
    end
  end
end
