# require "../../remote/remote_info"

# # for source like `hetushu` or `69shu` that can download book info/book text form
# # internet

# class CV::Chroot
#   def reload_remote!(mode : Int8) : Nil
#     self.clear_cache! if mode > 0

#     ttl = map_ttl(force: mode > 0)
#     return if mode < 1 && Time.unix(self.stime) >= Time.utc - ttl
#     self.reseed_remote!(ttl: ttl, force: mode > 1)
#   end

#   def reseed_remote!(ttl : Time::Span, force : Bool = false) : Nil
#     parser = RemoteInfo.new(self.sname, self.s_bid, ttl: ttl)
#     changed = parser.changed?(self.last_schid, self.utime)
#     return unless force || changed

#     raw_infos = parser.chap_infos
#     return if raw_infos.empty?

#     spawn do
#       File.open(self._repo.sauce_path, "w") do |io|
#         raw_infos.each do |x|
#           {x.chidx, x.schid, x.title, x.chvol}.join(io, '\t')
#           io << '\n'
#         end
#       end
#     end

#     sn_id = _repo.sn_id

#     infos = raw_infos.map do |input|
#       entry = Chinfo.new(sn_id, self.s_bid, input.chidx, input.schid.to_i)
#       entry.title = input.title
#       entry.chvol = input.chvol

#       entry
#     end

#     self._repo.bulk_upsert(infos)
#     self.stime = FileUtil.mtime_int(parser.info_file)

#     mftime = parser.update_int
#     mftime = changed ? self.stime : self.utime if mftime == 0

#     self.set_mftime(mftime)
#     self.set_status(parser.status_int.to_i) if force
#     self.set_latest(infos.last, force: true)

#     self.stage = 3_i16 if self.stage < 3
#     self.save!
#   rescue err
#     puts err.inspect_with_backtrace
#   end

#   ############

#   def remote?(force : Bool = true)
#     _repo.stype == 4 || (force && _repo.stype == 3)
#   end

#   def fresh?(privi : Int32 = 4, force : Bool = false)
#     return true if _repo.stype < 3
#     Time.unix(self.stime) >= Time.utc - map_ttl(force) * (5 &- privi)
#   end

#   TTL = {1.days, 5.days, 10.days, 30.days}

#   def map_ttl(force : Bool = false)
#     force ? 2.minutes : TTL[self.nvinfo.status]? || 10.days
#   end
# end
