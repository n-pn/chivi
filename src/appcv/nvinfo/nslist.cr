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

    @_base ||= Nvseed.load!(@nvinfo, "=base", force: true)
    @_user ||= Nvseed.load!(@nvinfo, "=user", force: true)

    @other.sort_by! { |x| SnameMap.zseed(x.sname) }
    @users.sort_by!(&.utime.-)
  end
end
