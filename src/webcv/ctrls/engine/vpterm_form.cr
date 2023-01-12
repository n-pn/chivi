require "json"

struct CV::VpTermForm
  include JSON::Serializable

  getter dname : String

  getter key : String
  getter val : String

  getter tags : String
  getter prio : Int8 = 2

  getter _mode : UInt8 = 0

  def after_initialize
    @key = @key.tr("\t\n", " ").strip
    @val = @val.tr("", "").strip
  end

  @[JSON::Field(ignore: true)]
  property! dict : VpDict

  @[JSON::Field(ignore: true)]
  property! user : Viuser

  # def initialize(@params : HTTP::Params, @dict : VpDict, @user : Viuser)
  #   @_mode = @params["_mode"].try(&.to_u8) || 0_u8
  # end

  def validate : String?
    return "Không đủ quyền hạn để sửa từ!" unless can_add_term?
    return if dict.type != 2 || !(term = VpDict.fixture.find(@key))
    return "Không thể sửa được từ khoá cứng!" unless term.deleted?
  end

  # check if user has privilege to add new term for this dict
  def can_add_term? : Bool
    privi = user.privi
    privi += 1 if @_mode == 1_u8 # allow bump level if using draft mode

    case dict.kind
    when .novel? then privi > 0
    when .basic? then privi > 1
    else              privi > 2
    end
  end

  def save : VpTerm?
    vpterm = VpTerm.new(@key, [@val], [@tags], @prio, uname: user.uname)
    vpterm._mode = @_mode
    dict.set!(vpterm)
  end
end
