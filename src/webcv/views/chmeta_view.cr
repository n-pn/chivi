require "./_base_view"

struct CV::ChmetaView
  include BaseView

  def initialize(@seed : Nvseed, @chap : ChInfo, @cpart = 0, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @seed.sname
      jb.field "total", @seed.chap_count

      jb.field "cpart", @cpart
      jb.field "clink", @seed.clink(@chap.schid)

      jb.field "_prev", prev_url
      jb.field "_next", next_url
    }
  end

  def prev_url
    return chap_url(@chap, @cpart - 1) if @cpart > 0
    @seed.chinfo(@chap.chidx - 2).try { |prev| chap_url(prev, -1) }
  end

  def next_url
    return chap_url(@chap, @cpart + 1) if @cpart < @chap.stats.parts - 1
    @seed.chinfo(@chap.chidx).try { |succ| chap_url(succ, 0) }
  end

  def chap_url(chap = @chap, cpart = 0)
    String.build do |io|
      io << chap.trans.uslug << '-' << chap.chidx
      if cpart != 0 && chap.stats.parts > 1
        io << '.' << cpart % chap.stats.parts
      end
    end
  end
end
