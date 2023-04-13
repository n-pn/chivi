require "../_base"

class CV::Memoir
  enum Type
    Murepl = 11

    Dtopic = 12
    Dboard = 12
  end

  include Clear::Model
  self.table = "memoirs"

  primary_key type: :serial

  column target_type : Int32 = 0
  column target_id : Int32 = 0

  column viuser_id : Int32 = 0

  column liked_at : Int64 = 0
  column track_at : Int64 = 0

  column viewed_at : Int64 = 0 # user last target visited at
  column tagged_at : Int64 = 0 # user get called in context

  column extra : String? = nil

  #

  def self.load(viuser_id : Int32, target_type : Type, target_id : Int32) : self
    params = {viuser_id: viuser_id, target_type: target_type.value, target_id: target_id}
    self.find(params) || self.new(params)
  end

  def self.glob(user_id : Int32, target_type : Type, target_ids : Array(Int32))
    self.query
      .where("viuser_id = ?", user_id)
      .where("target_type = ?", target_type.value)
      .where("target_id = any(?)", target_ids)
  end
end
