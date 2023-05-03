require "../_ctrl_base"

struct CV::GdreplForm
  include JSON::Serializable

  getter itext : String
  getter level : Int16 = 0_i16

  getter torepl : Int32 = 0
  getter touser : Int32 = 0

  getter gdroot : String

  @[JSON::Field(ignored: true)]
  getter gdroot_id : Int32 = 0

  def after_initialize
    @itext = @itext.strip
    @level = 0 if @level < 0
    @gdroot = @gdroot.strip
  end

  def valid?
    raise "Độ dài nội dung quá ngắn" if @itext.size < 3
  end
end
