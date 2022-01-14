require "json"

module CV::DtopicView
  def self.render(jb : JSON::Builder, dtopic : Dtopic, dboard = dtopic.dboard, cvuser = dtopic.cvuser)
    jb.object {
      jb.field "b_id", dboard.id
      jb.field "b_bname", dboard.bname
      jb.field "b_bslug", dboard.bslug

      jb.field "u_dname", cvuser.uname
      jb.field "u_privi", cvuser.uname

      jb.field "id", dtopic.id

      jb.field "title", dtopic.title
      jb.field "tslug", dtopic.tslug
      jb.field "brief", dtopic.brief

      jb.field "labels", dtopic.dlabel_ids

      jb.field "state", dtopic.state
      jb.field "utime", dtopic.utime
      jb.field "ctime", dtopic.created_at.to_unix

      jb.field "post_count", dtopic.post_count
      jb.field "like_count", dtopic.like_count
      jb.field "view_count", dtopic.view_count
    }
  end
end
