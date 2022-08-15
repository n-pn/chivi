struct CV::VpTermForm
  @params : Amber::Validators::Params
  @key : String

  def initialize(@params, @dict : VpDict, @user : Viuser)
    @key = @params["key"].tr("\t\n", " ").strip
    @_mode = @params["_mode"].try(&.to_u8) || 0_u8
  end

  def validate : String?
    return "Không đủ quyền hạn để sửa từ!" unless can_add_term?
    return if @dict.type != 2 || !(term = VpDict.fixture.find(@key))
    return "Không thể sửa được từ khoá cứng!" unless term.deleted?
  end

  # check if user has privilege to add new term for this dict
  def can_add_term? : Bool
    privi = @user.privi
    privi += 1 if @_mode == 1_u8 # allow bump level if using draft mode

    case @dict.kind
    when .novel? then privi > 0
    when .basic? then privi > 1
    else              privi > 2
    end
  end

  def save : VpTerm?
    vals = @params.json("vals").as_a.map(&.as_s.tr("", "").strip)
    tags = @params.json("tags").as_a.map(&.as_s.strip)

    prio = VpTerm.parse_prio(@params.read_str("prio", ""))

    vpterm = VpTerm.new(@key, vals, tags, prio, uname: @user.uname)
    vpterm._mode = @_mode

    @dict.set!(vpterm)
  end
end
