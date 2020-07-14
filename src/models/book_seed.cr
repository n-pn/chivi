require "./base_model"
require "./chap_item"

class BookSeed
  include BaseModel

  # seed types: 0 => remote, 1 => manual, 2 => locked
  property type = 0

  property name = ""
  property sbid = ""

  property mftime = 0_i64
  property latest = ChapItem.new

  def initialize(@name, @type = 0)
  end

  # update latest chap
  def update_latest(latest : ChapItem, mftime = @mftime)
    if @latest.scid != latest.scid
      mftime = Time.utc.to_unix_ms if mftime == @mftime
      @latest = latest
    else
      @latest.inherit(latest)
    end

    @changes += @latest.reset_changes!

    @mftime = mftime
    @latest
  end
end
