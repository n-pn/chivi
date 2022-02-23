require "./_base_view"

struct CV::DtopicView
  include BaseView

  def initialize(@data : Dtopic, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "dboard" do
        jb.object {
          jb.field "id", @data.nvinfo.id
          jb.field "bname", @data.nvinfo.vname
          jb.field "bslug", @data.nvinfo.bslug
        }
      end

      jb.field "id", @data.oid

      jb.field "title", @data.title
      jb.field "tslug", @data.tslug

      jb.field "state", @data.state
      jb.field "labels", @data.dlabel_ids

      jb.field "ctime", @data.created_at.to_unix

      if @full
        jb.field "bhtml", @data.dtbody.ohtml
      end

      jb.field "op_uname", @data.cvuser.uname
      jb.field "op_privi", @data.cvuser.privi

      if @data.post_count > 0
        jb.field "brief", @data.lasttp.otext.split("\n", 2).first?
        jb.field "utime", @data.lasttp.utime

        jb.field "lp_uname", @data.lasttp.cvuser.uname
        jb.field "lp_privi", @data.lasttp.cvuser.privi
      else
        jb.field "brief", @data.brief
        jb.field "utime", @data.utime
      end

      jb.field "post_count", @data.post_count
      jb.field "like_count", @data.like_count
      jb.field "view_count", @data.view_count
    }
  end
end
