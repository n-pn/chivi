require "./_base_view"

class CV::DtopicView
  include BaseView

  def initialize(@data : Dtopic, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "dboard" do
        jb.object {
          jb.field "id", @data.dboard.id
          jb.field "bname", @data.dboard.bname
          jb.field "bslug", @data.dboard.bslug
        }
      end

      jb.field "u_dname", @data.cvuser.uname
      jb.field "u_privi", @data.cvuser.privi

      jb.field "id", @data.id

      jb.field "title", @data.title
      jb.field "tslug", @data.tslug
      jb.field "brief", @data.brief

      jb.field "labels", @data.dlabel_ids

      jb.field "state", @data.state
      jb.field "utime", @data.utime
      jb.field "ctime", @data.created_at.to_unix

      jb.field "post_count", @data.post_count
      jb.field "like_count", @data.like_count
      jb.field "view_count", @data.view_count

      if @full
        jb.field "bhtml", @data.dtbody.ohtml
        jb.field "coins", @data.dtbody.coins
      end
    }
  end
end
