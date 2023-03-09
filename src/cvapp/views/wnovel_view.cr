require "./_base_view"

struct CV::WnovelView
  include BaseView

  def initialize(@data : Nvinfo, @full = true)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", @data.id
      jb.field "bslug", "#{@data.id}-#{@data.bslug}"

      jb.field "vauthor", @data.author.vname
      jb.field "vtitle", @data.vname

      jb.field "genres", @data.vgenres
      jb.field "bcover", @data.bcover
      jb.field "scover", @data.scover

      jb.field "status", @data.status
      jb.field "mftime", @data.utime

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      if @full
        jb.field "bintro", @data.bintro
        jb.field "labels", @data.vlabels

        jb.field "zauthor", @data.author.zname
        jb.field "ztitle", @data.btitle.zname
        jb.field "htitle", @data.btitle.hname

        jb.field "origins", @data.orig_links
      end
    end
  end

  def self.map(inp : Enumerable(Nvinfo), full = false)
    res = [] of self
    inp.each { |obj| res << new(obj, full) }
    res
  end
end
