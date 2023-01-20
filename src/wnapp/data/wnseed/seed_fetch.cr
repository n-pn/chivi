require "../../../_data/remote/remote_info"

class WN::WnSeed
  def remote_reload!(ttl : Time::Span | Time::MonthSpan = 3.minutes, force : Bool = false)
    # TODO: rewrite remote info parser
    parser = CV::RemoteInfo.new(self.sname, self.s_bid, ttl: ttl)
    changed = parser.changed?(self.last_s_cid.to_s, self.mtime)

    return unless force || changed

    raw_infos = parser.chap_infos
    return if raw_infos.empty?

    @_flag = parser.status_int.to_i

    bump_mftime(parser.update_int, force: changed)
    bump_latest(raw_infos.last.chidx, raw_infos.last.schid.to_i)

    self.save!(self.class.repo)

    self.zh_chaps.upsert_infos(raw_infos)
    @vi_chaps = nil # force retranslation
  end
end
