class CV::Nslist
  getter _base : Nvseed { Nvseed.load!(@nvinfo, "=base", force: true) }
  getter _user : Nvseed { Nvseed.load!(@nvinfo, "=user", force: true) }

  getter users = [] of Nvseed
  getter other = [] of Nvseed

  def initialize(@nvinfo : Nvinfo)
    seeds =
      Nvseed.query
        .where("nvinfo_id = #{nvinfo.id}")
        .where("shield < 3")

    seeds.each do |nvseed|
      case nvseed.sname
      when "=base"
        @_base = nvseed
      when "=user"
        @_user = nvseed
      when "users", .starts_with?('@')
        @users << nvseed
      else
        @other << nvseed
      end
    end

    @other.sort_by! { |x| SnameMap.zseed(x.sname) }
    @users.sort_by!(&.utime.-)

    @_base ||= begin
      seed = Nvseed.load!(@nvinfo, "=base", force: true)
      seed.autogen_base!(@other, mode: 0)
      seed
    end

    @_user ||= Nvseed.load!(@nvinfo, "=user", force: true)
  end
end
