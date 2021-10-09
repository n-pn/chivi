require "json"

module CV::DtopicView
  def self.render(jb : JSON::Builder, dtopic : Dtopic, dboard = dtopic.dboard, cvuser = dtopic.cvuser)
    jb.object {
      jb.field "dboard", {
        id:    dboard.id,
        bname: dboard.bname,
        bslug: dboard.bslug,
      }

      jb.field "cvuser", {
        uname: cvuser.uname,
        privi: cvuser.privi,
      }

      jb.field "id", dtopic.id

      jb.field "title", dtopic.title
      jb.field "uslug", dtopic.uslug
      jb.field "pdesc", dtopic.pdesc

      jb.field "state", dtopic.state
      jb.field "utime", dtopic.utime

      jb.field "posts", dtopic.posts
      jb.field "marks", dtopic.marks
      jb.field "views", dtopic.views
    }
  end
end
