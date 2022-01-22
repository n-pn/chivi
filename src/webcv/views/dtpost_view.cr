require "./_base_view"

class CV::DtpostView
  include BaseView

  def initialize(@data : Dtpost, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "u_dname", @data.cvuser.uname
      jb.field "u_privi", @data.cvuser.privi

      jb.field "id", @data.id
      jb.field "dt_id", @data.dt_id

      jb.field "ohtml", @data.ohtml
      jb.field "odesc", @data.otext.split("\n", 2).first?

      jb.field "state", @data.state
      jb.field "utime", @data.utime

      jb.field "edit_count", @data.edit_count
      jb.field "like_count", @data.like_count
      jb.field "repl_count", @data.repl_count

      jb.field "coins", @data.coins

      if @full
        jb.field "input", @data.input
        jb.field "itype", @data.itype
      end
    }
  end
end
