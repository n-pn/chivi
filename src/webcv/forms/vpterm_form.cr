struct CV::VpTermForm
  @params : Amber::Validators::Params
  @key : String
  @_priv : Bool

  def initialize(@params, @dict : VpDict, @user : Cvuser)
    @key = @params["key"].tr("\t\n", " ").strip
    @_priv = @params["_priv"]? == "true"
  end

  def validate : String?
    return "Không đủ quyền hạn để sửa từ!" unless can_add_term?

    if @dict.type == 2 && VpDict.fixture.find(@key).try(&.vals.first.empty?.!)
      return "Không thể sửa được từ khoá cứng!"
    end
  end

  # check if user has privilege to add new term for this dict
  def can_add_term? : Bool
    privi = @user.privi
    privi += 1 if @_priv

    case @dict.kind
    when .novel? then privi > 0
    when .basic? then privi > 1
    else              privi > 2
    end
  end

  def save? : VpTerm?
    vals = @params.fetch_str("vals").tr("", "").split(" | ").map(&.strip)

    tags = @params.fetch_str("tags", "").strip.split(" ")
    prio = VpTerm.parse_prio(@params.fetch_str("prio", ""))

    uname = @_priv ? "!" + @user.uname : @user.uname
    vpterm = VpTerm.new(@key, vals, tags, prio, uname: uname)

    @dict.set!(vpterm)
  end
end
