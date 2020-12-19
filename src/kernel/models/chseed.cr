require "./_models"
require "./serial"

class Chivi::Chseed
  include Clear::Model
  self.table = "chseeds"

  primary_key type: :serial
  belongs_to serial : Serial, foreign_key_type: Int32

  column seed : String
  column sbid : String

  column _order : Int32, presence: false
  column status : Int32, presence: false

  column update_at : Int64, presence: false
  column access_at : Int64, presence: false

  column word_count : Int32, presence: false
  column chap_count : Int32, presence: false

  column view_count : Int32, presence: false
  column read_count : Int32, presence: false

  def set_status(new_status : Int32, force : Bool = false)
    self.status = new_status if force || new_status > self.status
  end

  def set_update(mftime : Int64, force : Bool = false)
    self.update_at = mftime if force || mftime > self.update_at
  end

  def set_access(mftime : Int64, force : Bool = false)
    self.access_at = mftime if force || mftime > self.access_at
  end

  def self.upsert!(seed : String, sbid : String) : self
    unless model = find({seed: seed, sbid: sbid})
      model = new({seed: seed, sbid: sbid})
      yield model
      model.save!
    end

    model
  end
end
