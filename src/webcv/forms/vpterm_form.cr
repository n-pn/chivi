struct CV::VpTermForm
  @params : Amber::Validators::Params
  @key : String
  @_priv : Bool

  def initialize(@params, @dict : VpDict, @user : Cvuser)
    @key = @params["key"].tr("\t\n", " ").strip
    @_priv = @params["_priv"]? == "true"
  end

  def validate : String?
    return "Không đủ quyền hạn để sửa từ!" unless has_privi?

    if @dict.type == 2 && VpDict.fixture.find(@key).try(&.val.first.empty?.!)
      return "Không thể sửa được từ khoá cứng!"
    end
  end

  # check if user has privilege to add new term for this dict
  def has_privi? : Bool
    privi = @user.privi
    privi += 1 if @_priv

    case @dict.kind
    when .novel? then privi > 0
    when .basic? then privi > 1
    else              privi > 2
    end
  end

  def save? : VpTerm?
    val = @params.fetch_str("val").tr("", "").split(" | ").map(&.strip)

    attr = @params.fetch_str("attr", "")
    rank = @params.fetch_str("rank", "").to_i8? || 3_i8

    uname = @_priv ? "!" + @user.uname : @user.uname
    vpterm = VpTerm.new(@key, val, attr, rank, uname: uname)

    @dict.set!(vpterm)
  end
end
