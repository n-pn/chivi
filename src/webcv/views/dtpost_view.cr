require "json"

module CV::DtpostView
  def self.render(jb : JSON::Builder, dtpost : Dtpost, cvuser = dtpost.cvuser)
    jb.object {
      jb.field "cvuser", {
        uname: cvuser.uname,
        privi: cvuser.privi,
      }

      jb.field "id", dtpost.id
      jb.field "dt_id", dtpost.dt_id

      jb.field "ohtml", dtpost.ohtml
      jb.field "odesc", dtpost.odesc

      jb.field "state", dtpost.state
      jb.field "utime", dtpost.utime

      jb.field "edits", dtpost.edits
      jb.field "likes", dtpost.likes
      jb.field "award", dtpost.award
    }
  end
end
