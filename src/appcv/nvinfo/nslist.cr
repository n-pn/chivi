class CV::Nslist
  getter _base : Chroot { init_base }
  getter _user : Chroot { init_user }

  getter users = [] of Chroot
  getter other = [] of Chroot

  def initialize(@nvinfo : Nvinfo)
    Chroot.query.filter_nvinfo(@nvinfo.id).each do |chroot|
      chroot = Chroot.cache!(chroot)

      case chroot.sname
      when "=base"                     then @_base = chroot
      when "=user"                     then @_user = chroot
      when "users", .starts_with?('@') then @users << chroot
      else                                  @other << chroot
      end
    end

    @other.sort_by! { |x| SnameMap.zseed(x.sname) }
    @users.sort_by!(&.utime.-)

    @_base ||= init_base
    @_user ||= init_user
  end

  def init_base
    seed = Chroot.load!(@nvinfo, "=base", force: true)
    seed.tap(&.reload_base!(mode: 0_i8))
  end

  def init_user
    Chroot.load!(@nvinfo, "=user", force: true)
  end
end
