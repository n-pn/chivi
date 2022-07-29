require "./_base_view"

struct CV::ChmetaView
  include BaseView

  def initialize(@seed : Nvseed, @chap : ChInfo, @cpart = 0_i16, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @seed.sname
      jb.field "total", @seed.chap_count

      jb.field "cpart", @cpart
      jb.field "clink", chap_link

      jb.field "_curr", chap_url(@chap, @cpart)
      jb.field "_prev", prev_url
      jb.field "_next", next_url
    }
  end

  def chap_link
    if proxy = @chap.proxy
      SiteLink.text_url(proxy.sname, proxy.snvid, @chap.schid)
    else
      SiteLink.text_url(@seed.sname, @seed.snvid, @chap.schid)
    end
  end

  def prev_url
    return chap_url(@chap, @cpart &- 1) if @cpart > 0
    return if @chap.chidx == 1
    @seed.chinfo(@chap.chidx - 2).try { |prev| chap_url(prev, -1) }
  end

  def next_url
    return chap_url(@chap, @cpart &+ 1) if @cpart < @chap.stats.parts - 1
    return if @chap.chidx == @seed.chap_count
    @seed.chinfo(@chap.chidx).try { |succ| chap_url(succ, 0) }
  end

  def chap_url(chap = @chap, cpart = 0)
    String.build do |io|
      io << chap.chidx << '/' << chap.trans.uslug

      if cpart != 0 && chap.stats.parts > 1
        io << '/' << (cpart % chap.stats.parts &+ 1)
      end
    end
  end
end
