class CV::Nslist
  getter _base : Nvseed { init_base }
  getter _user : Nvseed { init_user }

  getter users = [] of Nvseed
  getter other = [] of Nvseed

  def initialize(@nvinfo : Nvinfo)
    Nvseed.query.filter_nvinfo(@nvinfo.id).each do |nvseed|
      nvseed = Nvseed.cache!(nvseed)

      case nvseed.sname
      when "=base"                     then @_base = nvseed
      when "=user"                     then @_user = nvseed
      when "users", .starts_with?('@') then @users << nvseed
      else                                  @other << nvseed
      end
    end

    @other.sort_by! { |x| SnameMap.zseed(x.sname) }
    @users.sort_by!(&.utime.-)

    @_base ||= init_base
    @_user ||= Nvseed.load!(@nvinfo, "=user", force: true)
  end

  def init_base
    seed = Nvseed.load!(@nvinfo, "=base", force: true)
    seed.tap(&.autogen_base!(@other, mode: 0))
  end

  def init_user
    Nvseed.load!(@nvinfo, "=user", force: true)
  end
end
