# require "../shared/nvinfo_util"

# class CV::ZhinfoData
#   alias TabAS = Tabkv(Array(String))

#   ################

#   getter _index : Tabkv(Bindex) { Tabkv(Bindex).new("#{@w_dir}/_index.tsv") }

#   getter bintro : TabAS { TabAS.new("#{@w_dir}/bintro.tsv") }
#   getter genres : TabAS { TabAS.new("#{@w_dir}/genres.tsv") }
#   getter bcover : Tabkv(String) { Tabkv(String).new("#{@w_dir}/bcover.tsv") }

#   getter status : Tabkv(Status) { Tabkv(Status).new("#{@w_dir}/status.tsv") }
#   getter mftime : Tabkv(Mftime) { Tabkv(Mftime).new("#{@w_dir}/mftime.tsv") }
#   getter chsize : Tabkv(Chsize) { Tabkv(Chsize).new("#{@w_dir}/chsize.tsv") }

#   def initialize(@sname : String, @w_dir : String)
#     @force_author = @sname.in?("zxcs_me", "hetushu", "users", "staff", "zhwenpg")
#     @force_btitle = @force_author || @sname.in?("rengshu")
#   end

#   def save!(clean : Bool = false)
#     @_index.try(&.save!(clean: clean))

#     @genres.try(&.save!(clean: clean))
#     @bintro.try(&.save!(clean: clean))
#     @bcover.try(&.save!(clean: clean))

#     @status.try(&.save!(clean: clean))
#     @mftime.try(&.save!(clean: clean))

#     @chsize.try(&.save!(clean: clean))
#   end

#   def add!(entry, snvid : String, stime : Int64)
#     _index.append(snvid, Bindex.new(stime, entry.btitle, entry.author))

#     bintro.append(snvid, entry.bintro)
#     genres.append(snvid, entry.genres)
#     bcover.append(snvid, entry.bcover)

#     mftime.append(snvid, Mftime.new(entry.update_int, entry.update_str))
#     status.append(snvid, Status.new(entry.status_int, entry.status_str))
#   rescue
#     _index.append(snvid, Bindex.new(stime, "", ""))
#   end

#   def get_nvinfo(zauthor : String, ztitle : String)
#     return if ztitle.blank? || zauthor.blank?

#     return unless author = WninfoUtil.get_author(zauthor, force: @force_author)
#     return unless btitle = WninfoUtil.get_btitle(ztitle, force: @force_btitle)

#     Wninfo.upsert!(author, btitle)
#   end

#   def seed!(mode : Int32 = 0, label : String = "-/-")
#     _index.data.each do |snvid, bindex|
#       seed_entry!(snvid, bindex, mode: mode)
#     rescue err
#       puts err.inspect_with_backtrace
#       puts "#{snvid}: #{bindex}"
#     end

#     WninfoUtil.print_stats("#{@sname}/#{label}")
#   end

#   def seed_entry!(snvid : String, bindex : Bindex, mode : Int32 = 0)
#     ztitle, zauthor = bindex.fix_names
#     return unless nvinfo = get_nvinfo(zauthor, ztitle)

#     nvseed = Chroot.upsert!(nvinfo, @sname, snvid)
#     return unless mode > 0 || nvseed.stime < bindex.stime

#     nvseed.stime = bindex.stime

#     nvseed.btitle = bindex.btitle
#     nvseed.author = bindex.author

#     force_mode = mode > 0 ? 1 : 0

#     self.genres[snvid]?.try { |x| nvseed.set_genres(x, mode: force_mode) }
#     self.bintro[snvid]?.try { |x| nvseed.set_bintro(x, mode: force_mode) }
#     self.bcover[snvid]?.try { |x| nvseed.set_bcover(x, mode: force_mode) }
#     self.status[snvid]?.try { |x| nvseed.set_status(x.status, mode: force_mode) }
#     self.mftime[snvid]?.try { |x| nvseed.set_mftime(x.mftime, force: mode > 0) }
#     nvseed.fix_latest(force: mode > 1)

#     if nvinfo.voters < 10
#       voters, rating = get_scores(ztitle, zauthor)
#       nvinfo.fix_scores!(voters, voters &* rating)
#     end

#     nvseed.save!
#     nvinfo.tap(&.add_nvseed(nvseed.zseed)).save!
#   end

#   RATING_FIX = Tabkv(Rating).new("var/zhinfos/rating_fix.tsv", :force)

#   def get_scores(btitle : String, author : String) : {Int32, Int32}
#     if fixed = RATING_FIX["#{btitle}  #{author}"]?
#       {fixed.voters, fixed.rating}
#     elsif @sname.in?("hetushu", "zxcs_me")
#       {Random.rand(20..30), Random.rand(50..60)}
#     else
#       {Random.rand(10..20), Random.rand(40..50)}
#     end
#   end
# end
