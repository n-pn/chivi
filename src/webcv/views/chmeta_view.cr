require "./_base_view"

struct CV::ChmetaView
  include BaseView

  def initialize(@seed : Chroot, @chap : Chinfo, @cpart = 0_i16, @full = false)
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "sname", @seed.sname
      jb.field "total", @seed.chap_count

      jb.field "cpart", @cpart
      jb.field "clink", SiteLink.text_url(@chap.sname, @chap.s_bid, @chap.s_cid)

      jb.field "_curr", chap_url(@chap, @cpart)
      jb.field "_prev", prev_url
      jb.field "_next", next_url
    }
  end

  def prev_url
    return chap_url(@chap, @cpart &- 1) if @cpart > 0
    return if @chap.ch_no == 1
    @seed.chinfo(@chap.ch_no! &- 1).try { |prev| chap_url(prev, -1) }
  end

  def next_url
    return chap_url(@chap, @cpart &+ 1) if @cpart < @chap.p_len &- 1
    return if @chap.ch_no == @seed.chap_count
    @seed.chinfo(@chap.ch_no! &+ 1).try { |succ| chap_url(succ, 0) }
  end

  def chap_url(chap = @chap, cpart = 0)
    String.build do |io|
      io << chap.ch_no << '/' << chap.trans.uslug

      if cpart != 0 && chap.p_len > 1
        io << '/' << (cpart % chap.p_len &+ 1)
      end
    end
  end
end
