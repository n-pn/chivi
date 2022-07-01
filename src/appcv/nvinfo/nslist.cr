class CV::Nslist
  getter _base : Nvseed? = nil
  getter _user : Nvseed? = nil

  getter users = [] of Nvseed
  getter other = [] of Nvseed

  def initialize(nslist : Array(Nvseed))
    nslist.each do |nvseed|
      case nvseed.sname
      when "=base" then @_base = nvseed
      when "=user" then @_user = nvseed
      when "users", .starts_with?('@')
        @users << nvseed
      else @other << nvseed
      end
    end

    @other.sort_by!(&.zseed)
    @users.sort_by!(&.utime.-)
  end
end
