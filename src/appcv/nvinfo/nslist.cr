require "../ch_root"

class CV::Nslist
  getter _base : Chroot { Chroot.load!(@nvinfo, "=base", force: true) }
  getter _user : Chroot { Chroot.load!(@nvinfo, "=user", force: true) }

  getter users = [] of Chroot
  getter other = [] of Chroot

  def initialize(@nvinfo : Nvinfo)
    Chroot.query.filter_nvinfo(@nvinfo.id).each do |chroot|
      chroot.nvinfo = nvinfo
      chroot = Chroot.cache!(chroot)

      case chroot.sname
      when "=base"            then @_base = chroot
      when "=user"            then @_user = chroot
      when .starts_with?('@') then @users << chroot
      else                         @other << chroot
      end
    end

    @other.sort_by! { |x| SnameMap.zseed(x.sname) }
    @users.sort_by!(&.utime.-)
  end
end
