# # method releted to primary (zseed == 0) chroot type
# # this chroot type do not store text file in storage, it will instead reuse texts
# # from other sources

# class CV::Chroot
#   # clone remote seed, return chmax
#   def mirror_other!(other : self, c_min : Int32 = self.chap_count) : Int32
#     if c_min > 0 && (title = self._repo.get_title(c_min))
#       start = other._repo.match_ch_no(title, c_min)
#     else
#       start = c_min
#     end

#     mirror_other!(other, c_min, other.chap_count, start)
#   end

#   def mirror_other!(other : self, chmin : Int32, chmax : Int32,
#                     new_chmin : Int32 = chmin) : Int32
#     return chmin if other.id == self.id

#     infos = other._repo.all(chmin, chmax)
#     return chmin unless last = infos.last?

#     offset = new_chmin &- chmin

#     infos.map! do |input|
#       entry = input.dup
#       entry.ch_no = input.ch_no! &+ offset
#       entry
#     end

#     self._repo.bulk_upsert(infos)
#     self.set_mftime(other.utime)
#     self.set_latest(last)

#     self.save!
#     chmax
#   end
# end
