require "./_base_view"

struct CV::WnovelView
  include BaseView

  def initialize(@data : Nvinfo, @full = true)
  end

  def cover_url
    return "/covers/#{@data.bcover}" unless @data.bcover.empty?
    @data.scover.blank? ? "/covers/_blank.webp" : @data.scover
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", @data.id
      jb.field "bslug", "#{@data.id}-#{@data.bslug}"

      jb.field "vauthor", @data.author.vname
      jb.field "vtitle", @data.vname

      jb.field "genres", @data.vgenres
      jb.field "bcover", cover_url

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

  def self.as_list(inp : Enumerable(Nvinfo), full = false)
    res = [] of self
    inp.each { |obj| res << new(obj, full) }
    res
  end

  def self.as_hash(inp : Enumerable(Nvinfo))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end
end
