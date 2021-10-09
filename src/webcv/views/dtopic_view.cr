require "json"

module CV::DtopicView
  def self.render(jb : JSON::Builder, dtopic : Dtopic, dboard = dtopic.dboard, cvuser = dtopic.cvuser)
    jb.object {
      jb.field "b_id", dboard.id
      jb.field "b_name", dboard.bname
      jb.field "b_slug", dboard.bslug

      jb.field "u_dname", cvuser.uname
      jb.field "u_privi", cvuser.uname

      jb.field "id", dtopic.id

      jb.field "title", dtopic.title
      jb.field "uslug", dtopic.uslug

      jb.field "state", dtopic.state
      jb.field "utime", dtopic.utime
      jb.field "ctime", dtopic.created_at.to_unix

      jb.field "posts", dtopic.posts
      jb.field "marks", dtopic.marks
      jb.field "views", dtopic.views
    }
  end
end
