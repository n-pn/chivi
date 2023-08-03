require "./_base_view"

struct CV::WninfoView
  include BaseView

  def initialize(@data : Wninfo, @full = true)
  end

  def cover_url
    return "/covers/#{@data.bcover}" unless @data.bcover.empty?
    @data.scover.blank? ? "/covers/_blank.webp" : @data.scover
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", @data.id
      jb.field "bslug", "#{@data.id}-#{@data.bslug}"

      jb.field "vauthor", @data.author_vi
      jb.field "vtitle", @data.btitle_vi

      jb.field "genres", @data.vgenres
      jb.field "bcover", cover_url

      jb.field "status", @data.status
      jb.field "mftime", @data.utime

      jb.field "voters", @data.voters
      jb.field "rating", @data.rating / 10

      if @full
        jb.field "bintro", @data.bintro
        jb.field "labels", @data.vlabels

        jb.field "zauthor", @data.author_zh
        jb.field "ztitle", @data.btitle_zh
        jb.field "htitle", @data.btitle_hv

        jb.field "origins", @data.orig_links
      end
    end
  end

  def self.as_list(inp : Enumerable(Wninfo), full = false)
    res = [] of self
    inp.each { |obj| res << new(obj, full) }
    res
  end

  def self.as_hash(inp : Enumerable(Wninfo))
    res = {} of Int64 => self
    inp.each { |obj| res[obj.id] = new(obj) }
    res
  end
end
